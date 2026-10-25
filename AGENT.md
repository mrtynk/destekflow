# DestekFlow Ajan Rehberi

## Amaç ve Öncelik

DestekFlow, destek talebinin oluşturulması, temsilciye atanması, yanıtlanması ve çözülmesi akışını uçtan uca sunan Türkçe bir Rails uygulamasıdır. Öncelik çalışan ve doğrulanmış 85 puan kapsamıdır; kullanıcı yorumuna dayanan küçük bir özgün fayda bunun üstüne eklenir.

## Domain Sözlüğü (TR ↔ EN)

- destek talebi = Ticket
- talep sahibi / müşteri = Requester
- destek temsilcisi = Agent
- atama = Assignment
- yanıt = Reply
- işlem geçmişi = Activity / TicketEvent
- onay talebi = ApprovalRequest
- onay geçmişi = ApprovalEvent
- eskalasyon = Escalation
- öncelik = Priority
- durum = Status
- ilk yanıt = First response
- SLA son zamanı = SLA due at
- SLA ihlali = SLA breach / overdue
- aort dilimi = Core flow

## Mimari İlkeler

- Rails 8+, PostgreSQL, ERB, Turbo ve Minitest kullan.
- Rails konvansiyonlarını izle; sapmaları bu dosyada açıkla.
- Controller yalnızca HTTP akışını yönetsin. Durum geçişi, SLA hesabı ve atama gibi iş kuralları açık model metotlarında veya `app/services` altındaki küçük servislerde yaşasın.
- İş mantığını callback, concern veya dolaylı metaprogramming arkasına saklama.
- Kullanıcı arayüzünde çalışmayan buton veya sahte özellik bırakma.

## İş Kurallarının Yeri

Gerçek yerleşim:

- Durumlar ve izinli geçişler: `app/models/ticket.rb` ve `app/services/tickets/transition.rb`
- SLA süreleri: `app/services/sla/deadline_calculator.rb`
- SLA risk sıralaması: `app/services/sla/priority_assistant.rb`
- Çözülmüş taleplerin kapanması: `app/jobs/close_resolved_tickets_job.rb`
- İşlem geçmişi: `Tickets::Create`, `Tickets::Assign`, `Tickets::Reply` ve `Tickets::Transition` servislerinin oluşturduğu `TicketEvent` kayıtları
- Onay geçişleri: `ApprovalRequest::TRANSITIONS`, `Approvals::Decide` ve `Approvals::EscalateOverdue`
- Agent-insan sınırı: `AgentWorkflow::RequestApproval`; agent yalnızca onay ister, kritik işlemi uygulamaz
- Gerçek RAG benzerlik akışı: `Tickets::RagSimilarity`; embedding retrieval sonuçlarını sınırlı üretim bağlamına verir, otomatik ilişkilendirme yapmaz

## Onay ve Eskalasyon Kuralları

- `requested`, yalnızca `approved`, `rejected` veya `escalated` durumuna geçebilir.
- `escalated`, insan kararıyla `approved` veya `rejected` olur. Son durumlar tekrar değiştirilemez.
- Kararlar `with_lock` ve transaction içinde alınır; aynı onayın iki kez sonuçlandırılması reddedilir.
- Varsayılan eskalasyon eşiği 30 dakikadır ve `APPROVAL_ESCALATION_MINUTES` ile yapılandırılır.
- Ücretsiz canlı ortamda gerçek cron/worker yoktur. Arayüzdeki tarama yalnız kontrollü demo çağrısıdır.
- Agent endpoint'i `AGENT_API_TOKEN` olmadan çalışmaz. Token repoya yazılmaz.
- Agent, sabit ve açık kurallı demo servisidir; LLM değildir ve LLM çağrısı yapıldığı iddia edilmez.
- RAG asistanı bundan ayrıdır: yalnız `GEMINI_API_KEY` tanımlıyken gerçek Gemini batch embedding ve generateContent çağrısı yapar. Ad/e-posta göndermez; talimat enjeksiyonuna karşı talep metnini güvenilmeyen veri sayar ve sonucu insan incelemesine bırakır. Ücretsiz katmanda yalnız sahte demo verisi kullanılmalıdır.
- Web onay ekranındaki aktör adları simülasyondur; kimlik doğrulanmış kullanıcı olarak sunulmaz.
- Production web arayüzü `DEMO_SITE_AUTH_ENABLED=true` iken HTTP Basic ile tamamen korunur. Kullanıcı adı ve en az 20 bayt parola Render secret olarak verilir; eksik yapılandırma 503 ile kapalı kalır.
- Internal agent API en az 32 baytlık `AGENT_API_TOKEN` olmadan 503 ile devre dışı kalır; yanlış veya eksik Bearer token 401 üretir.
- Demo parolası ve agent tokenı dokümana, kaynak koda, URL'ye, test çıktısına veya Git geçmişine yazılmaz. Öğretmene ayrı ve güvenli kanaldan iletilir.

## Test Kuralları

- Her zaman kuralının en az bir `travel_to` testi olmalı.
- Her izinli kritik durum geçişi ve her yasak geçiş test edilmeli.
- Talep oluşturma, atama, yanıtlama, çözme ve geçmiş görüntüleme akışları entegrasyon/sistem testleriyle doğrulanmalı.
- Test sonucu yalnızca gerçekten çalıştırılmış komut çıktısıyla raporlanır.
- GitHub Actions yeşil olmadan CI başarılı denmez.

## Kodlama Kuralları

- Kullanıcıya görünen metin Türkçe yazılır.
- Domain metotları niyeti açıklayan İngilizce adlar taşır.
- Küçük, tek sorumluluklu sınıflar ve açık keyword argümanları tercih edilir.
- Çalışmış migration değiştirilmez; yeni migration eklenir.
- Zaman hesabında `Time.current` kullanılır.
- Parola, token ve gizli anahtar repoya yazılmaz.

## Yasaklanan Karmaşık Rails Kalıpları

- `default_scope`
- `method_missing`
- İş kuralı içeren `before_*` / `after_*` callback'leri
- Davranışı gizleyen genel concern'ler
- Gereksiz monkey patch ve dinamik metot üretimi
- Yeni bağımlılık gerektiren iş günü hesabı; açıkça istenmedikçe SLA takvim saatiyle hesaplanır

## Konvansiyondan Sapmalar

- Yerel Windows PostgreSQL kurulumu eksik veritabanını otomatik oluşturma sırasında yanıltıcı bağlantı hatası verdi; geliştirme ve test veritabanları `createdb` ile açıkça oluşturuldu.
- Demo kapsamı için kimlik doğrulama eklenmedi. Bu durum canlı yayından önce güvenlik kararı gerektirir ve `docs/YAPAMADIKLARIM.md` içinde açıktır.
- Production tek `DATABASE_URL` kullanır; Rails'in varsayılan ayrı cache/queue/cable veritabanları küçük Render kurulumu için kaldırıldı.

## Sürüm Notu

İlk sürüm Git geçmişinde `ce6cb13` commit'iyle korunur. Bu sürümde hedef dosya adları gerçek dosyalara çevrildi; işlem geçmişi servisleri, yerel veritabanı sapması, production bağlantı kararı ve kimlik doğrulama eksiği eklendi. Doğrulanan komutlar `bundle exec rails test` ve `bundle exec rails zeitwerk:check`tir.
