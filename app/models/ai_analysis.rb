class AiAnalysis < ApplicationRecord
  STATUSES = %w[completed failed].freeze

  belongs_to :ticket

  validates :status, inclusion: { in: STATUSES }
  validates :provider, :embedding_model, :generation_model, presence: true
  validates :answer, presence: true, if: :completed?

  def completed?
    status == "completed"
  end
end
