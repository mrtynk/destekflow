module Approvals
  class Decide
    class InvalidTransition < StandardError; end

    DECISIONS = %w[approved rejected].freeze

    def self.call(approval_request:, decision:, actor_name:)
      raise InvalidTransition, "Karar approved veya rejected olmalıdır." unless DECISIONS.include?(decision)

      approval_request.with_lock do
        unless approval_request.allowed_transitions.include?(decision)
          raise InvalidTransition, "#{approval_request.status} durumundan #{decision} durumuna geçilemez."
        end

        approval_request.update!(status: decision, decided_at: Time.current, decided_by: actor_name)
        approval_request.approval_events.create!(
          event_type: decision,
          actor_name:,
          details: decision == "approved" ? "İnsan onayı verildi." : "İnsan onayı reddedildi."
        )
        approval_request.ticket.ticket_events.create!(
          event_type: "approval_#{decision}",
          actor_name:,
          details: "Onay ##{approval_request.id} #{decision == 'approved' ? 'kabul edildi' : 'reddedildi'}."
        )
      end

      approval_request
    end
  end
end
