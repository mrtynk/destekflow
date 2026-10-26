module Tickets
  class Unlink
    def self.call(ticket:, link:, actor_name: "Operasyon yöneticisi")
      new(ticket:, link:, actor_name:).call
    end

    def initialize(ticket:, link:, actor_name:)
      @ticket = ticket
      @link = link
      @actor_name = actor_name
    end

    def call
      related_ticket = link.other_ticket(ticket)

      TicketLink.transaction do
        link.destroy!
        ticket.ticket_events.create!(event_type: "unlinked", actor_name:, details: "##{related_ticket.id} numaralı taleple ilişki geri alındı.")
        related_ticket.ticket_events.create!(event_type: "unlinked", actor_name:, details: "##{ticket.id} numaralı taleple ilişki geri alındı.")
      end
    end

    private

    attr_reader :ticket, :link, :actor_name
  end
end
