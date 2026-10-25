require "test_helper"

class AgentTriageTest < ActiveSupport::TestCase
  class FakeClient
    def initialize(payload)
      @payload = payload
    end

    def response(**)
      JSON.generate(@payload)
    end
  end

  test "human required alanında boolean dışında değeri reddeder" do
    client = FakeClient.new(priority: "normal", human_required: "false", reason: "Yanlış tip", suggested_reply: "Yanıt", knowledge_ids: [ "KB-01" ])

    assert_raises(Ai::GeminiClient::Error) do
      AgentWorkflow::Triage.call(subject: "Şifre sorunu", description: "Bağlantı çalışmıyor", client:)
    end
  end

  test "boş gerekçeyi reddeder" do
    client = FakeClient.new(priority: "normal", human_required: false, reason: " ", suggested_reply: "Yanıt", knowledge_ids: [ "KB-01" ])

    assert_raises(Ai::GeminiClient::Error) do
      AgentWorkflow::Triage.call(subject: "Şifre sorunu", description: "Bağlantı çalışmıyor", client:)
    end
  end
end
