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
          requested_by: "Kural tabanlı demo agent"
        )
        approval.approval_events.create!(
          event_type: "agent_evaluated",
          actor_name: "Kural tabanlı demo agent",
          details: "Agent yalnızca onay istedi; kritik işlem otomatik uygulanmadı. LLM çağrısı yapılmadı."
        )
        approval
      end
    end
  end
end
