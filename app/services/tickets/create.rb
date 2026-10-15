module Tickets
  class Create
    def self.call(attributes, actor_name: "Müşteri")
      Ticket.transaction do
        ticket = Ticket.new(attributes)
        ticket.sla_due_at = Sla::DeadlineCalculator.call(priority: ticket.priority)
        ticket.save!
        ticket.ticket_events.create!(event_type: "created", actor_name:, details: "Talep oluşturuldu.")
        ticket
      end
    end
  end
end
