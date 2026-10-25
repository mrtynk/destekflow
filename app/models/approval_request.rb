class ApprovalRequest < ApplicationRecord
  STATUSES = %w[requested approved rejected escalated].freeze
  REQUESTED_ACTIONS = %w[refund close_ticket grant_access].freeze
  TERMINAL_STATUSES = %w[approved rejected].freeze
  TRANSITIONS = {
    "requested" => %w[approved rejected escalated],
    "escalated" => %w[approved rejected],
    "approved" => [],
    "rejected" => []
  }.freeze

  belongs_to :ticket
  has_many :approval_events, dependent: :destroy

  validates :reason, :requested_action, :decision_owner, :requested_by, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :requested_action, inclusion: { in: REQUESTED_ACTIONS }
  validates :reason, length: { maximum: 2_500 }
  validates :decision_owner, :requested_by, length: { maximum: 200 }

  scope :oldest_first, -> { order(created_at: :asc) }

  def allowed_transitions
    TRANSITIONS.fetch(status)
  end

  def pending_decision?
    %w[requested escalated].include?(status)
  end
end
