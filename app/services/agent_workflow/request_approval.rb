module AgentWorkflow
  class RequestApproval
    def self.call(ticket:, reason:, requested_action:, decision_owner:)
      unless ApprovalRequest::REQUESTED_ACTIONS.include?(requested_action)
        raise ArgumentError, "Desteklenmeyen kritik işlem."
      end
      raise ArgumentError, "Agent gerekçesi boş olamaz." if reason.blank?

      ApprovalRequest.transaction do
        approval = Approvals::Request.call(
          ticket:,
          reason:,
          requested_action:,
          decision_owner:,
          requested_by: "DestekFlow AI Agent"
        )
        approval.approval_events.create!(
          event_type: "agent_evaluated",
          actor_name: "DestekFlow AI Agent",
          details: "Agent yalnızca onay istedi; kritik işlem otomatik uygulanmadı. LLM çağrısı yapılmadı."
        )
        approval
      end
    end
  end
end
