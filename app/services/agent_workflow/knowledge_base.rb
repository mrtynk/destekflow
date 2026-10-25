module AgentWorkflow
  class KnowledgeBase
    ARTICLES = [
      { id: "KB-01", title: "Şifre sıfırlama", body: "Şifre sıfırlama bağlantısı 15 dakika geçerlidir. Bağlantı çalışmazsa yeni bağlantı istenmelidir." },
      { id: "KB-02", title: "Fatura görüntüleme", body: "Faturalar Hesabım > Faturalar bölümünden PDF olarak indirilebilir. Ödeme itirazları insan incelemesine aktarılır." },
      { id: "KB-03", title: "Hesap erişimi", body: "E-posta değişikliği ve erişim verme işlemleri kimlik doğrulaması ve insan onayı gerektirir." }
    ].freeze

    def self.context
      ARTICLES.map { |article| "#{article[:id]} — #{article[:title]}: #{article[:body]}" }.join("\n")
    end

    def self.ids
      ARTICLES.pluck(:id)
    end
  end
end
