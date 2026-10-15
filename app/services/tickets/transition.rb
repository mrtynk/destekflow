module Tickets
  class Transition
    class InvalidTransition < StandardError; end

    def self.call(ticket:, to:, actor_name: "Yönetici", at: Time.current)
      to = to.to_s
      unless ticket.allowed_transitions.include?(to)
        raise InvalidTransition, "#{ticket.status} durumundan #{to} durumuna geçilemez"
      end

      Ticket.transaction do
        from = ticket.status
        changes = { status: to }
        changes[:resolved_at] = at if to == "solved"
        changes[:closed_at] = at if to == "closed"
        changes[:resolved_at] = nil if from == "solved" && to == "open"
        ticket.update!(changes)
        ticket.ticket_events.create!(event_type: "status_changed", actor_name:, details: "Durum #{from} → #{to} olarak değiştirildi.")
        ticket
      end
    end
  end
end
