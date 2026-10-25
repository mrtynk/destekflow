module AgentWorkflow
  class KnowledgeBase
    ARTICLES = [
      { id: "KB-01", auto_reply: true, title: "Şifre sıfırlama", body: "Şifre sıfırlama bağlantısı 15 dakika geçerlidir. Bağlantı çalışmazsa yeni bağlantı istenmelidir." },
      { id: "KB-02", auto_reply: false, title: "Fatura görüntüleme", body: "Faturalar Hesabım > Faturalar bölümünden PDF olarak indirilebilir. Ödeme itirazları insan incelemesine aktarılır." },
      { id: "KB-03", auto_reply: false, title: "Hesap erişimi", body: "E-posta değişikliği ve erişim verme işlemleri kimlik doğrulaması ve insan onayı gerektirir." }
    ].freeze

    def self.context
      ARTICLES.map { |article| "#{article[:id]} — #{article[:title]}: #{article[:body]}" }.join("\n")
    end

    def self.ids
      ARTICLES.pluck(:id)
    end

    def self.auto_reply_ids
      ARTICLES.select { |article| article[:auto_reply] }.pluck(:id)
    end
  end
end
