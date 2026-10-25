class ApplicationController < ActionController::Base
  before_action :authenticate_demo_site!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def authenticate_demo_site!
    return unless Rails.application.config.x.demo_site_auth_enabled

    username = Rails.application.config.x.demo_site_username.to_s
    password = Rails.application.config.x.demo_site_password.to_s
    unless username.present? && password.bytesize >= 20
      render plain: "Demo erişimi güvenli biçimde yapılandırılmadığı için kapalı.", status: :service_unavailable
      return
    end

    authenticated = authenticate_with_http_basic do |supplied_username, supplied_password|
      secure_match?(supplied_username, username) && secure_match?(supplied_password, password)
    end
    request_http_basic_authentication("DestekFlow kontrollü demo") unless authenticated
  end

  def secure_match?(supplied, expected)
    supplied = supplied.to_s
    supplied.bytesize == expected.bytesize && ActiveSupport::SecurityUtils.secure_compare(supplied, expected)
  end
end
