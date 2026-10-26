minutes = Integer(ENV.fetch("APPROVAL_ESCALATION_MINUTES", "30"), 10)
raise "APPROVAL_ESCALATION_MINUTES pozitif olmalıdır" unless minutes.positive?

Rails.application.config.x.approvals.escalation_threshold = minutes.minutes
Rails.application.config.x.approvals.escalation_owner = ENV.fetch("APPROVAL_ESCALATION_OWNER", "Üst Yetkili Demo Kuyruğu")
Rails.application.config.x.agent_api_token = ENV["AGENT_API_TOKEN"]
Rails.application.config.x.public_demo_read_only = ActiveModel::Type::Boolean.new.cast(
  ENV.fetch("PUBLIC_DEMO_READ_ONLY", Rails.env.production?.to_s)
)
