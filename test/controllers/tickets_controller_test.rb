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
end
