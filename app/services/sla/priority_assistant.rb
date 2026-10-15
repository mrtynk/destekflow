module Sla
  class PriorityAssistant
    Result = Data.define(:ticket, :score, :reason)

    def self.call(tickets, at: Time.current)
      tickets.select(&:active?).map do |ticket|
        remaining = ticket.sla_due_at - at
        score = remaining <= 0 ? 10_000 : (ticket.priority == "high" ? 2_000 : 1_000) - remaining / 60
        reason = if remaining <= 0
          "İlk yanıt SLA'sı aşıldı; hemen ele alınmalı."
        elsif ticket.first_responded_at.present?
          "İlk yanıt verildi; aktif talepler içinde takip edilmeli."
        else
          "İlk yanıta #{distance_in_words(remaining)} kaldı; #{ticket.priority == 'high' ? 'yüksek' : 'normal'} öncelik."
        end
        Result.new(ticket:, score:, reason:)
      end.sort_by { |result| -result.score }
    end

    def self.distance_in_words(seconds)
      minutes = [ (seconds / 60).ceil, 0 ].max
      minutes < 60 ? "#{minutes} dakika" : "#{(minutes / 60.0).round(1)} saat"
    end
    private_class_method :distance_in_words
  end
end
