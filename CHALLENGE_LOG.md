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
- Çalışan uygulama ve test değişiklikleri yerel `6efedbd` (`Onay ve eskalasyon merkezini ekle`) commit'inde tutulur. Commit henüz remote'a gönderilmediği için GitHub bağlantısı varmış gibi verilmez.
- Yayın öncesi denetimde kimlik doğrulamasız web karar uçları ve zayıf agent tokenı riski bulundu. Site geneli fail-closed HTTP Basic, en az 32 bayt agent tokenı ve erişim testleri yerel `8b2c879` (`Demo ve agent erisimini fail closed koru`) commit'inde düzeltildi.

Bu çalışma için henüz GitHub Actions veya Render demo kanıtı yoktur; açık izin olmadan push/deploy yapılmayacaktır. Yerel doğrulamalar Ruby 3.4.7 çalıştırıcısıyla tamamlanmıştır. Sistem testi komutu başarılı çıkış vermiş ancak projede sistem test dosyası olmadığı için `0 runs` raporlamıştır.

Yapılamayanlar:

- Gerçek kullanıcı hesabı ve rol tabanlı yetkilendirme yoktur. Kontrollü yayın yalnız site geneli HTTP Basic demo korumasıyla yapılabilir.
- Gerçek cron/worker ile otomatik 30 dakika taraması yoktur; manuel demo çağrısı vardır.
- Gerçek LLM entegrasyonu yoktur; açıkça kural tabanlı demo agent kullanılır.
- İnsan ve agent süreleri ölçülmedi; süre uydurulmadı.
- Bu sürüm Render'da doğrulanmadı ve canlı özellik olarak sunulamaz.

## Zaman

Çalışma 25 Ekim 2026 tarihinde yapıldı. İnsan çalışma süresi, agent çalışma süresi ve token maliyeti ayrı bir ölçüm sistemiyle kaydedilmedi; bu nedenle sayısal süre veya maliyet verilmez.

## Karar

**DEVAM.** Mevcut talep altyapısını koruyarak onay/eskalasyon değeri ekliyoruz. Production kararı için önce auth/RBAC, gerçek zamanlayıcı, başarılı CI ve kontrollü canlı doğrulama zorunludur.
