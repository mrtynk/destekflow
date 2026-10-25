module Internal
  class AgentTicketsController < ActionController::API
    before_action :authenticate_agent!

    def create
      result = AgentWorkflow::Intake.call(intake_params.to_h.symbolize_keys)
      render json: serialize(result), status: result.duplicate ? :ok : :created
    rescue ActionController::ParameterMissing, ArgumentError, ActiveRecord::RecordInvalid => error
      render json: { error: error.message }, status: :unprocessable_entity
    end

    def show
      ticket = Ticket.find(params[:id])
      render json: {
        id: ticket.id, status: ticket.status, priority: ticket.priority,
        privacy_mode: ticket.privacy_mode, requester_reference: ticket.requester_reference,
        latest_agent_decision: ticket.agent_runs.order(:created_at).last&.decision
      }
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Talep bulunamadı." }, status: :not_found
    end

    private

    def intake_params
      params.permit(:external_reference, :requester_reference, :subject, :description, :category).tap do |permitted|
        %w[external_reference requester_reference subject description category].each { |key| permitted.require(key) }
      end
    end

    def serialize(result)
      {
        id: result.ticket.id, duplicate: result.duplicate, status: result.ticket.status,
        priority: result.ticket.priority, privacy_mode: result.ticket.privacy_mode,
        decision: result.agent_run&.decision, reply_published: result.agent_run&.reply_published,
        human_required: result.agent_run&.decision == "human_handoff"
      }
    end

    def authenticate_agent!
      configured = Rails.application.config.x.agent_api_token.to_s
      return render(json: { error: "Agent API güvenli biçimde yapılandırılmadığı için devre dışı." }, status: :service_unavailable) if configured.bytesize < 32

      supplied = request.authorization.to_s.delete_prefix("Bearer ")
      authorized = supplied.bytesize == configured.bytesize && ActiveSupport::SecurityUtils.secure_compare(supplied, configured)
      render json: { error: "Yetkisiz agent çağrısı." }, status: :unauthorized unless authorized
    end
  end
end
