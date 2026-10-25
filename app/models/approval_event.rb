class ApprovalEvent < ApplicationRecord
  belongs_to :approval_request

  validates :event_type, :actor_name, :details, presence: true
end
