require "test_helper"

class InternalAgentTicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = Rails.application.config.x.agent_api_token
    Rails.application.config.x.agent_api_token = "test-agent-token-with-at-least-32-bytes"
  end

  teardown { Rails.application.config.x.agent_api_token = @previous_token }

  test "tokensız ajan talep oluşturamaz" do
    assert_no_difference("Ticket.count") do
      post internal_agent_tickets_path, params: valid_params
    end
    assert_response :unauthorized
  end

  test "tokensız ajan talebi takip edemez" do
    ticket = Tickets::Create.call(subject: "Test", description: "Test", requester_name: "Test", requester_email: "test@example.com", category: "other", priority: "normal")
    get internal_agent_ticket_path(ticket)
    assert_response :unauthorized
  end

  private

  def valid_params
    { external_reference: "external-123", requester_reference: "anon-7", subject: "Yardım", description: "Şifre bağlantısı", category: "technical" }
  end
end
