require "test_helper"

class RagSimilarityTest < ActiveSupport::TestCase
  FakeClient = Struct.new(:vectors, :generated_text, :embedded_inputs, :generation_input, keyword_init: true) do
    def embeddings(inputs:, model:)
      self.embedded_inputs = inputs
      vectors
    end

    def response(input:, instructions:, model:)
      self.generation_input = input
      generated_text
    end
  end

  test "embedding ile getirilen kayıtları gerçek RAG kanıtıyla kaydeder" do
    source = create_ticket(subject: "Kartımdan iki kez ödeme alındı", description: "Aynı sipariş için çift çekim var", email: "kaynak@example.com")
    similar = create_ticket(subject: "Mükerrer kart tahsilatı", description: "Sipariş bedeli karttan iki defa çekilmiş", email: "gizli@example.com")
    unrelated = create_ticket(subject: "Şifre sıfırlama", description: "Hesabıma giremiyorum", email: "diger@example.com")
    client = FakeClient.new(
      # Servis en yeni adayı önce işler: unrelated, ardından similar.
      vectors: [ [ 1.0, 0.0 ], [ 0.0, 1.0 ], [ 0.92, 0.08 ] ],
      generated_text: "İki kayıt aynı ödeme sürtünmesini anlatıyor; kesin mükerrer kararı insanındır."
    )

    result = Tickets::RagSimilarity.call(source, candidates: Ticket.where(id: [ similar.id, unrelated.id ]), client:)

    assert_equal [ similar ], result.matches.map(&:ticket)
    assert result.analysis.completed?
    assert_equal similar.id, result.analysis.retrieval_evidence.first.fetch("ticket_id")
    assert_not_includes client.embedded_inputs.join, "gizli@example.com"
    assert_not_includes client.generation_input, "gizli@example.com"
    assert_includes result.analysis.answer, "insanındır"
  end

  test "api hatasını başarısız ve denetlenebilir analiz olarak kaydeder" do
    source = create_ticket(subject: "Ödeme sorunu", description: "Tahsilat görünmüyor")
    other = create_ticket(subject: "Başka ödeme", description: "Kart çekimi eksik", email: "b@example.com")
    failing_client = Object.new
    failing_client.define_singleton_method(:embeddings) { |**| raise Ai::GeminiClient::Error, "servis kullanılamıyor" }

    assert_raises(Ai::GeminiClient::Error) do
      Tickets::RagSimilarity.call(source, candidates: Ticket.where(id: other.id), client: failing_client)
    end
    assert_equal "failed", source.ai_analyses.last.status
    assert_equal "servis kullanılamıyor", source.ai_analyses.last.error_code
  end

  private

  def create_ticket(subject:, description:, email: "demo@example.com")
    Tickets::Create.call({ subject:, description:, requester_name: "Demo", requester_email: email, category: "technical", priority: "normal" })
  end
end
