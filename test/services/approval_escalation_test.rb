require "test_helper"

class ApprovalEscalationTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @ticket = Tickets::Create.call({
      subject: "Erişim isteği",
      description: "Yönetici onayı gerekiyor",
      requester_name: "Ece",
      requester_email: "ece@example.com",
      category: "account",
      priority: "normal"
    })
  end

  test "30 dakika dolmadan eskalasyon yapılmaz" do
    travel_to Time.zone.local(2026, 10, 25, 10, 0)
    @approval = request_approval

    travel_to Time.zone.local(2026, 10, 25, 10, 29, 59)
    assert_empty Approvals::EscalateOverdue.call
    assert_equal "requested", @approval.reload.status
  end

  test "30 dakika dolunca bir kez eskale edilir ve sonrasında onaylanabilir" do
    travel_to Time.zone.local(2026, 10, 25, 10, 0)
    @approval = request_approval

    travel_to Time.zone.local(2026, 10, 25, 10, 30)
    assert_equal [ @approval ], Approvals::EscalateOverdue.call
    assert_empty Approvals::EscalateOverdue.call
    assert_equal "escalated", @approval.reload.status
    assert_equal 1, @approval.approval_events.where(event_type: "escalated").count

    Approvals::Decide.call(approval_request: @approval, decision: "approved", actor_name: "Üst Yetkili")
    assert_equal "approved", @approval.reload.status
  end

  test "eskale edilen onay insan tarafından reddedilebilir" do
    travel_to Time.zone.local(2026, 10, 25, 10, 0)
    @approval = request_approval

    travel_to Time.zone.local(2026, 10, 25, 10, 31)
    Approvals::EscalateOverdue.call
    Approvals::Decide.call(approval_request: @approval, decision: "rejected", actor_name: "Üst Yetkili")
    assert_equal "rejected", @approval.reload.status
  end

  private

  def request_approval
    Approvals::Request.call(
      ticket: @ticket,
      reason: "Yetkili incelemesi",
      requested_action: "grant_access",
      decision_owner: "Takım Lideri",
      requested_by: "Demo temsilci"
    )
  end
end
