require "test_helper"

class TicketLinkTest < ActiveSupport::TestCase
  test "ilişki iki kaydı korur geçmiş yazar ve SLA ile durumları değiştirmez" do
    first = create_ticket("Fatura ekranı boş")
    second = create_ticket("Fatura ekranı açılmıyor", email: "diger@example.com")
    snapshots = [ first, second ].to_h { |ticket| [ ticket.id, [ ticket.status, ticket.sla_due_at ] ] }

    link = Tickets::Link.call(ticket: second, related_ticket: first)

    assert_equal [ first.id, second.id ], [ link.first_ticket_id, link.second_ticket_id ]
    assert_equal [ second ], first.related_tickets
    assert_equal [ first ], second.related_tickets
    assert_equal %w[created linked], first.ticket_events.order(:id).pluck(:event_type)
    assert_equal %w[created linked], second.ticket_events.order(:id).pluck(:event_type)
    [ first, second ].each do |ticket|
      ticket.reload
      assert_equal snapshots[ticket.id], [ ticket.status, ticket.sla_due_at ]
    end
  end

  test "aynı ilişki ters sırayla tekrar oluşturulamaz" do
    first = create_ticket("Fatura ekranı boş")
    second = create_ticket("Fatura ekranı açılmıyor", email: "diger@example.com")
    Tickets::Link.call(ticket: first, related_ticket: second)

    assert_raises(ActiveRecord::RecordInvalid) do
      Tickets::Link.call(ticket: second, related_ticket: first)
    end
    assert_equal 1, TicketLink.count
  end

  test "ilişki geri alınır iki talep ve geçmiş korunur" do
    first = create_ticket("Fatura ekranı boş")
    second = create_ticket("Fatura ekranı açılmıyor", email: "diger@example.com")
    link = Tickets::Link.call(ticket: first, related_ticket: second)

    assert_difference("TicketLink.count", -1) do
      Tickets::Unlink.call(ticket: first, link:)
    end

    assert Ticket.exists?(first.id)
    assert Ticket.exists?(second.id)
    assert_equal %w[created linked unlinked], first.ticket_events.order(:id).pluck(:event_type)
    assert_equal %w[created linked unlinked], second.ticket_events.order(:id).pluck(:event_type)
  end

  test "bir talep kendisiyle ilişkilendirilemez" do
    ticket = create_ticket("Fatura ekranı boş")

    assert_raises(ActiveRecord::RecordInvalid) { Tickets::Link.call(ticket:, related_ticket: ticket) }
    assert_equal 0, TicketLink.count
  end

  private

  def create_ticket(subject, email: "musteri@example.com")
    Tickets::Create.call({ subject:, description: "Faturayı indirirken boş sayfa görüyorum", requester_name: "Demo", requester_email: email, category: "billing", priority: "high" })
  end
end
