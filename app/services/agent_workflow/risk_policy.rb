module AgentWorkflow
  class RiskPolicy
    RULES = {
      "finansal işlem veya itiraz" => /kart(?:ım)?|para çek|ödeme|iade|tahsil|borç|fatura itiraz/i,
      "hukuki tehdit veya resmî şikâyet" => /hakem heyet|mahkeme|dava|avukat|hukuk|savcılık|şikâyet edece/i,
      "güvenlik veya yetkisiz erişim" => /dolandır|çalınd|hack|ele geçir|yetkisiz|kimlik|hesap eriş|erişim ver/i
    }.freeze

    def self.reasons(subject:, description:)
      text = "#{subject}\n#{description}"
      RULES.filter_map { |label, pattern| label if text.match?(pattern) }
    end
  end
end
