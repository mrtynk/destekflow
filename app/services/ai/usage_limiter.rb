module Ai
  class UsageLimiter
    class LimitExceeded < StandardError; end

    PROVIDER = "google_gemini"

    def initialize(
      per_minute: Integer(ENV.fetch("GEMINI_REQUESTS_PER_MINUTE", Rails.env.test? ? "10000" : "4"), 10),
      per_day: Integer(ENV.fetch("GEMINI_REQUESTS_PER_DAY", Rails.env.test? ? "10000" : "40"), 10),
      clock: -> { Time.current }
    )
      @per_minute = per_minute
      @per_day = per_day
      @clock = clock
      raise ArgumentError, "Gemini kullanım sınırları pozitif olmalıdır." unless per_minute.positive? && per_day.positive?
    end

    def consume!
      now = @clock.call
      budget = find_budget(now)

      budget.with_lock do
        reset_windows(budget, now)
        raise LimitExceeded, "Gemini dakika kullanım sınırına ulaşıldı; kısa süre sonra yeniden deneyin." if budget.minute_count >= @per_minute
        raise LimitExceeded, "Gemini günlük demo kullanım sınırına ulaşıldı; yarın yeniden deneyin." if budget.day_count >= @per_day

        budget.update!(minute_count: budget.minute_count + 1, day_count: budget.day_count + 1)
      end
    end

    private

    def find_budget(now)
      AiUsageBudget.find_or_create_by!(provider: PROVIDER) do |budget|
        budget.minute_started_at = now
        budget.day_started_on = now.to_date
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def reset_windows(budget, now)
      if budget.minute_started_at <= 1.minute.ago(now)
        budget.minute_started_at = now
        budget.minute_count = 0
      end
      if budget.day_started_on != now.to_date
        budget.day_started_on = now.to_date
        budget.day_count = 0
      end
    end
  end
end
