require "test_helper"

class ApprovalWorkflowTest < ActiveSupport::TestCase
  def setup
    @ticket = Tickets::Create.call({
      subject: "İade onayı",
      description: "Yüksek tutarlı iade için karar gerekiyor",
      requester_name: "Deniz",
      requester_email: "deniz@example.com",
      category: "billing",
      priority: "high"
    })
  end

  test "onay oluşturulur ve kritik işlem insan kararına kadar uygulanmaz" do
    approval = request_approval

    assert_equal "requested", approval.status
    assert_nil approval.decided_at
    assert_equal [ "requested" ], approval.approval_events.pluck(:event_type)
    assert_equal "new", @ticket.reload.status
  end

  test "bekleyen onay insan tarafından onaylanır" do
    approval = request_approval
    Approvals::Decide.call(approval_request: approval, decision: "approved", actor_name: "Takım Lideri")

    assert_equal "approved", approval.reload.status
    assert_equal "Takım Lideri", approval.decided_by
    assert approval.decided_at.present?
    assert_equal %w[requested approved], approval.approval_events.order(:id).pluck(:event_type)
  end

  test "bekleyen onay insan tarafından reddedilir" do
    approval = request_approval
    Approvals::Decide.call(approval_request: approval, decision: "rejected", actor_name: "Takım Lideri")

    assert_equal "rejected", approval.reload.status
    assert_equal %w[requested rejected], approval.approval_events.order(:id).pluck(:event_type)
  end

  test "sonuçlanmış onay ikinci kez sonuçlandırılamaz" do
    approval = request_approval
    Approvals::Decide.call(approval_request: approval, decision: "approved", actor_name: "Birinci karar verici")

    assert_raises(Approvals::Decide::InvalidTransition) do
      Approvals::Decide.call(approval_request: approval, decision: "rejected", actor_name: "İkinci karar verici")
    end
    assert_equal "approved", approval.reload.status
    assert_equal 1, approval.approval_events.where(event_type: %w[approved rejected]).count
  end

  test "tanımsız durum geçişi engellenir" do
    approval = request_approval

    assert_raises(Approvals::Decide::InvalidTransition) do
      Approvals::Decide.call(approval_request: approval, decision: "escalated", actor_name: "Kişi")
    end
    assert_equal "requested", approval.reload.status
  end

  private

  def request_approval
    Approvals::Request.call(
      ticket: @ticket,
      reason: "5000 TL üzeri iade",
      requested_action: "refund",
      decision_owner: "Takım Lideri",
      requested_by: "Demo temsilci"
    )
  end
end
