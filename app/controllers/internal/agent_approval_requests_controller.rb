module Internal
  class AgentApprovalRequestsController < ActionController::API
    before_action :authenticate_agent!

    def create
      approval = AgentWorkflow::RequestApproval.call(
        ticket: Ticket.find(params.require(:ticket_id)),
        reason: params.require(:reason),
        requested_action: params.require(:requested_action),
        decision_owner: params.require(:decision_owner)
      )
      render json: {
        id: approval.id,
        status: approval.status,
        critical_action_executed: false,
        message: "İnsan kararı bekleniyor."
      }, status: :created
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Talep bulunamadı." }, status: :not_found
    rescue ActionController::ParameterMissing, ArgumentError => error
      render json: { error: error.message }, status: :unprocessable_entity
    end

    private

    def authenticate_agent!
      configured_token = Rails.application.config.x.agent_api_token.to_s
      supplied_token = request.authorization.to_s.delete_prefix("Bearer ")
      authorized = configured_token.present? && supplied_token.bytesize == configured_token.bytesize &&
                   ActiveSupport::SecurityUtils.secure_compare(supplied_token, configured_token)
      render json: { error: "Yetkisiz agent çağrısı." }, status: :unauthorized unless authorized
    end
  end
end
