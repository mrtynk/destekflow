module Approvals
  class EscalateOverdue
    def self.call(now: Time.current, threshold: Rails.application.config.x.approvals.escalation_threshold,
                  decision_owner: Rails.application.config.x.approvals.escalation_owner)
      escalated = []
      ApprovalRequest.where(status: "requested", created_at: ..(now - threshold)).find_each do |approval|
        approval.with_lock do
          next unless approval.status == "requested" && approval.created_at <= now - threshold

          approval.update!(status: "escalated", escalated_at: now, decision_owner:)
          approval.approval_events.create!(
            event_type: "escalated",
            actor_name: "Sistem eskalasyon kuralı",
            details: "Bekleme süresi #{threshold.in_minutes.to_i} dakikayı geçti; #{decision_owner} kuyruğuna aktarıldı."
          )
          approval.ticket.ticket_events.create!(
            event_type: "approval_escalated",
            actor_name: "Sistem eskalasyon kuralı",
            details: "Onay ##{approval.id}, #{decision_owner} kuyruğuna eskale edildi."
          )
          escalated << approval
        end
      end
      escalated
    end
  end
end
