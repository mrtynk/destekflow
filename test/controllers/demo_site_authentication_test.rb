require "test_helper"

class DemoSiteAuthenticationTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @previous_agent_token = Rails.application.config.x.agent_api_token
    Rails.application.config.x.agent_api_token = "a" * 32
    @agent = Agent.create!(name: "Demo Temsilci", email: "public-agent@example.com")
  end

  teardown do
    Rails.application.config.x.agent_api_token = @previous_agent_token
  end

  test "anonim ziyaretçi talep oluşturur atar yanıtlar ve durum değiştirir" do
    get tickets_path
    assert_response :success
    assert_select ".public-demo-notice", /Gizlilik korumalı çalışma alanı/

    assert_difference("Ticket.count", 1) do
      post tickets_path, params: { ticket: {
        subject: "Demo bağlantı sorunu", description: "Sahte demo açıklaması",
        category: "technical", priority: "normal"
      } }
    end
    ticket = Ticket.order(:id).last
    assert_redirected_to ticket_path(ticket)
    assert_equal "Anonim Ziyaretçi", ticket.requester_name
    assert_match(/@example\.com\z/, ticket.requester_email)

    post assign_ticket_path(ticket), params: { agent_id: @agent.id }
    assert_redirected_to ticket_path(ticket)
    assert_equal @agent, ticket.reload.assignee

    assert_difference("Reply.count", 1) do
      post reply_ticket_path(ticket), params: { body: "Demo yanıtı" }
    end
    assert_redirected_to ticket_path(ticket)

    post transition_ticket_path(ticket), params: { to: "solved" }
    assert_response :redirect
    assert_equal "solved", ticket.reload.status

    post transition_ticket_path(ticket), params: { to: "pending" }
    assert_response :redirect
    assert_equal "solved", ticket.reload.status
  end

  test "anonim ziyaretçi onay ret ve manuel eskalasyon akışlarını kullanır" do
    ticket = Tickets::Create.call({
      subject: "Demo onay", description: "Sahte kayıt", requester_name: "Demo",
      requester_email: "approval@example.com", category: "billing", priority: "high"
    })

    assert_difference("ApprovalRequest.count", 1) do
      post approval_requests_path, params: { ticket_id: ticket.id, reason: "Demo iade", requested_action: "refund" }
    end
    approval = ApprovalRequest.order(:id).last
    post approve_approval_request_path(approval)
    assert_equal "approved", approval.reload.status

    post approval_requests_path, params: { ticket_id: ticket.id, reason: "Demo ret", requested_action: "refund" }
    rejected = ApprovalRequest.order(:id).last
    post reject_approval_request_path(rejected)
    assert_equal "rejected", rejected.reload.status

    travel_to 31.minutes.ago do
      post approval_requests_path, params: { ticket_id: ticket.id, reason: "Demo eskalasyon", requested_action: "grant_access" }
    end
    escalated = ApprovalRequest.order(:id).last
    post run_escalation_approval_requests_path
    assert_response :redirect
    assert_equal "escalated", escalated.reload.status
  end

  test "public HTML erişimi agent API bearer token korumasını kaldırmaz" do
    post internal_agent_tickets_path, params: {
      external_reference: "PUBLIC-DEMO-1", requester_reference: "anon-1",
      subject: "Yetkisiz çağrı", description: "Bu kayıt oluşmamalı", category: "technical"
    }

    assert_response :unauthorized
  end
end
