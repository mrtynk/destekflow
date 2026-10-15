class TicketsController < ApplicationController
  before_action :set_ticket, only: %i[show assign reply transition]

  def index
    @tickets = Ticket.includes(:assignee).order(created_at: :desc)
    @tickets = @tickets.where(status: params[:status]) if Ticket::STATUSES.include?(params[:status])
    @tickets = @tickets.where(priority: params[:priority]) if Ticket::PRIORITIES.include?(params[:priority])
    @priorities = Sla::PriorityAssistant.call(@tickets.to_a)
  end

  def show
    @agents = Agent.order(:name)
  end

  def new
    @ticket = Ticket.new(priority: "normal", category: "technical")
  end

  def create
    @ticket = Tickets::Create.call(ticket_params)
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
    Tickets::Reply.call(ticket: @ticket, agent:, body: params[:body])
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

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:subject, :description, :requester_name, :requester_email, :category, :priority)
  end
end
