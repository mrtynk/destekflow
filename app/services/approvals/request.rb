module Approvals
  class Request
    def self.call(ticket:, reason:, requested_action:, decision_owner:, requested_by:)
      ApprovalRequest.transaction do
        approval = ticket.approval_requests.create!(
          reason:,
          requested_action:,
          decision_owner:,
          requested_by:
        )
        approval.approval_events.create!(
          event_type: "requested",
          actor_name: requested_by,
          details: "#{requested_action} işlemi için insan onayı istendi: #{reason}"
        )
        ticket.ticket_events.create!(
          event_type: "approval_requested",
          actor_name: requested_by,
          details: "Onay ##{approval.id} istendi; kritik işlem karar verilene kadar uygulanmadı."
        )
        approval
      end
    end
  end
end
