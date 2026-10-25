class AgentRun < ApplicationRecord
  STATUSES = %w[completed failed].freeze
  DECISIONS = %w[auto_reply human_handoff].freeze

  belongs_to :ticket

  validates :status, inclusion: { in: STATUSES }
  validates :decision, inclusion: { in: DECISIONS }
  validates :provider, :model, :reason, presence: true
end
