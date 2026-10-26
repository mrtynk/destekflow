require "test_helper"

class AiUsageLimiterTest < ActiveSupport::TestCase
  setup { AiUsageBudget.delete_all }

  test "dakika sınırını aşan Gemini isteğini reddeder" do
    now = Time.zone.parse("2026-10-26 10:00:00")
    limiter = Ai::UsageLimiter.new(per_minute: 2, per_day: 10, clock: -> { now })

    2.times { limiter.consume! }
    error = assert_raises(Ai::UsageLimiter::LimitExceeded) { limiter.consume! }

    assert_match(/dakika kullanım sınırına/, error.message)
    assert_equal 2, AiUsageBudget.find_by!(provider: "google_gemini").day_count
  end

  test "dakika penceresi yenilenir ama günlük bütçe korunur" do
    now = Time.zone.parse("2026-10-26 10:00:00")
    limiter = Ai::UsageLimiter.new(per_minute: 1, per_day: 2, clock: -> { now })
    limiter.consume!

    now += 61.seconds
    limiter.consume!
    now += 61.seconds

    assert_raises(Ai::UsageLimiter::LimitExceeded) { limiter.consume! }
  end
end
