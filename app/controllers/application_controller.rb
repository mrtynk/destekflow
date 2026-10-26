class ApplicationController < ActionController::Base
  before_action :enforce_public_demo_read_only!
  helper_method :public_demo_read_only?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def public_demo_read_only?
    Rails.application.config.x.public_demo_read_only
  end

  def enforce_public_demo_read_only!
    return unless public_demo_read_only?
    return if request.get? || request.head?

    render plain: "Herkese açık demo salt okunurdur; değişiklik işlemleri kapalıdır.", status: :forbidden
  end
end
