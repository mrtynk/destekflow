class Ticket < ApplicationRecord
  PRIORITIES = %w[normal high].freeze
  CATEGORIES = %w[technical billing account other].freeze
  STATUSES = %w[new open pending solved closed].freeze
  TRANSITIONS = {
    "new" => %w[open pending],
    "open" => %w[pending solved],
    "pending" => %w[open solved],
    "solved" => %w[open closed],
    "closed" => []
  }.freeze

  belongs_to :assignee, class_name: "Agent", optional: true
  has_many :replies, dependent: :destroy
  has_many :ticket_events, dependent: :destroy
  has_many :approval_requests, dependent: :destroy
  has_many :ai_analyses, dependent: :destroy
  has_many :agent_runs, dependent: :destroy
  has_many :outgoing_ticket_links, class_name: "TicketLink", foreign_key: :first_ticket_id, inverse_of: :first_ticket, dependent: :destroy
  has_many :incoming_ticket_links, class_name: "TicketLink", foreign_key: :second_ticket_id, inverse_of: :second_ticket, dependent: :destroy

  validates :subject, :description, :requester_name, :requester_email, presence: true
  validates :priority, inclusion: { in: PRIORITIES }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :origin, inclusion: { in: %w[web agent_api] }
  validates :agent_external_reference, uniqueness: true, allow_nil: true
  validates :agent_external_reference, presence: true, if: -> { origin == "agent_api" }
  validates :requester_reference, presence: true, if: :privacy_mode?

  scope :active, -> { where(status: %w[new open pending]) }
  scope :overdue, -> { active.where(first_responded_at: nil).where(sla_due_at: ...Time.current) }

  def first_response_overdue?(at: Time.current)
    first_responded_at.nil? && active? && sla_due_at < at
  end

  def active?
    %w[new open pending].include?(status)
  end

  def allowed_transitions
    TRANSITIONS.fetch(status)
  end

  def closable?(at: Time.current)
    status == "solved" && resolved_at.present? && resolved_at <= at - 48.hours
  end

  def ticket_links
    TicketLink.where(first_ticket: self).or(TicketLink.where(second_ticket: self))
  end

  def related_tickets
    ticket_links.includes(:first_ticket, :second_ticket).map { |link| link.other_ticket(self) }
  end
end
