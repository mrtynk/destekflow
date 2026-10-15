class TicketEvent < ApplicationRecord
  belongs_to :ticket

  validates :event_type, :actor_name, :details, presence: true
end
