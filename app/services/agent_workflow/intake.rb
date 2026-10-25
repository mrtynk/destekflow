module AgentWorkflow
  class Intake
    Result = Data.define(:ticket, :agent_run, :duplicate)
    SAFE_AUTO_REPLY_CATEGORIES = %w[technical other].freeze

    def self.call(attributes, client: nil)
      reference = attributes.fetch(:external_reference).to_s
      raise ArgumentError, "Ajan referansı 6-80 karakter olmalıdır." unless reference.length.between?(6, 80)
      requester_reference = attributes.fetch(:requester_reference).to_s
      unless requester_reference.match?(/\A[a-zA-Z0-9_-]{3,80}\z/)
        raise ArgumentError, "Müşteri referansı yalnız anonim harf, sayı, alt çizgi ve tire içermelidir."
      end
      if (existing = Ticket.find_by(agent_external_reference: reference))
        return Result.new(ticket: existing, agent_run: existing.agent_runs.order(:created_at).last, duplicate: true)
      end
      subject = attributes.fetch(:subject).to_s.strip
      description = attributes.fetch(:description).to_s.strip
      raise ArgumentError, "Başlık 5-200 karakter olmalıdır." unless subject.length.between?(5, 200)
      raise ArgumentError, "Açıklama 5-4000 karakter olmalıdır." unless description.length.between?(5, 4_000)

      Ticket.transaction do
        ticket = Tickets::Create.call(
          {
            subject: Privacy::Redactor.call(subject),
            description: Privacy::Redactor.call(description),
            requester_name: "Gizli müşteri",
            requester_email: "#{SecureRandom.uuid}@privacy.invalid",
            requester_reference:,
            agent_external_reference: reference,
            origin: "agent_api",
            privacy_mode: true,
            category: attributes.fetch(:category),
            priority: "normal"
          },
          actor_name: "Müşteri adına çalışan AI agent"
        )
        begin
          triage = Triage.call(subject: ticket.subject, description: ticket.description, client: client || Ai::GeminiClient.new)
        rescue Ai::GeminiClient::Error => error
          run = ticket.agent_runs.create!(
            status: "failed", provider: "Google Gemini", model: Triage::MODEL,
            decision: "human_handoff", reason: "AI triyajı başarısız; güvenli varsayılan insan kuyruğudur.",
            error_code: error.message.first(180)
          )
          ticket.ticket_events.create!(event_type: "agent_handoff", actor_name: "DestekFlow güvenlik katmanı", details: "AI hatası nedeniyle otomatik yanıt yayınlanmadı; insan incelemesi gerekiyor.")
          next Result.new(ticket:, agent_run: run, duplicate: false)
        end
        ticket.update!(priority: triage.priority, sla_due_at: Sla::DeadlineCalculator.call(priority: triage.priority))

        code_requires_human = triage.human_required || triage.priority == "high" ||
                              !SAFE_AUTO_REPLY_CATEGORIES.include?(ticket.category) || triage.suggested_reply.blank? ||
                              triage.knowledge_ids.empty? ||
                              (triage.knowledge_ids - KnowledgeBase.auto_reply_ids).any?
        run = record_run(ticket, triage, code_requires_human)
        code_requires_human ? handoff(ticket, triage) : publish_reply(ticket, triage, run)
        Result.new(ticket:, agent_run: run.reload, duplicate: false)
      end
    rescue ActiveRecord::RecordNotUnique => error
      existing = Ticket.find_by(agent_external_reference: reference)
      raise error unless existing

      Result.new(ticket: existing, agent_run: existing.agent_runs.order(:created_at).last, duplicate: true)
    end

    def self.record_run(ticket, triage, human_required)
      ticket.agent_runs.create!(
        status: "completed", provider: "Google Gemini", model: Triage::MODEL,
        decision: human_required ? "human_handoff" : "auto_reply", reason: triage.reason,
        suggested_reply: triage.suggested_reply, knowledge_evidence: triage.knowledge_ids
      )
    end
    private_class_method :record_run

    def self.handoff(ticket, triage)
      ticket.ticket_events.create!(event_type: "agent_handoff", actor_name: "DestekFlow güvenlik katmanı", details: "AI önerisi yayınlanmadı; insan incelemesi gerekiyor. Gerekçe: #{triage.reason}")
    end
    private_class_method :handoff

    def self.publish_reply(ticket, triage, run)
      agent = Agent.find_or_create_by!(email: "ai-agent@destekflow.invalid") { |record| record.name = "DestekFlow AI Agent" }
      Tickets::Assign.call(ticket:, agent:, actor_name: "Agent orkestrasyonu")
      Tickets::Reply.call(ticket:, agent:, body: triage.suggested_reply)
      run.update!(reply_published: true)
    end
    private_class_method :publish_reply
  end
end
