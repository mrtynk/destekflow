module Sla
  class DeadlineCalculator
    DURATIONS = { "high" => 4.hours, "normal" => 24.hours }.freeze

    def self.call(priority:, started_at: Time.current)
      started_at + DURATIONS.fetch(priority)
    end
  end
end
