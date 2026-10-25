require "test_helper"

class DemoSiteAuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @previous_enabled = Rails.application.config.x.demo_site_auth_enabled
    @previous_username = Rails.application.config.x.demo_site_username
    @previous_password = Rails.application.config.x.demo_site_password
    Rails.application.config.x.demo_site_auth_enabled = true
    Rails.application.config.x.demo_site_username = "teacher"
    Rails.application.config.x.demo_site_password = "correct-horse-battery-staple"
  end

  teardown do
    Rails.application.config.x.demo_site_auth_enabled = @previous_enabled
    Rails.application.config.x.demo_site_username = @previous_username
    Rails.application.config.x.demo_site_password = @previous_password
  end

  test "kimlik bilgisi olmadan demo ve yönetim işlemleri reddedilir" do
    get tickets_path
    assert_response :unauthorized

    assert_no_difference("ApprovalRequest.count") do
      post approval_requests_path, params: { ticket_id: -1, reason: "x", requested_action: "refund", decision_owner: "x" }
    end
    assert_response :unauthorized

    post run_escalation_approval_requests_path
    assert_response :unauthorized
  end

  test "yanlış kimlik bilgisi reddedilir ve doğru bilgi erişim sağlar" do
    get tickets_path, headers: basic_auth("teacher", "wrong-password-with-length")
    assert_response :unauthorized

    get tickets_path, headers: basic_auth("teacher", "correct-horse-battery-staple")
    assert_response :success
  end

  test "eksik production benzeri yapılandırma fail closed davranır" do
    Rails.application.config.x.demo_site_password = nil

    get tickets_path
    assert_response :service_unavailable
    assert_match(/erişimi güvenli biçimde yapılandırılmadığı için kapalı/, response.body)
  end

  private

  def basic_auth(username, password)
    { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
  end
end
