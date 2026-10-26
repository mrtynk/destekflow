module Tickets
  class Link
    def self.call(ticket:, related_ticket:, actor_name: "Operasyon yöneticisi")
      new(ticket:, related_ticket:, actor_name:).call
    end

    def initialize(ticket:, related_ticket:, actor_name:)
      @ticket = ticket
      @related_ticket = related_ticket
      @actor_name = actor_name
    end

    def call
      first, second = [ ticket, related_ticket ].sort_by(&:id)
      if first == second
        invalid_link = TicketLink.new(first_ticket: first, second_ticket: second, linked_by: actor_name)
        invalid_link.validate
        raise ActiveRecord::RecordInvalid, invalid_link
      end

      TicketLink.transaction do
        link = TicketLink.create!(first_ticket: first, second_ticket: second, linked_by: actor_name)
        record_event(ticket, "linked", "##{related_ticket.id} numaralı benzer taleple ilişkilendirildi.")
        record_event(related_ticket, "linked", "##{ticket.id} numaralı benzer taleple ilişkilendirildi.")
        link
      end
    end

    private

    attr_reader :ticket, :related_ticket, :actor_name

    def record_event(owner, type, details)
      owner.ticket_events.create!(event_type: type, actor_name:, details:)
    end
  end
end
