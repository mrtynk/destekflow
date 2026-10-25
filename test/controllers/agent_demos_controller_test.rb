require "test_helper"

class AgentDemosControllerTest < ActionDispatch::IntegrationTest
  test "agent demo merkezi açılır" do
    get agent_demo_path
    assert_response :success
    assert_select "h1", /Agent talebi açar/
    assert_select "form[action='#{run_agent_demo_path(scenario: "safe")}']"
    assert_select "form[action='#{run_agent_demo_path(scenario: "critical")}']"
  end

  test "bilinmeyen senaryo çalıştırılmaz" do
    assert_no_difference("Ticket.count") { post run_agent_demo_path(scenario: "unknown") }
    assert_redirected_to agent_demo_path
  end
end
