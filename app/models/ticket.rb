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

  validates :subject, :description, :requester_name, :requester_email, presence: true
  validates :priority, inclusion: { in: PRIORITIES }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }

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
end
