require "test_helper"

class AgentDemoTest < ActiveSupport::TestCase
  class FakeClient
    def response(**)
      JSON.generate(priority: "normal", human_required: false, reason: "KB-01 yeterli", suggested_reply: "Yeni bağlantı isteyin.", knowledge_ids: [ "KB-01" ])
    end
  end

  test "sabit sahte senaryoyu agent intake akışına taşır" do
    result = AgentWorkflow::Demo.call(scenario: "safe", reference: "WEB-DEMO-SAFE-TEST", client: FakeClient.new)
    assert_equal "agent_api", result.ticket.origin
    assert result.ticket.privacy_mode?
    assert result.agent_run.reply_published?
  end

  test "aynı demo referansı ikinci talebi oluşturmaz" do
    reference = "WEB-DEMO-SAFE-IDEMPOTENT"
    AgentWorkflow::Demo.call(scenario: "safe", reference:, client: FakeClient.new)
    assert_no_difference("Ticket.count") do
      result = AgentWorkflow::Demo.call(scenario: "safe", reference:, client: FakeClient.new)
      assert result.duplicate
    end
  end

  test "bilinmeyen senaryo reddedilir" do
    assert_raises(ArgumentError) { AgentWorkflow::Demo.call(scenario: "unknown", client: FakeClient.new) }
  end
end
