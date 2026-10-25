require "test_helper"

class ApprovalConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    ApprovalEvent.delete_all
    ApprovalRequest.delete_all
    TicketEvent.delete_all
    Ticket.delete_all
  end

  teardown do
    ApprovalEvent.delete_all
    ApprovalRequest.delete_all
    TicketEvent.delete_all
    Ticket.delete_all
  end

  test "eşzamanlı iki karar yalnızca bir kez sonuçlandırır" do
    ticket = Tickets::Create.call({
      subject: "Yarış testi",
      description: "Aynı onaya iki karar geliyor",
      requester_name: "Test",
      requester_email: "race@example.com",
      category: "other",
      priority: "normal"
    })
    approval = Approvals::Request.call(
      ticket:,
      reason: "Kritik işlem",
      requested_action: "close_ticket",
      decision_owner: "Takım Lideri",
      requested_by: "Demo agent"
    )
    gate = Queue.new
    results = %w[approved rejected].map do |decision|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          gate.pop
          Approvals::Decide.call(approval_request: ApprovalRequest.find(approval.id), decision:, actor_name: decision)
          :success
        rescue Approvals::Decide::InvalidTransition
          :blocked
        end
      end
    end
    2.times { gate << true }

    outcomes = results.map(&:value)
    assert_equal 1, outcomes.count(:success)
    assert_equal 1, outcomes.count(:blocked)
    assert_includes %w[approved rejected], approval.reload.status
    assert_equal 1, approval.approval_events.where(event_type: %w[approved rejected]).count
  end
end
