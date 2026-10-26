# CHALLENGE_LOG

## Başlangıç noktası

Doğrulanan başlangıç HEAD'i [`7e8c6b1`](https://github.com/mrtynk/destekflow/commit/7e8c6b1224c8f6febccda495cd79fe23a7a43e3a) (`Son teslim testlerini dogrula`) idi. Başlangıçta DestekFlow; talep oluşturma, atama, yanıtlama, durum geçişi, SLA önceliklendirme ve geri alınabilir benzer talep ilişkilendirme akışlarını içeriyordu. Onay talebi veya eskalasyon modeli yoktu.

Bu challenge için verilen gerçek hedef cümlesi aynen şöyledir:

> "Onay/eskalasyon akışının uçtan uca simülasyonunu hazırla."

Bunun dışında daha eski bir “ilk prompt” proje dosyalarından doğrulanamamıştır; uydurulmamıştır.

## Acı

Zendesk topluluğundaki Nayden11 adlı kullanıcı, mevcut onay akışının katılığını; bekleyen durumda genel yanıtları sınırlayamama, tek aktif istek sınırı ve otomatik sıralı onay zinciri eksikliği nedeniyle manuel yük doğmasıyla açıklıyor. Kaynak: [Zendesk Community — Agent Workspace Restrictions and Workflow Flexibility for Approval Requests](https://community.zendesk.com/ideas/product-feedback-agent-workspace-restrictions-and-workflow-flexibility-for-approval-requests-5556).

Zendesk'in resmî dokümanı onayların yetkili insana gönderildiğini, kararın kaydedildiğini ve API/action flow yoluyla da onay açılabildiğini doğruluyor: [Understanding approvals and how they work](https://support.zendesk.com/hc/en-us/articles/8481179038490-Understanding-approvals-and-how-they-work). DestekFlow'un bu haftaki dar problemi, agent önerisinin kritik işlemi doğrudan uygulamaması; geciken kararın görünür ve tekrar etmeyen biçimde üst kuyruğa taşınmasıdır.

## Bu haftanın vaadi

Bir talebe gerekçeli onay isteği eklemek; 30 dakika bekleyen isteği idempotent biçimde eskale etmek; agent'ın yalnız onay isteyebilmesini sağlamak; insan kararı gelmeden kritik işlemi gerçekleştirmemek; tüm adımları denetlenebilir kayda yazmak.

## Yapılanlar ve kanıt

- `ApprovalRequest` ve `ApprovalEvent` modelleri ile açık durum tablosu eklendi.
- `Approvals::Request`, `Approvals::Decide` ve `Approvals::EscalateOverdue` servisleri eklendi.
- Karar servisi `with_lock` kullanır; terminal durumdan ikinci kararı reddeder.
- 30 dakika eşiği `APPROVAL_ESCALATION_MINUTES` ile yapılandırılabilir. Tarama tekrar çalıştırıldığında yalnız `requested` kayıtları işler.
- `AgentWorkflow::RequestApproval`, izinli kritik işlemleri doğrular ve yalnız insan onayı oluşturur. LLM çağrısı yoktur.
- İç API Bearer token ister; token kodda veya Git geçmişinde tutulmaz.
- Onay kuyruğu, talep içi onay formu, karar düğmeleri ve iki seviyeli zaman çizelgesi eklendi.
- Testler; oluşturma/onay/red, yasak geçiş, 30 dakika öncesi/sonrası `travel_to`, çift eskalasyon, eşzamanlı karar, API yetkilendirmesi ve regresyon paketini kapsayacak şekilde eklendi.
- Yayın öncesi yerel tam paket: `37 runs, 158 assertions, 0 failures, 0 errors, 0 skips`.
- RuboCop: 66 dosya, 0 ihlal. Brakeman: 0 uyarı. Bundler Audit ve importmap audit: güvenlik açığı yok. Zeitwerk: `All is good!`. Production asset build başarılıdır.
- Bundler Audit'in ilk koşuda bulduğu `crass 1.0.7` CSS sanitizer açığı `1.0.8` sürümüne güncellenerek kapatıldı ve denetim tekrarlandı.
- Çalışan uygulama ve test değişiklikleri [`6efedbd`](https://github.com/mrtynk/destekflow/commit/6efedbd) (`Onay ve eskalasyon merkezini ekle`) commit'inde başladı; güvenlik ve yayın düzeltmeleri sonraki commitlerde korunmuştur.
- Yayın öncesi denetimde kimlik doğrulamasız web karar uçları ve zayıf agent tokenı riski bulundu. Site geneli fail-closed HTTP Basic, en az 32 bayt agent tokenı ve erişim testleri yerel `8b2c879` (`Demo ve agent erisimini fail closed koru`) commit'inde düzeltildi.
- Sonraki agent-first katmanda anonim dış referans, LLM öncesi e-posta/telefon/kart benzeri veri maskelemesi, gerçek Gemini triyajı, yerel bilgi tabanı kanıtı ve kod seviyesinde yayın kapısı eklendi. `/agent_demo` yalnız sabit sahte senaryolarla bu zinciri görünür kılar; geçerli KB kanıtı olmayan yanıt insana devredilir.
- Agent-first son CI koşusu [40225273025](https://github.com/mrtynk/destekflow/actions/runs/40225273025) olup `58 runs, 247 assertions, 0 failures, 0 errors` sonucunu ve tüm lint/güvenlik işlerinde başarıyı doğrular.
- Ayrıntılı güvenlik incelemesi `ce1a08d` commit'inde LLM çıktı şemasını, KB otomatik yanıt yetkisini, çıktı PII maskelemesini, girdi sınırlarını, kaynak izolasyonunu ve idempotency yarışını sertleştirdi. [CI 40225765287](https://github.com/mrtynk/destekflow/actions/runs/40225765287): `64 runs, 262 assertions, 0 failures, 0 errors`.
- `8a419d6` commit'i modelin serbest metnini doğrudan yayımlamayı kaldırdı; cevap onaylı KB metninden üretilir. Kategori yanlış girilse de finans/hukuk/güvenlik sinyalleri kod tarafından insan devrine zorlanır. [CI 40226175715](https://github.com/mrtynk/destekflow/actions/runs/40226175715): `68 runs, 285 assertions, 0 failures, 0 errors`.

Son doğrulanan GitHub Actions koşusu [40199897119](https://github.com/mrtynk/destekflow/actions/runs/40199897119) olup commit `3de863c` için `45 runs, 190 assertions, 0 failures, 0 errors` ve tüm lint/güvenlik işlerinde başarı verdi. Aynı commit Render'da canlıdır. DEMO-A onay, DEMO-R ret ve 30 dakikadan eski DEMO-B manuel eskalasyon akışları sahte verilerle gözlendi. Canlı RAG çağrısı #9, #11 ve #8 kayıtlarını sırasıyla %94, %86 ve %79 skorla getirip nihai kararı insanda bıraktı.

Yapılamayanlar:

- Gerçek kullanıcı hesabı ve rol tabanlı yetkilendirme yoktur. Ders ve portföy paylaşımı için production HTML arayüzü şifresiz ve herkes tarafından değiştirilebilir hâle getirilmiştir. Bu bilinçli demo sınırı gerçek auth/RBAC yerine geçmez ve ticari kullanıma uygun değildir.
- Gerçek cron/worker ile otomatik 30 dakika taraması yoktur; manuel demo çağrısı vardır.
- İç onay agentı hâlâ kural tabanlıdır ve LLM diye sunulmaz. Ayrı RAG benzerlik katmanı gerçek Google Gemini çağrısı yapar; kritik işlem gerçekleştirmez.
- İnsan ve agent süreleri ölçülmedi; süre uydurulmadı.
- Agent API'nin doğru tokenla pozitif canlı çağrısı güvenli secret erişimi olmadan ayrıca doğrulanmadı; negatif erişim kontrolleri korunur.
- Agent Demo Merkezi son commit Render'a deploy edilip sahte senaryolar çalıştırılana kadar canlı uçtan uca kanıt tamamlanmış sayılmaz.

## Zaman

Çalışma 25 Ekim 2026 tarihinde yapıldı. İnsan çalışma süresi, agent çalışma süresi ve token maliyeti ayrı bir ölçüm sistemiyle kaydedilmedi; bu nedenle sayısal süre veya maliyet verilmez.

## Karar

**DEVAM.** Mevcut talep altyapısını koruyarak onay/eskalasyon değeri ekliyoruz. Production kararı için önce auth/RBAC, gerçek zamanlayıcı, başarılı CI ve kontrollü canlı doğrulama zorunludur.

### 26 Ekim 2026 — herkese açık portföy sınırı

- HTTP Basic bağımlılığı koddan ve `render.yaml` dosyasından kaldırıldı; `DEMO_SITE_AUTH_ENABLED`, `DEMO_SITE_USERNAME` ve `DEMO_SITE_PASSWORD` artık uygulama tarafından okunmaz.
- TASK 20 sırasında `PUBLIC_DEMO_READ_ONLY=true` ile şifresiz fakat salt-okunur yayın hazırlanmıştı. Bu geçici yaklaşım, kullanıcının riskleri kabul ederek verdiği TASK 21 onayıyla aşağıdaki açık eğitim demosuna dönüştürüldü.
- Yeni talep, yanıt, atama, durum değişimi, ilişkilendirme, RAG çalıştırma, agent demo çalıştırma, onay/ret ve manuel eskalasyon kontrolleri public arayüzden kaldırıldı.
- İsim ve e-posta alanları public görünümde saklanır; açıklama, yanıt ve gerekçelerde e-posta, telefon ve kart biçimleri görüntüleme sırasında maskelenir. Veritabanındaki geçmiş kayıtlar silinmedi veya değiştirilmedi.
- Seed kayıtları `.example` e-postalar ve açıkça sahte demo içerikleridir. Buna rağmen canlı veritabanına geçmişte elle girilmiş her serbest metnin kökeni koddan kesin doğrulanamadığı için maskeleme korunur ve gerçek veri kullanımına izin verildiği iddia edilmez.
- Internal agent API ayrı `ActionController::API` zincirinde kalır ve `AGENT_API_TOKEN` Bearer doğrulamasını aynen korur; token değiştirilmedi veya görüntülenmedi.

### 26 Ekim 2026 — TASK 21 açık ve kullanılabilir eğitim demosu

- Kullanıcı, canlı kayıtların demo amaçlı olduğunu ve anonim ziyaretçilerin kayıtları değiştirmesi, spam ve ücretsiz Gemini kotası tüketimi risklerini kabul ederek public yazma erişimini açıkça onayladı.
- Salt-okunur `403` katmanı ve `PUBLIC_DEMO_READ_ONLY` ayarı kaldırıldı. Talep oluşturma, atama, yanıt, geçiş, ilişkilendirme, RAG, onay, ret ve manuel eskalasyon anonim HTML arayüzünde kullanılabilir.
- Yeni taleplerde ad/e-posta alanları kaldırıldı; sunucu `Anonim Demo Ziyaretçisi` ve rastgele `.example` adresi üretir. Konu, açıklama, yanıt ve onay gerekçesindeki e-posta/telefon/kart biçimleri kaydetmeden önce maskelenir. Mevcut kayıtlar silinmedi.
- Gemini dış istekleri ortak PostgreSQL sayacı ve satır kilidiyle varsayılan dakikada 4, günde 40 istekle sınırlandırılır. Her yeniden deneme de bütçeden düşer; sınır aşımında güvenli Türkçe hata gösterilir.
- CSRF, model/form doğrulamaları, Ticket durum makinesi, onay transaction/locking ve idempotent eskalasyon korunur. Agent API yalnız Bearer tokenla erişilebilir kalır.
