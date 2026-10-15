class Reply < ApplicationRecord
  belongs_to :ticket
  belongs_to :agent

  validates :body, presence: true
end
