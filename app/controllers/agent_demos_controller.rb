class AgentDemosController < ApplicationController
  def show
    @agent_tickets = Ticket.where(origin: "agent_api").includes(:agent_runs).order(created_at: :desc).limit(12)
  end

  def run
    result = AgentWorkflow::Demo.call(scenario: params.require(:scenario))
    session[:agent_demo_reference] = result.ticket.agent_external_reference
    redirect_to result.ticket, notice: result_message(result)
  rescue Ai::GeminiClient::Error, ArgumentError => error
    redirect_to agent_demo_path, alert: "Agent demosu çalıştırılamadı: #{error.message}"
  end

  def repeat
    reference = session[:agent_demo_reference].to_s
    raise ArgumentError, "Önce bir demo senaryosu çalıştırın." if reference.blank?

    scenario = reference[/\AWEB-DEMO-([A-Z]+)-/, 1]&.downcase
    result = AgentWorkflow::Demo.call(scenario:, reference:)
    redirect_to result.ticket, notice: result_message(result)
  rescue Ai::GeminiClient::Error, ArgumentError => error
    redirect_to agent_demo_path, alert: "Tekrar testi çalıştırılamadı: #{error.message}"
  end

  private

  def result_message(result)
    return "Aynı dış referans yakalandı; ikinci talep oluşturulmadı." if result.duplicate
    return "Gemini triyajı tamamlanamadı; güvenli varsayılanla yanıt yayınlanmadan insana devredildi." if result.agent_run.status == "failed"

    if result.agent_run.reply_published?
      "Agent talebi değerlendirdi ve bilgi tabanlı yanıtı yayınladı."
    else
      "Agent talebi değerlendirdi; kod güvenlik kapısı yanıtı engelleyip insana devretti."
    end
  end
end
