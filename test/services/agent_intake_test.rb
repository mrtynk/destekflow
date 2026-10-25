require "test_helper"

class AgentIntakeTest < ActiveSupport::TestCase
  class FakeClient
    def initialize(payload)
      @payload = payload
    end

    def response(**)
      JSON.generate(@payload)
    end
  end

  test "düşük riskli bilgi tabanı yanıtını ajan adına yayınlar ve kişiyi maskeler" do
    result = AgentWorkflow::Intake.call(params("agent-safe-001", category: "technical"), client: FakeClient.new({
      priority: "normal", human_required: false, reason: "KB-01 yanıtlıyor",
      suggested_reply: "Yeni bir şifre sıfırlama bağlantısı isteyin.", knowledge_ids: [ "KB-01" ]
    }))

    assert_equal "agent_api", result.ticket.origin
    assert result.ticket.privacy_mode?
    assert_equal "Gizli müşteri", result.ticket.requester_name
    assert_match(/@privacy\.invalid\z/, result.ticket.requester_email)
    assert_equal "auto_reply", result.agent_run.decision
    assert result.agent_run.reply_published?
    assert_equal 1, result.ticket.replies.count
  end

  test "model yanıt yazsa bile yüksek öncelikte kod yayınlamayı engeller" do
    result = AgentWorkflow::Intake.call(params("agent-risk-001", category: "technical"), client: FakeClient.new({
      priority: "high", human_required: false, reason: "Acil risk",
      suggested_reply: "Bu yanıt yayınlanmamalı.", knowledge_ids: [ "KB-01" ]
    }))

    assert_equal "human_handoff", result.agent_run.decision
    refute result.agent_run.reply_published?
    assert_empty result.ticket.replies
    assert_equal "agent_handoff", result.ticket.ticket_events.order(:id).last.event_type
  end

  test "finansal kategoride model güvenli dese bile insan incelemesini zorunlu tutar" do
    result = AgentWorkflow::Intake.call(params("agent-billing-001", category: "billing"), client: FakeClient.new({
      priority: "normal", human_required: false, reason: "Fatura maddesi",
      suggested_reply: "Ödeme tamamdır.", knowledge_ids: [ "KB-02" ]
    }))

    assert_equal "human_handoff", result.agent_run.decision
    assert_empty result.ticket.replies
  end

  test "model güvenli dese bile bilgi tabanı kanıtı yoksa yanıt yayınlamaz" do
    result = AgentWorkflow::Intake.call(params("agent-no-evidence-001", category: "technical"), client: FakeClient.new({
      priority: "normal", human_required: false, reason: "Kanıtsız model önerisi",
      suggested_reply: "Bu yanıt yayınlanmamalı.", knowledge_ids: []
    }))

    assert_equal "human_handoff", result.agent_run.decision
    refute result.agent_run.reply_published?
    assert_empty result.ticket.replies
  end

  test "insan onayı isteyen bilgi maddesi otomatik yanıtı engeller" do
    result = AgentWorkflow::Intake.call(params("agent-kb-human-001", category: "technical"), client: FakeClient.new({
      priority: "normal", human_required: false, reason: "KB-03 hesap erişimi",
      suggested_reply: "Erişim açıldı.", knowledge_ids: [ "KB-03" ]
    }))

    assert_equal "human_handoff", result.agent_run.decision
    assert_empty result.ticket.replies
  end

  test "model çıktısındaki kişisel veriyi de maskeler" do
    result = AgentWorkflow::Intake.call(params("agent-output-pii-001", category: "technical"), client: FakeClient.new({
      priority: "normal", human_required: false, reason: "mert@example.com için KB-01",
      suggested_reply: "0555 123 45 67 numarasını arayın.", knowledge_ids: [ "KB-01" ]
    }))

    refute_includes result.agent_run.reason, "mert@example.com"
    refute_includes result.ticket.replies.first.body, "0555 123"
    assert_includes result.ticket.replies.first.body, "[TELEFON MASKELENDİ]"
  end

  test "aşırı uzun agent girdisini modele göndermeden reddeder" do
    client = Object.new
    client.define_singleton_method(:response) { raise "Model çağrılmamalı" }
    input = params("agent-too-long-001", category: "technical").merge(description: "a" * 4_001)

    assert_no_difference("Ticket.count") do
      assert_raises(ArgumentError) { AgentWorkflow::Intake.call(input, client:) }
    end
  end

  test "aynı dış referansı ikinci kez kayıt oluşturmaz" do
    input = params("agent-idempotent-001", category: "technical")
    client = FakeClient.new({ priority: "normal", human_required: true, reason: "İnsan gerekli", suggested_reply: "", knowledge_ids: [] })

    first = AgentWorkflow::Intake.call(input, client:)
    assert_no_difference("Ticket.count") do
      second = AgentWorkflow::Intake.call(input, client:)
      assert second.duplicate
      assert_equal first.ticket.id, second.ticket.id
    end
  end

  test "kişisel veriyi kaydetmeden ve modele göndermeden maskeler" do
    captured = nil
    client = Object.new
    client.define_singleton_method(:response) do |input:, **|
      captured = input
      JSON.generate(priority: "normal", human_required: true, reason: "İnsan gerekli", suggested_reply: "", knowledge_ids: [])
    end
    input = params("agent-private-001", category: "technical").merge(
      description: "Bana mert@example.com veya 0555 123 45 67 üzerinden ulaşın. Kart 4111 1111 1111 1111."
    )

    result = AgentWorkflow::Intake.call(input, client:)

    refute_includes result.ticket.description, "mert@example.com"
    refute_includes result.ticket.description, "0555 123"
    refute_includes result.ticket.description, "4111 1111"
    refute_includes captured, "mert@example.com"
    assert_includes captured, "[E-POSTA MASKELENDİ]"
  end

  private

  def params(reference, category:)
    {
      external_reference: reference, requester_reference: "customer-42",
      subject: "Şifre bağlantısı çalışmıyor", description: "Yeni bağlantıya ihtiyacım var.", category:
    }
  end
end
