# Test Kanıtları

## Yerel koşu

- Tarih: 15 Ekim 2026
- Komut: `bundle exec rails test`
- Sonuç: `9 runs, 29 assertions, 0 failures, 0 errors, 0 skips`
- Autoload denetimi: `bundle exec rails zeitwerk:check` sonucu `All is good!`

Kapsanan davranışlar: talep oluşturma, liste/form render, atama, yanıt, çözme, işlem geçmişi, yasak geçiş, yüksek öncelik 4 saat, normal öncelik 24 saat, SLA ihlali, 48 saat kapanış ve SLA Öncelik Asistanı.

## GitHub Actions

- Depo: [mrtynk/destekflow](https://github.com/mrtynk/destekflow)
- Başarılı koşu: [CI #38714995821](https://github.com/mrtynk/destekflow/actions/runs/38714995821)
- Sonuç: lint, Brakeman, bundler-audit, importmap audit, Rails test ve system-test job'larının tamamı başarılı.

## Render canlı doğrulaması

- Canlı URL: [https://destekflow.onrender.com](https://destekflow.onrender.com)
- Sağlık kontrolü: `GET /up` → HTTP 200
- Runtime: Rails 8.1.4, Ruby 3.4.7, PostgreSQL 17
- Test kaydı: #2 `Canlı ortam SLA doğrulaması`
- Doğrulanan akış: yüksek öncelikli talep oluşturma → Mehmet Kaya'ya atama → temsilci yanıtı → çözüldü durumuna geçiş → işlem geçmişini kontrol etme.
- İşlem geçmişi: oluşturma, atama, otomatik `new → open`, temsilci yanıtı ve `open → solved` olayları görüntülendi.
- SLA asistanı: aktif yüksek öncelikli talebi ilk sıraya aldı ve kalan ilk yanıt süresini gerekçesiyle gösterdi; çözülen test talebini öneri listesinden çıkardı.
- Görsel kontrol: 1440×900 masaüstü ve 390×844 mobil viewport'larda yatay taşma görülmedi; ana başlık, yeni talep eylemi ve SLA asistanı görünürdü.

## Dürüst sınırlar

Windows libvips kurulumu uygulamanın kullanmadığı HEIF/JXL/Imagemagick/OpenSlide/Poppler modülleri için uyarı verdi. Test süreci 0 koduyla bitti ve yukarıdaki sonuçları üretti. Ücretsiz Render planında cron servisi oluşturulmadığı için 48 saatlik otomatik kapanış job'ı canlı zamanlayıcıyla gözlenmedi; davranış otomatik testlerle doğrulandı.
