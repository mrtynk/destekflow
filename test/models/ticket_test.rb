require "test_helper"

class TicketTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def attributes(priority: "normal")
    { subject: "Bağlantı sorunu", description: "Panele bağlanamıyorum", requester_name: "Ece", requester_email: "ece@example.com", category: "technical", priority: }
  end

  test "yüksek öncelikli talebin ilk yanıt SLA süresi dört saattir" do
    travel_to Time.zone.local(2026, 10, 15, 9) do
      ticket = Tickets::Create.call(attributes(priority: "high"))
      assert_equal 4.hours.from_now, ticket.sla_due_at
    end
  end

  test "normal öncelikli talebin ilk yanıt SLA süresi yirmi dört saattir" do
    travel_to Time.zone.local(2026, 10, 15, 9) do
      ticket = Tickets::Create.call(attributes)
      assert_equal 24.hours.from_now, ticket.sla_due_at
    end
  end

  test "yanıtsız talep SLA süresi geçince ihlal sayılır" do
    travel_to Time.zone.local(2026, 10, 15, 9) do
      ticket = Tickets::Create.call(attributes(priority: "high"))
      travel 5.hours
      assert ticket.reload.first_response_overdue?
    end
  end

  test "çözülen talep kırk sekiz saat sonra kapanmaya uygundur" do
    ticket = Tickets::Create.call(attributes)
    Tickets::Assign.call(ticket:, agent: Agent.create!(name: "Ada", email: "ada@example.com"))
    travel_to Time.zone.local(2026, 10, 15, 9) do
      Tickets::Transition.call(ticket:, to: "solved")
      travel 48.hours
      assert ticket.reload.closable?
      CloseResolvedTicketsJob.perform_now(at: Time.current)
      assert_equal "closed", ticket.reload.status
    end
  end

  test "yasak durum geçişi engellenir" do
    ticket = Tickets::Create.call(attributes)
    assert_raises(Tickets::Transition::InvalidTransition) { Tickets::Transition.call(ticket:, to: "closed") }
    assert_equal "new", ticket.reload.status
  end
end
