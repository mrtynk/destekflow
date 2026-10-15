module Tickets
  class Assign
    def self.call(ticket:, agent:, actor_name: "Yönetici")
      Ticket.transaction do
        ticket.update!(assignee: agent)
        ticket.ticket_events.create!(event_type: "assigned", actor_name:, details: "#{agent.name} temsilcisine atandı.")
        Tickets::Transition.call(ticket:, to: "open", actor_name:) if ticket.status == "new"
        ticket
      end
    end
  end
end
