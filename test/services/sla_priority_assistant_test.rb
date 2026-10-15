require "test_helper"

class SlaPriorityAssistantTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test "SLA ihlali olan talebi ilk sıraya alır ve nedenini açıklar" do
    travel_to Time.zone.local(2026, 10, 15, 12) do
      overdue = Ticket.create!(subject: "Geciken", description: "A", requester_name: "A", requester_email: "a@example.com", category: "other", priority: "normal", status: "open", sla_due_at: 1.minute.ago)
      risky = Ticket.create!(subject: "Riskli", description: "B", requester_name: "B", requester_email: "b@example.com", category: "other", priority: "high", status: "open", sla_due_at: 30.minutes.from_now)

      results = Sla::PriorityAssistant.call([ risky, overdue ])

      assert_equal overdue, results.first.ticket
      assert_includes results.first.reason, "aşıldı"
      assert_includes results.second.reason, "30 dakika"
    end
  end
end
