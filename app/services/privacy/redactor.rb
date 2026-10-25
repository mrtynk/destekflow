module Privacy
  class Redactor
    EMAIL = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
    PHONE = /(?<!\d)(?:\+?90\s?)?(?:0\s?)?5\d{2}[\s.-]?\d{3}[\s.-]?\d{2}[\s.-]?\d{2}(?!\d)/
    CARD = /(?<!\d)(?:\d[ -]?){13,19}(?!\d)/

    def self.call(value)
      value.to_s.gsub(EMAIL, "[E-POSTA MASKELENDİ]")
        .gsub(PHONE, "[TELEFON MASKELENDİ]")
        .gsub(CARD, "[KART MASKELENDİ]")
    end
  end
end
