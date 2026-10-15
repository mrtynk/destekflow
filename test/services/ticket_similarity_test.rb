require "test_helper"

class TicketSimilarityTest < ActiveSupport::TestCase
  test "benzer başlık ve açıklamayı farklı e-postalarda açıklanabilir biçimde önerir" do
    source = create_ticket(subject: "Fatura ekranı boş", description: "Son faturayı indirirken boş sayfa görüyorum", email: "bir@example.com")
    similar = create_ticket(subject: "Fatura ekranı açılmıyor", description: "Faturayı indirince boş sayfa görüyorum", email: "iki@example.com")

    result = Tickets::Similarity.call(source, candidates: Ticket.where(id: similar.id)).sole

    assert_equal similar, result.ticket
    assert_operator result.score, :>=, Tickets::Similarity::THRESHOLD
    assert_includes result.matched_terms, "fatura"
    assert_includes result.matched_terms, "bos"
    assert_not_equal source.requester_email, similar.requester_email
  end

  test "ilgisiz talepleri önermez" do
    source = create_ticket(subject: "Fatura ekranı boş", description: "Faturayı indiremiyorum")
    unrelated = create_ticket(subject: "Şifre yenileme", description: "Hesabıma giriş yapamıyorum", email: "baska@example.com")

    assert_empty Tickets::Similarity.call(source, candidates: Ticket.where(id: unrelated.id))
  end

  test "benzerlik puanı deterministiktir ve Türkçe karakterleri normalleştirir" do
    source = create_ticket(subject: "Ödeme çöktü", description: "Ödeme ekranı açılmıyor")
    similar = create_ticket(subject: "Odeme coktu", description: "Odeme ekrani acilmiyor", email: "baska@example.com")

    first = Tickets::Similarity.call(source, candidates: Ticket.where(id: similar.id)).sole
    second = Tickets::Similarity.call(source, candidates: Ticket.where(id: similar.id)).sole

    assert_equal 100, first.score
    assert_equal first.score, second.score
    assert_equal %w[acilmiyor coktu ekrani odeme], first.matched_terms
  end

  private

  def create_ticket(subject:, description:, email: "musteri@example.com")
    Tickets::Create.call({ subject:, description:, requester_name: "Demo", requester_email: email, category: "technical", priority: "normal" })
  end
end
