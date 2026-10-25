require "json"

module AgentWorkflow
  class Triage
    Result = Data.define(:priority, :human_required, :reason, :suggested_reply, :knowledge_ids)
    MODEL = ENV.fetch("AGENT_TRIAGE_MODEL", "gemini-3.5-flash-lite")

    def self.call(subject:, description:, client: Ai::GeminiClient.new)
      raw = client.response(
        model: MODEL,
        instructions: <<~PROMPT,
          Bir destek triyaj ajanısın. Yalnız verilen bilgi tabanı maddelerine dayan.
          JSON dışında hiçbir şey yazma. Şema: {"priority":"normal|high","human_required":true|false,"reason":"kısa gerekçe","suggested_reply":"Türkçe yanıt veya boş","knowledge_ids":["KB-01"]}.
          Finansal itiraz, hukuki tehdit, güvenlik, kimlik, hesap erişimi, belirsizlik veya bilgi tabanında karşılık olmaması halinde human_required=true yap.
          İnsan gerekliyse suggested_reply boş olsun. Kişi hakkında tahmin yürütme.
        PROMPT
        input: "Bilgi tabanı:\n#{KnowledgeBase.context}\n\nTalep başlığı: #{subject}\nTalep açıklaması: #{description}"
      )
      parsed = JSON.parse(raw.to_s.gsub(/\A```json\s*|\s*```\z/, ""))
      priority = parsed.fetch("priority")
      raise Ai::GeminiClient::Error, "Triyaj önceliği geçersiz." unless Ticket::PRIORITIES.include?(priority)

      ids = Array(parsed["knowledge_ids"]) & KnowledgeBase.ids
      Result.new(
        priority:,
        human_required: parsed.fetch("human_required") == true,
        reason: parsed.fetch("reason").to_s.first(500),
        suggested_reply: parsed.fetch("suggested_reply", "").to_s.first(2_000),
        knowledge_ids: ids
      )
    rescue JSON::ParserError, KeyError => error
      raise Ai::GeminiClient::Error, "Triyaj yanıtı doğrulanamadı: #{error.class}."
    end
  end
end
