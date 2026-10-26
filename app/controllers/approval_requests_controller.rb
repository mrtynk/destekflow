class ApprovalRequestsController < ApplicationController
  before_action :set_approval_request, only: %i[approve reject]

  def index
    @approval_requests = ApprovalRequest.includes(:ticket, :approval_events).oldest_first.group_by(&:status)
  end

  def create
    ticket = Ticket.find(params.require(:ticket_id))
    approval = Approvals::Request.call(
      ticket:,
      reason: Privacy::Redactor.call(params.require(:reason)),
      requested_action: params.require(:requested_action),
      decision_owner: "Herkese Açık Demo Kuyruğu",
      requested_by: "Demo destek temsilcisi"
    )
    redirect_to approval_requests_path(anchor: "approval-#{approval.id}"), notice: "Onay talebi oluşturuldu; kritik işlem henüz uygulanmadı."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to ticket_path(ticket), alert: error.record.errors.full_messages.to_sentence
  end

  def approve
    decide("approved")
  end

  def reject
    decide("rejected")
  end

  def run_escalation
    count = Approvals::EscalateOverdue.call.count
    redirect_to approval_requests_path, notice: "Manuel demo taraması tamamlandı: #{count} onay eskale edildi. Gerçek cron/worker çalıştırılmadı."
  end

  private

  def set_approval_request
    @approval_request = ApprovalRequest.find(params[:id])
  end

  def decide(decision)
    Approvals::Decide.call(approval_request: @approval_request, decision:, actor_name: "Demo insan karar verici")
    redirect_to approval_requests_path(anchor: "approval-#{@approval_request.id}"), notice: "İnsan kararı kaydedildi."
  rescue Approvals::Decide::InvalidTransition => error
    redirect_to approval_requests_path, alert: error.message
  end
end
