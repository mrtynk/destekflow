require "test_helper"

class InternalAgentApprovalRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = Rails.application.config.x.agent_api_token
    Rails.application.config.x.agent_api_token = "test-agent-token-with-at-least-32-bytes"
    @ticket = Tickets::Create.call({
      subject: "Agent değerlendirmesi",
      description: "Kritik işlem önerisi",
      requester_name: "Ada",
      requester_email: "ada@example.com",
      category: "account",
      priority: "high"
    })
  end

  teardown { Rails.application.config.x.agent_api_token = @previous_token }

  test "tokensız agent çağrısı reddedilir" do
    assert_no_difference("ApprovalRequest.count") do
      post internal_agent_approval_requests_path, params: valid_params
    end
    assert_response :unauthorized
  end

  test "yanlış token reddedilir ve yanıta ya da parametre filtresine sızmaz" do
    supplied = "wrong-agent-token-with-at-least-32-byte"
    post internal_agent_approval_requests_path,
         params: valid_params,
         headers: { "Authorization" => "Bearer #{supplied}" }

    assert_response :unauthorized
    assert_not_includes response.body, supplied
    assert_not_includes response.body, Rails.application.config.x.agent_api_token
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    filtered = filter.filter("authorization" => supplied, "agent_api_token" => Rails.application.config.x.agent_api_token)
    assert_equal "[FILTERED]", filtered["authorization"]
    assert_equal "[FILTERED]", filtered["agent_api_token"]
  end

  test "eksik veya zayıf token yapılandırması API'yi kapalı tutar" do
    Rails.application.config.x.agent_api_token = "short"

    assert_no_difference("ApprovalRequest.count") do
      post internal_agent_approval_requests_path, params: valid_params, headers: auth_header
    end
    assert_response :service_unavailable
    assert_not_includes response.body, "short"
  end

  test "geçersiz agent işlemi doğrulamada reddedilir" do
    assert_no_difference("ApprovalRequest.count") do
      post internal_agent_approval_requests_path,
           params: valid_params.merge(requested_action: "delete_everything"),
           headers: auth_header
    end
    assert_response :unprocessable_entity
  end

  test "yetkili agent yalnızca denetlenebilir insan onayı ister" do
    assert_difference("ApprovalRequest.count", 1) do
      post internal_agent_approval_requests_path, params: valid_params, headers: auth_header
    end
    assert_response :created
    body = response.parsed_body
    assert_equal false, body["critical_action_executed"]
    assert_equal "requested", body["status"]
    assert_equal %w[requested agent_evaluated], ApprovalRequest.last.approval_events.order(:id).pluck(:event_type)
    assert_equal "new", @ticket.reload.status
  end

  private

  def valid_params
    { ticket_id: @ticket.id, reason: "Riskli erişim", requested_action: "grant_access", decision_owner: "Güvenlik Lideri" }
  end

  def auth_header
    { "Authorization" => "Bearer test-agent-token-with-at-least-32-bytes" }
  end
end
