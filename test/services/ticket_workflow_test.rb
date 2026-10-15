require "test_helper"

class TicketWorkflowTest < ActiveSupport::TestCase
  test "talep atanır yanıtlanır ve çözülürken geçmiş tutulur" do
    agent = Agent.create!(name: "Can", email: "can@example.com")
    ticket = Tickets::Create.call({ subject: "Hesap kilitli", description: "Giriş yapamıyorum", requester_name: "Ela", requester_email: "ela@example.com", category: "account", priority: "normal" })

    Tickets::Assign.call(ticket:, agent:)
    reply = Tickets::Reply.call(ticket:, agent:, body: "Hesabınızı yeniden açtık.")
    Tickets::Transition.call(ticket:, to: "solved", actor_name: agent.name)

    assert_equal agent, ticket.reload.assignee
    assert_equal "Hesabınızı yeniden açtık.", reply.body
    assert ticket.first_responded_at.present?
    assert_equal "solved", ticket.status
    assert_equal %w[created assigned status_changed replied status_changed], ticket.ticket_events.order(:created_at, :id).pluck(:event_type)
  end
end
