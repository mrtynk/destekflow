class TicketsController < ApplicationController
  before_action :set_ticket, only: %i[show assign reply transition link_related unlink_related analyze_with_rag]

  def index
    @tickets = Ticket.includes(:assignee).order(created_at: :desc)
    @tickets = @tickets.where(status: params[:status]) if Ticket::STATUSES.include?(params[:status])
    @tickets = @tickets.where(priority: params[:priority]) if Ticket::PRIORITIES.include?(params[:priority])
    @priorities = Sla::PriorityAssistant.call(@tickets.to_a)
  end

  def show
    @agents = Agent.order(:name)
    linked_ids = @ticket.related_tickets.map(&:id)
    candidates = Ticket.where.not(id: [ @ticket.id, *linked_ids ])
    @similar_tickets = Tickets::Similarity.call(@ticket, candidates:)
    @latest_ai_analysis = @ticket.ai_analyses.order(created_at: :desc).first
  end

  def analyze_with_rag
    linked_ids = @ticket.related_tickets.map(&:id)
    candidates = Ticket.where.not(id: [ @ticket.id, *linked_ids ])
    Tickets::RagSimilarity.call(@ticket, candidates:)
    redirect_to @ticket, notice: "RAG analizi tamamlandı; sonuç insan incelemesine sunuldu."
  rescue Ai::GeminiClient::Error => error
    redirect_to @ticket, alert: "RAG analizi çalıştırılamadı: #{error.message}"
  end

  def new
    @ticket = Ticket.new(priority: "normal", category: "technical")
  end

  def create
    @ticket = Tickets::Create.call(public_demo_ticket_params)
    redirect_to @ticket, notice: "Destek talebiniz oluşturuldu."
  rescue ActiveRecord::RecordInvalid => error
    @ticket = error.record
    render :new, status: :unprocessable_entity
  end

  def assign
    Tickets::Assign.call(ticket: @ticket, agent: Agent.find(params[:agent_id]))
    redirect_to @ticket, notice: "Talep temsilciye atandı."
  end

  def reply
    agent = @ticket.assignee || Agent.find(params[:agent_id])
    Tickets::Reply.call(ticket: @ticket, agent:, body: Privacy::Redactor.call(params[:body]))
    redirect_to @ticket, notice: "Yanıt eklendi."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to @ticket, alert: error.record.errors.full_messages.to_sentence
  end

  def transition
    Tickets::Transition.call(ticket: @ticket, to: params[:to])
    redirect_to @ticket, notice: "Talep durumu güncellendi."
  rescue Tickets::Transition::InvalidTransition => error
    redirect_to @ticket, alert: error.message
  end

  def link_related
    related_ticket = Ticket.find(params.require(:related_ticket_id))
    Tickets::Link.call(ticket: @ticket, related_ticket:)
    redirect_to @ticket, notice: "Talepler silinmeden ilişkilendirildi."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to @ticket, alert: error.record.errors.full_messages.to_sentence.presence || "Bu ilişki zaten var veya geçersiz."
  end

  def unlink_related
    link = @ticket.ticket_links.find(params.require(:link_id))
    Tickets::Unlink.call(ticket: @ticket, link:)
    redirect_to @ticket, notice: "Talep ilişkisi geri alındı; iki kayıt da korundu."
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:subject, :description, :category, :priority)
  end

  def public_demo_ticket_params
    permitted = ticket_params.to_h.symbolize_keys
    permitted.merge(
      subject: Privacy::Redactor.call(permitted[:subject]),
      description: Privacy::Redactor.call(permitted[:description]),
      requester_name: "Anonim Ziyaretçi",
      requester_email: "demo-#{SecureRandom.uuid}@example.com"
    )
  end
end
