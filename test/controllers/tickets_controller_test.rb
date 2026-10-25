require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  test "talep listesi ve form ekranı açılır" do
    get tickets_path
    assert_response :success
    assert_select "h1", "Destek talepleri"

    get new_ticket_path
    assert_response :success
    assert_select "form"
  end

  test "müşteri yeni destek talebi oluşturur" do
    assert_difference("Ticket.count", 1) do
      post tickets_path, params: { ticket: { subject: "Yeni sorun", description: "Detay", requester_name: "Mert", requester_email: "mert@example.com", category: "technical", priority: "high" } }
    end
    assert_redirected_to ticket_path(Ticket.last)
    assert_equal 1, Ticket.last.ticket_events.count
  end

  test "önerilen talepler arayüzden ilişkilendirilir ve geri alınır" do
    first = Tickets::Create.call({ subject: "Fatura ekranı boş", description: "Faturayı indirirken boş sayfa görüyorum", requester_name: "A", requester_email: "a@example.com", category: "billing", priority: "high" })
    second = Tickets::Create.call({ subject: "Fatura ekranı açılmıyor", description: "Faturayı indirince boş sayfa görüyorum", requester_name: "B", requester_email: "b@example.com", category: "billing", priority: "normal" })

    get ticket_path(first)
    assert_response :success
    assert_select "h2", "Benzer Talep ve RAG Asistanı"
    assert_select "form[action='#{link_related_ticket_path(first, related_ticket_id: second.id)}']"

    assert_difference("TicketLink.count", 1) do
      post link_related_ticket_path(first), params: { related_ticket_id: second.id }
    end
    link = TicketLink.last
    assert_redirected_to ticket_path(first)

    assert_difference("TicketLink.count", -1) do
      delete unlink_related_ticket_path(first), params: { link_id: link.id }
    end
    assert_redirected_to ticket_path(first)
  end

  test "RAG anahtarı yokken çalışıyor izlenimi vermez ve başarısız denemeyi kaydeder" do
    first = Tickets::Create.call({ subject: "Ödeme sorunu", description: "Kartımdan iki kez çekildi", requester_name: "A", requester_email: "a@example.com", category: "billing", priority: "high" })
    Tickets::Create.call({ subject: "Çift tahsilat", description: "Karttan mükerrer çekim", requester_name: "B", requester_email: "b@example.com", category: "billing", priority: "normal" })

    previous_key = ENV.delete("GEMINI_API_KEY")
    assert_difference("AiAnalysis.count", 1) { post analyze_with_rag_ticket_path(first) }
    assert_redirected_to ticket_path(first)
    assert_equal "failed", first.ai_analyses.last.status
  ensure
    ENV["GEMINI_API_KEY"] = previous_key if previous_key
  end

  test "başka talebe ait ilişki idsiyle geri alma reddedilir" do
    first = Tickets::Create.call({ subject: "Bir", description: "Birinci kayıt", requester_name: "A", requester_email: "a@example.com", category: "other", priority: "normal" })
    second = Tickets::Create.call({ subject: "İki", description: "İkinci kayıt", requester_name: "B", requester_email: "b@example.com", category: "other", priority: "normal" })
    third = Tickets::Create.call({ subject: "Üç", description: "Üçüncü kayıt", requester_name: "C", requester_email: "c@example.com", category: "other", priority: "normal" })
    link = Tickets::Link.call(ticket: second, related_ticket: third)

    assert_no_difference("TicketLink.count") do
      delete unlink_related_ticket_path(first), params: { link_id: link.id }
    end
    assert_response :not_found
  end
end
