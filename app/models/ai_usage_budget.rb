class AiUsageBudget < ApplicationRecord
  validates :provider, presence: true, uniqueness: true
  validates :minute_count, :day_count, numericality: { greater_than_or_equal_to: 0 }
end
