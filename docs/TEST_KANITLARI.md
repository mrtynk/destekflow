# Test Kanıtları

## Onay ve eskalasyon paketi — 25 Ekim 2026

- Tam komut: `bundle exec rails test`
- Sonuç: `32 runs, 136 assertions, 0 failures, 0 errors, 0 skips`
- Kapsam: onay oluşturma/onay/red; terminal durumdan yasak geçiş; 30 dakika öncesi ve sonrası `travel_to`; idempotent eskalasyon; eskalasyon sonrası insan kararı; PostgreSQL satır kilidiyle eşzamanlı iki kararın yalnız birinin kabulü; token korumalı agent API; geçersiz işlem doğrulaması; eski talep akışlarının regresyonu.
- RuboCop: 65 dosya, 0 ihlal.
- Brakeman: 0 güvenlik uyarısı.
- Bundler Audit: ilk koşuda `crass 1.0.7` açığı bulundu; `1.0.8` güncellemesinden sonra `No vulnerabilities found`.
- Importmap audit: `No vulnerable packages found`.
- Zeitwerk: `All is good!`.
- `rails test:system`: başarılı komut, fakat sistem test dosyası olmadığı için `0 runs`; sistem testi varmış gibi sunulmaz.
- Bu sürüm henüz push edilmediği için GitHub Actions sonucu; deploy edilmediği için Render/canlı uçtan uca kanıtı yoktur.

### TASK 17 yayın öncesi tekrar doğrulaması

- Tam paket: `37 runs, 158 assertions, 0 failures, 0 errors, 0 skips`.
- Yeni güvenlik testleri: production benzeri site korumasında kimliksiz/yanlış erişim 401; eksik secret yapılandırması 503; doğru HTTP Basic erişimi 200; eksik/zayıf agent tokenı 503; tokensız agent çağrısı 401.
- Production asset build: başarılı (`application-5915d808.css` üretildi, ardından yerel build artığı temizlendi).
- Test PostgreSQL migration durumu: `20261015090000`, `20261015190000`, `20261025120000` kayıtlarının tamamı `up`.
- RuboCop: 66 dosya, 0 ihlal. Brakeman: 0 uyarı. Bundler Audit ve importmap audit: açık yok. Zeitwerk: `All is good!`.
- GitHub Actions ve Render sonucu hâlâ yoktur; push/deploy yapılmamıştır.

## Yerel koşu

- Tarih: 15 Ekim 2026
- Komut: `bundle exec rails test`
- Sonuç: `18 runs, 77 assertions, 0 failures, 0 errors, 0 skips`
- Son yeniden koşu: 15 Ekim 2026; yeni migration test veritabanına uygulandıktan sonra tam paket başarıyla tamamlandı.
- Autoload denetimi: `bundle exec rails zeitwerk:check` sonucu `All is good!`

Kapsanan davranışlar: önceki ana akış ve zaman/durum kurallarına ek olarak benzer başlık/açıklama, farklı e-posta, ilgisiz kayıt, deterministik Türkçe puan, ilişkilendirme, yinelenen çiftin reddi, geri alma, iki taraflı işlem geçmişi ve SLA/durum korunumu.

## GitHub Actions

- Depo: [mrtynk/destekflow](https://github.com/mrtynk/destekflow)
- Yeni özellik commit'i için başarılı koşu: [CI #38773363080](https://github.com/mrtynk/destekflow/actions/runs/38773363080)
- Sonuç: lint, Brakeman, bundler-audit, importmap audit, Rails test ve system-test job'larının tamamı başarılı.

Yeni özellik commit'i `e373bb7` için `test`, `system-test`, `lint`, `scan_ruby` ve `scan_js` job'ları başarıyla tamamlandı.

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

### Geri alınabilir benzer talep canlı testi

- Tarih: 16 Ekim 2026; Render kaynak commit'i `e373bb7`, deploy durumu `Live`, `/up` HTTP 200 (0,309 sn).
- PostgreSQL migration logu: `CreateTicketLinks` başarıyla tamamlandı; build ve iç sağlık kontrolü geçti.
- #4 ve #5 farklı `.example` e-postalı sahte kayıtlar %73 benzerlik ve sekiz ortak terimle önerildi; e-posta puana katılmadı.
- İlişkilendirme iki detay ekranında da göründü. Her kayıt `Yeni/Normal` kaldı, ayrı 24 saatlik SLA zamanı ve kendi geçmişi korundu.
- İlişki geri alındı; iki kayıt kaldı, öneri yeniden belirdi ve `ilişkilendirildi` ile `ilişki geri alındı` olayları geçmişte görüntülendi.
- Yeni deploy altında eski #2 kaydının Mehmet Kaya ataması, yanıtı, çözüldü durumu ve beş olaylı ana akışı da korundu.

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

## RAG ve arayüz yenilemesi — 25 Ekim 2026

- Tam Rails paketi: `40 runs, 176 assertions, 0 failures, 0 errors, 0 skips`.
- Sahte API istemcili RAG testi gerçek orkestrasyonu doğrular: embedding sırası, cosine retrieval, eşik/ilk üç seçimi, getirilen kaydın üretim bağlamına verilmesi ve `AiAnalysis` denetim kaydı.
- Gizlilik testi, aday e-posta adresinin embedding girdisine ve üretim girdisine eklenmediğini doğrular.
- Hata testi, API hatasının başarılı sonuç gibi gösterilmediğini ve `failed` denetim kaydı oluşturduğunu doğrular.
- Anahtarsız controller testi, isteğin kullanıcıya hata dönerek güvenli kapanmasını doğrular.
- Yerel masaüstü tarayıcı incelemesinde ana ekran, metrik kartları, filtreler, SLA asistanı ve talep detay düzeni yatay taşma olmadan görüntülendi.
- Gerçek OpenAI ağına çağrı yapılmadı; ücretli/gizli anahtar kullanılmadı. Bu nedenle gerçek model kalitesi ve canlı Render RAG akışı henüz doğrulanmadı.
