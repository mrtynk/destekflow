require "test_helper"

class AgentRiskPolicyTest < ActiveSupport::TestCase
  test "finans hukuk ve güvenlik sinyallerini açık nedenlerle döndürür" do
    reasons = AgentWorkflow::RiskPolicy.reasons(
      subject: "Yetkisiz kart işlemi",
      description: "Param çekildi, savcılığa ve hakem heyetine başvuracağım."
    )

    assert_includes reasons, "finansal işlem veya itiraz"
    assert_includes reasons, "hukuki tehdit veya resmî şikâyet"
    assert_includes reasons, "güvenlik veya yetkisiz erişim"
  end

  test "normal şifre sıfırlama talebini kritik saymaz" do
    assert_empty AgentWorkflow::RiskPolicy.reasons(subject: "Şifre bağlantısı", description: "Yeni bağlantı istiyorum")
  end
end
