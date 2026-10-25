module AgentWorkflow
  class Demo
    SCENARIOS = {
      "safe" => { subject: "Şifre sıfırlama bağlantısı çalışmıyor", description: "Yeni bir şifre sıfırlama bağlantısına ihtiyacım var.", category: "technical" },
      "privacy" => { subject: "Şifre bağlantısı ve iletişim bilgileri", description: "Bana sahte@example.com veya 0555 123 45 67 üzerinden ulaşın. Kart 4111 1111 1111 1111.", category: "technical" },
      "critical" => { subject: "Kartımdan iki kez para çekildi", description: "İşlemi iptal edin, aksi halde hakem heyetine başvuracağım.", category: "billing" }
    }.freeze

    def self.call(scenario:, reference: nil, client: nil)
      attributes = SCENARIOS.fetch(scenario)
      reference ||= "WEB-DEMO-#{scenario.upcase}-#{SecureRandom.hex(8)}"
      Intake.call(attributes.merge(external_reference: reference, requester_reference: "sahte-musteri-#{scenario}"), client:)
    rescue KeyError
      raise ArgumentError, "Bilinmeyen agent demo senaryosu."
    end
  end
end
