class Agent < ApplicationRecord
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :assignee_id, inverse_of: :assignee
  has_many :replies, dependent: :restrict_with_error

  validates :name, :email, presence: true
  validates :email, uniqueness: true
end
