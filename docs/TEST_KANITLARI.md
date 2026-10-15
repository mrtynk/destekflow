# Test Kanıtları

## Yerel koşu

- Tarih: 15 Ekim 2026
- Komut: `bundle exec rails test`
- Sonuç: `18 runs, 77 assertions, 0 failures, 0 errors, 0 skips`
- Son yeniden koşu: 15 Ekim 2026; yeni migration test veritabanına uygulandıktan sonra tam paket başarıyla tamamlandı.
- Autoload denetimi: `bundle exec rails zeitwerk:check` sonucu `All is good!`

Kapsanan davranışlar: önceki ana akış ve zaman/durum kurallarına ek olarak benzer başlık/açıklama, farklı e-posta, ilgisiz kayıt, deterministik Türkçe puan, ilişkilendirme, yinelenen çiftin reddi, geri alma, iki taraflı işlem geçmişi ve SLA/durum korunumu.

## GitHub Actions

- Depo: [mrtynk/destekflow](https://github.com/mrtynk/destekflow)
- Başarılı koşu: [CI #38714995821](https://github.com/mrtynk/destekflow/actions/runs/38714995821)
- Sonuç: lint, Brakeman, bundler-audit, importmap audit, Rails test ve system-test job'larının tamamı başarılı.

Yeni özelliğin commit'ine ait CI koşusu push sonrasında ayrıca doğrulanacaktır; yukarıdaki eski koşu yeni kodun kanıtı olarak sunulmaz.

## Render canlı doğrulaması

- Canlı URL: [https://destekflow.onrender.com](https://destekflow.onrender.com)
- Sağlık kontrolü: `GET /up` → HTTP 200
- Runtime: Rails 8.1.4, Ruby 3.4.7, PostgreSQL 17
- Test kaydı: #2 `Canlı ortam SLA doğrulaması`
- Doğrulanan akış: yüksek öncelikli talep oluşturma → Mehmet Kaya'ya atama → temsilci yanıtı → çözüldü durumuna geçiş → işlem geçmişini kontrol etme.
- İşlem geçmişi: oluşturma, atama, otomatik `new → open`, temsilci yanıtı ve `open → solved` olayları görüntülendi.
- SLA asistanı: aktif yüksek öncelikli talebi ilk sıraya aldı ve kalan ilk yanıt süresini gerekçesiyle gösterdi; çözülen test talebini öneri listesinden çıkardı.
- Görsel kontrol: 1440×900 masaüstü ve 390×844 mobil viewport'larda yatay taşma görülmedi; ana başlık, yeni talep eylemi ve SLA asistanı görünürdü.

### 503 sonrası bağımsız tekrar kontrolü

- Tarih: 15 Ekim 2026
- Render durumu: `Live`; Puma iki worker ile production modunda `0.0.0.0:10000` üzerinde çalışıyor.
- HTTP ölçümü: `/up` 200 (0,337 sn), `/` 200 (0,349 sn), `/tickets` 200 (0,291 sn).
- PostgreSQL kanıtı: Render uygulama logunda ana sayfa isteği `ActiveRecord: 45.3ms (2 queries)` ile 200 tamamlandı; bağlantı hatası görülmedi.
- Tekrar E2E kaydı: #3 `503 sonrası canlı doğrulama`; oluşturuldu, Mehmet Kaya'ya atandı, yanıtlandı, çözüldü ve beş işlem geçmişi olayı görüldü.
- Değerlendirme: gözlenen 503 kalıcı deploy/veritabanı hatası değil, ücretsiz instance'ın uyku/uyanma davranışıyla uyumlu geçici kullanılabilirlik olayıdır.

### Son teslim denetimi tekrar kontrolü

- Tarih: 15 Ekim 2026
- Ücretsiz instance uyandırıldıktan sonra gerçek HTTP sonuçları: `/up` 200 (18,696 sn), `/` 200 (21,508 sn), `/tickets` 200 (20,820 sn).
- Masaüstü tarayıcı erişilebilirlik ağacında talep listesi, yeni talep bağlantısı, durum/öncelik filtreleri ve Akıllı SLA Öncelik Asistanı birlikte görüntülendi.

## 85 puan kontrolü

| Koşul | Durum | Kanıt |
|---|---|---|
| Fortune 500 + Faz 1/Faz 2 | Karşılandı; değerleme aralığının veri sınırı açık | README araştırma tabloları ve Stanley Black & Decker SEC kaynağı |
| Canlı aort dilimi | Karşılandı | Render URL'sinde #2 ve #3 uçtan uca akışları |
| GitHub Actions ve rozet | Karşılandı | README rozeti ve başarılı Actions koşuları |
| Zaman ve durum testleri | Karşılandı | `ticket_test.rb`: 4 `travel_to`, üç zaman kuralı ve yasak geçiş |
| AGENT.md | Karşılandı | İlk sürüm `ce6cb13`, güncel rehber depoda |
| README Yapamadıklarım | Karşılandı | Cron, ücretsiz uyku, değerleme, G2–G4 ve auth sınırları açık |

100+ adayı olan SLA Asistanı, Capterra'daki Hadi B.'nin Zendesk Explore özel metrikleri ve hesaplanan öznitelikleri için belirttiği öğrenme eğrisiyle ilişkilidir. Çözüm, tam analitik ürün iddiası taşımadan, “önce hangi aktif talep?” kararı için ayrı metrik/formül/pano kurulumu istemez; SLA riskiyle sıralar ve Türkçe gerekçe verir.

İkinci aday, Eleanor T.'nin farklı e-posta/cihazla yinelenen talepler ve geri alınamayan yanlış birleştirme şikâyetinden türetilen Geri Alınabilir Benzer Talep Asistanı'dır. Zendesk'in zaten öneri sunduğu kabul edilir; fark, puan/ortak terim açıklamasıyla iki kaydı koruyan ve geri alınabilen bağlantıdır.

## Dürüst sınırlar

Windows libvips kurulumu uygulamanın kullanmadığı HEIF/JXL/Imagemagick/OpenSlide/Poppler modülleri için uyarı verdi. Test süreci 0 koduyla bitti ve yukarıdaki sonuçları üretti. Ücretsiz Render planında cron servisi oluşturulmadığı için 48 saatlik otomatik kapanış job'ı canlı zamanlayıcıyla gözlenmedi; davranış otomatik testlerle doğrulandı.
