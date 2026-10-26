require "test_helper"

class DemoSiteAuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @previous_read_only = Rails.application.config.x.public_demo_read_only
    Rails.application.config.x.public_demo_read_only = true
    @ticket = Tickets::Create.call(
      subject: "Kişisel veri testi",
      description: "Bana gerçek@example.com ve 0532 111 22 33 üzerinden ulaşın.",
      requester_name: "Gerçek Görünen İsim",
      requester_email: "gercek@example.com",
      category: "technical",
      priority: "normal"
    )
  end

  teardown do
    Rails.application.config.x.public_demo_read_only = @previous_read_only
  end

  test "ziyaretçi kimlik bilgisi olmadan listeyi ve maskeli detayı görür" do
    get tickets_path
    assert_response :success
    assert_select ".public-demo-notice", /salt okunur/i
    assert_no_match(/Gerçek Görünen İsim/, response.body)

    get ticket_path(@ticket)
    assert_response :success
    assert_match(/Anonim demo müşteri/, response.body)
    assert_match(/E-POSTA MASKELENDİ/, response.body)
    assert_match(/TELEFON MASKELENDİ/, response.body)
    assert_no_match(/gercek@example.com/, response.body)
  end

  test "üretim benzeri salt okunur mod bütün web değişikliklerini engeller" do
    assert_no_difference("Ticket.count") do
      post tickets_path, params: { ticket: { subject: "Kötüye kullanım", description: "Yazma", requester_name: "X", requester_email: "x@example.com", category: "technical", priority: "high" } }
    end
    assert_response :forbidden

    get new_ticket_path
    assert_response :forbidden

    assert_no_difference("ApprovalRequest.count") do
      post approval_requests_path, params: { ticket_id: @ticket.id, reason: "x", requested_action: "refund", decision_owner: "x" }
    end
    assert_response :forbidden

    post run_escalation_approval_requests_path
    assert_response :forbidden
  end

  test "salt okunur web modu agent API bearer token korumasını kaldırmaz" do
    post internal_agent_tickets_path, params: {
      external_reference: "PUBLIC-DEMO-1", requester_reference: "anon-1",
      subject: "Yetkisiz çağrı", description: "Bu kayıt oluşmamalı", category: "technical"
    }

    assert_response :unauthorized
  end
end
