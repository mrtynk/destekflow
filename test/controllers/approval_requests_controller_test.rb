require "test_helper"

class ApprovalRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket = Tickets::Create.call({
      subject: "Demo onayı",
      description: "Arayüz akışı",
      requester_name: "Mert",
      requester_email: "mert@example.com",
      category: "billing",
      priority: "high"
    })
  end

  test "onay kuyruğu demo ve cron sınırını açıkça gösterir" do
    get approval_requests_path

    assert_response :success
    assert_select "h1", "Onay Kuyruğu"
    assert_select ".demo-warning", /auth\/RBAC/
    assert_select ".demo-warning", /cron\/worker kurulmuş değildir/
  end

  test "talep ekranından onay istenir ve insan kararı verilir" do
    assert_difference("ApprovalRequest.count", 1) do
      post approval_requests_path, params: {
        ticket_id: @ticket.id,
        reason: "İade limiti aşıldı",
        requested_action: "refund",
        decision_owner: "Takım Lideri"
      }
    end
    approval = ApprovalRequest.last
    assert_redirected_to approval_requests_path(anchor: "approval-#{approval.id}")

    post approve_approval_request_path(approval)
    assert_redirected_to approval_requests_path(anchor: "approval-#{approval.id}")
    assert_equal "approved", approval.reload.status
  end
end
