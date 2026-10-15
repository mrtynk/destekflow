module Tickets
  class Reply
    def self.call(ticket:, agent:, body:)
      Ticket.transaction do
        reply = ticket.replies.create!(agent:, body:)
        ticket.update!(first_responded_at: Time.current) if ticket.first_responded_at.nil?
        ticket.ticket_events.create!(event_type: "replied", actor_name: agent.name, details: "Temsilci yanıt verdi.")
        reply
      end
    end
  end
end
