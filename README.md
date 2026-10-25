# DestekFlow

[![CI](https://github.com/mrtynk/destekflow/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/mrtynk/destekflow/actions/workflows/ci.yml)

- Canlı uygulama: [destekflow.onrender.com](https://destekflow.onrender.com)
- GitHub deposu: [mrtynk/destekflow](https://github.com/mrtynk/destekflow)

DestekFlow, kurumsal destek taleplerini oluşturma, temsilciye atama, yanıtlama ve kontrollü biçimde çözme akışını yöneten Türkçe bir Ruby on Rails uygulamasıdır. Zendesk'in destek talebi akışından ilham alır; ürün adı ve görsel kimliği özgündür.

## Ana akış

1. Müşteri başlık, açıklama, kategori ve öncelikle talep açar.
2. Yönetici talebi destek temsilcisine atar; talep `new` durumundan `open` durumuna geçer.
3. Temsilci yanıt verir; ilk yanıt zamanı kaydedilir.
4. Talep yalnızca izinli geçişlerle `pending`, `solved` veya `closed` durumuna taşınır.
5. Her önemli işlem zaman çizelgesine yazılır.

Durum akışı: `new → open/pending`, `open → pending/solved`, `pending → open/solved`, `solved → open/closed`. Kapalı talep yeniden açılamaz.

## Zaman kuralları

- Yüksek öncelikli taleplerde ilk yanıt SLA'sı 4 saattir.
- Normal öncelikli taleplerde ilk yanıt SLA'sı 24 saattir.
- Çözülmüş talep 48 saat sonra otomatik kapanmaya uygun olur.

`CloseResolvedTicketsJob` kapanmaya uygun talepleri kapatır. Render cron servisleri ücretli olduğundan ücretsiz canlı ortamda zamanlanmış cron oluşturulmamıştır; job test paketiyle doğrulanmıştır ve ücretli ortama geçildiğinde zamanlanabilir.

## Özgün fayda: Akıllı SLA Öncelik Asistanı

Capterra'daki doğrulanmış kullanıcı Hadi B. (Product Coordinator, E-Learning), 23 Nisan 2026 tarihli Zendesk Explore incelemesinde özel metrik ve hesaplanan öznitelik üretmenin belirgin bir öğrenme eğrisi olduğunu; terimlerin ve veri kümesi yapısının yeni kullanıcılar için her zaman açık olmadığını yazıyor. DestekFlow bu acının dar, operasyonel bölümünü çözer: aktif talepleri ayrıca metrik, formül veya pano kurmadan SLA riski ve önceliğe göre sıralar ve her sıra için Türkçe gerekçe gösterir.

- Gerçek kullanıcı yorumu: [Capterra — Zendesk Explore incelemeleri](https://www.capterra.com/p/132248/BIME/reviews/)
- Zendesk'in mevcut çözümü: Explore; hazır panolar, SLA performansı, özel sorgu/hesaplanan metrik ve paylaşılabilir panolar sunar. [Zendesk metrik belgeleri](https://support.zendesk.com/hc/en-us/articles/4408846733722-Using-metrics-and-attributes-in-reports)
- DestekFlow'un kaldırdığı sürtünme: küçük bir destek ekibinin “önce hangi talebe bakmalıyım?” sorusu için Explore veri kümesini, formül dilini ve pano yapılandırmasını öğrenme gereğini kaldırır.
- Özgün katkı, tek cümle: **Hadi B.'nin özel metrik öğrenme eğrisi sorununu, etkin talepleri kurulum istemeden SLA riskine göre sıralayan ve nedeni Türkçe açıklayan bir iş kuyruğuna dönüştürüyoruz.**

| Önce | Sonra |
|---|---|
| Explore veri kümesini, hesaplanan metriği ve panoyu yapılandır; sonra SLA görünümünü yorumla. | Talep listesine gir; sıradaki aktif talebi, kalan süreyi ve gerekçeyi doğrudan gör. |

| Savunma sorusu | Kanıtlanabilir yanıt |
|---|---|
| Kullanıcı hangi problemi yaşıyor? | Hadi B., Explore'da özel metrik ve hesaplanan öznitelik üretmenin öğrenme eğrisini; terim ve veri kümesi yapısının yeni kullanıcı için belirsizliğini bildiriyor. |
| Zendesk bunu nasıl çözmeye çalışıyor? | Explore hazır panolar, sorgular, özel metrikler ve SLA performans raporları sunuyor; yani Zendesk'te analitik/SLA yokluğu iddia edilmiyor. |
| DestekFlow'un somut farkı nedir? | Geniş bir analitik araç yerine tek operasyonel kararı — “şimdi hangi aktif talep?” — kurulum gerektirmeyen, açıklamalı bir kuyruk olarak verir. |
| Kullanıcı hangi adımı daha az yapıyor? | Veri kümesi seçme, formül yazma ve bu karar için ayrı pano kurma adımlarını atlar. |
| 30 saniyelik canlı gösterim | `/tickets` açılır; normal ve yüksek öncelikli iki aktif kayıt gösterilir; asistanın yüksek riskliyi üste aldığı, kalan süreyi ve Türkçe gerekçeyi sunduğu işaret edilir. |

Karşılaştırma sınırı: Zendesk'te SLA veya raporlama yokmuş gibi bir iddia yoktur. Fark, geniş analitik yetenek yerine bu tek karar için yapılandırmasız ve açıklamalı kuyruktur. [Zendesk SLA belgeleri](https://support.zendesk.com/hc/en-us/articles/5604663490458-Using-SLA-policies)

## İkinci özgün fayda: Geri Alınabilir Benzer Talep Asistanı

G2'de Eleanor T. (Marketing Manager, Enterprise), aynı müşterinin telefon ve dizüstü bilgisayardan farklı e-postalarla yazması sonucu yinelenen talepler oluştuğunu; hatalı birleştirmenin geri alınamaması nedeniyle özel alan verisi kaybettiğini bildiriyor. Zendesk'in kendisi hem ilgili talep önerileri hem de talep birleştirme sunar; fakat resmî belgelerine göre birleştirme geri alınamaz, kaynak talep kapanır ve alanlar hedef talebe taşınmaz. [G2 yorumu](https://www.g2.com/products/zendesk-for-customer-service/reviews?qs=pros-and-cons), [Zendesk birleştirme belgesi](https://support.zendesk.com/hc/en-us/articles/4408882445594-Merging-tickets), [Zendesk öneri belgesi](https://support.zendesk.com/hc/en-us/articles/6885971957914-Merging-related-tickets-based-on-suggestions)

DestekFlow başlık ve açıklamaları Türkçe karakterleri normalleştiren deterministik Jaccard benzerliğiyle karşılaştırır. E-posta adresini puana katmadan farklı adresli talepleri de değerlendirebilir; bu, kişilerin aynı olduğu varsayımı değildir. Arayüz puanı ve ortak terimleri gösterir. Yönetici onayıyla kurulan bağlantı iki kaydı, SLA'yı, durumu ve yanıt geçmişini değiştirmez; geri alınabilir ve iki işlem de zaman çizelgesine yazılır.

| Zendesk'in doğrulanmış yaklaşımı | DestekFlow'un dar farkı |
|---|---|
| İlgili talep önerir ve seçilen kayıtları kalıcı olarak birleştirir. | Benzerliği açıklayıp kayıtları silmeden/kapamadan geri alınabilir bağlantı kurar. |
| Birleştirme geri alınamaz; kaynak alanlar hedefe taşınmaz. | Her iki talep ayrı kalır; yanlış ilişki tek işlemle kaldırılır. |

Yerel ve açıklanabilir yedek yaklaşım hâlâ küçük veri kümeli Jaccard sözcük benzerliğidir; anlam veya kimlik doğrulamaz, eş anlamlılarda yanlış negatif ve genel terimlerde yanlış pozitif üretebilir. Bunun üzerine isteğe bağlı gerçek RAG katmanı eklenmiştir:

1. İncelenen talep ile en fazla 12 adayın yalnız başlık/açıklaması `gemini-embedding-2` ile vektörleştirilir.
2. Cosine similarity ile eşik üzerindeki en yakın üç kayıt getirilir.
3. Getirilen kayıtlar düşük gecikmeli `gemini-3.5-flash-lite` için sınırlı kanıt bağlamı olur; model benzerlik ve farkı Türkçe açıklar.
4. Kullanıcı adı/e-posta modele gönderilmez. Model kritik işlem veya otomatik ilişkilendirme yapamaz; bağlantı kararı insandadır.
5. Model adı, retrieval kayıtları/skorları, sonuç veya hata `AiAnalysis` kaydında denetlenebilir biçimde tutulur; API anahtarı tutulmaz.

`GEMINI_API_KEY` yoksa arayüz “API anahtarı yapılandırılmadı” der ve RAG'ı çalışıyor gibi göstermez; kelime tabanlı açıklanabilir öneri kullanılmaya devam eder. Google'ın resmî Gemini belgeleri embedding'lerin RAG ve anlamsal arama kullanımını, batch embedding uç noktasını ve metin üretimini açıklar: [Embeddings](https://ai.google.dev/gemini-api/docs/embeddings), [metin üretimi](https://ai.google.dev/gemini-api/docs/text-generation?lang=rest), [ücretsiz katman](https://ai.google.dev/gemini-api/docs/pricing).

Sınırlar: RAG sonucu da kimlik doğrulamaz ve kesin mükerrer kararı değildir. Otomatik birleştirme yapmaz. Site geneli Basic koruma gerçek kullanıcı/RBAC değildir; gerçek kişisel veriyle kullanıma uygun değildir. Canlı `3de863c` sürümünde yalnız sahte demo verisiyle gerçek Gemini çağrısı doğrulanmıştır; bu doğrulama gerçek müşteri verisiyle kullanıma onay anlamına gelmez.

## Onay ve Eskalasyon Merkezi — agent-first, human-in-the-loop

Bir destek temsilcisi veya token korumalı iç agent endpoint'i; iade, erişim verme ya da talep kapatma gibi kritik bir işlem için gerekçeli insan onayı isteyebilir. Agent kritik işlemi gerçekleştirmez. Onay `requested` olarak açılır; insan tarafından `approved` veya `rejected` yapılabilir. 30 dakika bekleyen kayıt, yapılandırılabilir kuralla `escalated` durumuna ve üst yetkili demo kuyruğuna taşınır; eskalasyon sonrası da insan kararı gerekir.

Durum tablosu:

| Mevcut durum | İzinli sonraki durumlar |
|---|---|
| `requested` | `approved`, `rejected`, `escalated` |
| `escalated` | `approved`, `rejected` |
| `approved` | Yok |
| `rejected` | Yok |

Kararlar transaction ve satır kilidi içinde uygulanır; ikinci karar reddedilir. Onay ve eskalasyon olayları hem onay denetim geçmişine hem talep zaman çizelgesine yazılır. İç agent API'si `AGENT_API_TOKEN` Bearer tokenı ister, izinli kritik işlemleri doğrular ve yanıtında `critical_action_executed: false` döndürür. Bu onay servisi kural tabanlıdır; LLM çağrısı yapmaz ve LLM olarak tanıtılmaz. RAG benzerlik asistanı ayrı bir bileşendir ve yalnız yapılandırıldığında gerçek model çağrısı yapar.

Güvenlik ve canlılık sınırı: gerçek kullanıcı hesabı/RBAC henüz yoktur; görünen karar sahibi adları kontrollü ders simülasyonudur. Production arayüzünün tamamı `DEMO_SITE_USERNAME` ve en az 20 baytlık `DEMO_SITE_PASSWORD` ile HTTP Basic korumasına alınır; bilgiler eksikse uygulama `/up` dışında 503 ile kapalı kalır. İç agent API en az 32 baytlık `AGENT_API_TOKEN` olmadan devre dışıdır. Bu gizli değerler Render secret olarak girilir ve repoya yazılmaz. Onay/eskalasyon kodu `e8bca94` commit'iyle canlıdadır; ancak 30 dakika taraması arayüzden manuel tetiklenir, uygulama saatini değiştiren production parametresi ve gerçek worker/cron yoktur.

## Gizlilik korumalı agent-first destek akışı

Token korumalı `/internal/agent_tickets` API'si, bir yazılım ajanının form kullanmadan sahte/anonim müşteri referansıyla talep açmasını ve sonucu takip etmesini sağlar. Aynı `external_reference` tekrar gönderildiğinde ikinci kayıt oluşturulmaz. Müşteri adı ve e-postası yerine opak referans tutulur; açıklamadaki e-posta, telefon ve kart benzeri sayılar Gemini çağrısından ve veritabanına yazımdan önce maskelenir.

Gemini triyajı talebin önceliğini, insan gerekip gerekmediğini ve yalnız yerel bilgi tabanı maddelerine dayanan öneri yanıtını JSON olarak üretir. Ancak yayın kararı modele bırakılmaz: finans, hukuk, güvenlik, kimlik/hesap erişimi, yüksek öncelik, belirsizlik, boş yanıt veya bilgi tabanı kanıtı yoksa kod yanıtı engeller ve talebi insan kuyruğuna bırakır. Güvenli teknik taleplerde kanıtlı yanıt otomatik yayınlanabilir. Her çağrı model, karar, gerekçe, bilgi tabanı kanıtı ve yayın durumu ile `AgentRun` kaydına yazılır.

Bu katman insan-insan aktarımını düşük riskli ve bilgi tabanıyla cevaplanabilen taleplerde azaltır; kritik kararları insandan kaldırmaz. Regex maskeleme tam anonimleştirme değildir, gerçek müşteri verisiyle kullanım için DLP, saklama politikası, gerçek kullanıcı/RBAC ve hukuki değerlendirme gerekir. Mevcut onay API'si de ayrı kalır: kritik aksiyonlar yine insan kararı olmadan uygulanmaz.

## Faz 1: Fortune 500 araştırması

Fortune 500, şirketleri değerlemeye göre değil gelire göre sıralar. 2026 listesi 21 trilyon dolar toplam gelir, 2,1 trilyon dolar toplam kâr, 55 trilyon dolar toplam piyasa değeri ve 30,5 milyon çalışan bildiriyor. [Fortune 500 2026](https://fortune.com/ranking/fortune500/), [Fortune toplu analiz](https://www.fortune.com/2026/06/19/fortune-500-employment-profits-revenue-hiring-jobs-ai/)

| İstenen ölçü | Kaynaklı sonuç | Sınır |
|---|---:|---|
| Piyasa değeri aralığı — sayısal verisi bulunan 472 şirket | 18,9 milyon – 4,23792 trilyon dolar | 500 şirketin tamamı okundu; `Market Value ($M)` alanı sayısal olan 472 şirket analiz edildi, boş 28 şirket tahmin edilmeden kapsam dışında bırakıldı. Minimum QVC Group (sıra 433, 18,9 milyon $), maksimum Nvidia'dır (sıra 16, 4.237.920 milyon $). Birim milyon USD, veri kesiti 31 Mart 2026. [Fortune 500 2026](https://fortune.com/ranking/fortune500/), [QVC Group](https://fortune.com/company/qurate-retail/), [Nvidia](https://fortune.com/company/nvidia/), [yöntem ve yeniden üretim](docs/FORTUNE500_ANALIZ.md) |
| Çalışan sayısı aralığı | 603 – 2.100.000 | 2026 listesinde BitGo 603 çalışanla örneklenen en küçük işveren; Walmart şirket profilinde 2,1 milyon çalışan bildiriyor. [Fortune istihdam analizi](https://www.fortune.com/2026/06/19/fortune-500-employment-profits-revenue-hiring-jobs-ai/), [Walmart profili](https://fortune.com/company/walmart/) |
| Yaklaşık SaaS uygulaması | 660 ortalama, 641 medyan | Fortune 500'e özel ölçüm değil; 10.001+ çalışanlı büyük işletme örneklemi. [Zylo verisini aktaran 2025 rapor sunumu](https://25602359.fs1.hubspotusercontent-eu1.net/hubfs/25602359/Ibexa%20Summit%202025/Keynote-Summit-2025-web.pdf) |
| Yıllık SaaS harcaması | 284 milyon dolar ortalama | Fortune 500'e özel değil; 10.000+ çalışanlı işletmeler. Veri 40 milyon lisans ve 40 milyar dolar yönetilen harcamadan türetilmiştir. [Zylo 2025 duyurusu](https://www.prweb.com/releases/2025-saas-management-index-reveals-first-increase-in-average-saas-spend-in-three-years-amid-rising-vendor-costs-and-rapid-ai-adoption-302351642.html) |

Piyasa değeri, şirket değerlemesi/enterprise value ve gelir aynı ölçü değildir. Fortune 500 sırası gelire göredir; buradaki min–max yalnız Fortune'un sayısal `Market Value` yayımladığı 472 şirketin özsermaye piyasa değeri aralığıdır. Boş 28 şirket nedeniyle “500 şirketin tamamının değerleme aralığı” diye sunulmaz. BitGo'nun Fortune 500 üyeliği ayrıca Fortune şirket profilinde doğrulanmıştır; Fortune Global 500 ile karıştırılmamıştır. [Fortune BitGo Holdings profili](https://fortune.com/company/bitgo-holdings/). SaaS adet ve harcama ölçütleri de Fortune 500 kesinliğiyle sunulmamıştır; açık örneklem sınırına sahip 10.000+ çalışanlı büyük işletme kıyaslamasıdır.

## SaaS seçimi ve Fortune 500 kanıtı

Zendesk'in SEC'e sunduğu 2018 Q1 hissedar mektubu Stanley Black & Decker'ı açıkça bir Fortune 500 şirketi olarak tanımlar. Aynı bölüm, şirketin Zendesk Support, Guide, Chat ve Talk ürünlerini içeren çok ürünlü bir dağıtım için anlaşmayı onayladığını ve ekiplerin üç hafta içinde kullanıma geçtiğini bildirir. Bu, bir Fortune 500 şirketinin Zendesk ürünleri için ticari anlaşma yaptığına ilişkin birincil kaynak kanıtıdır. [SEC dosyası, sayfa 6](https://www.sec.gov/Archives/edgar/data/1463172/000162828018005523/a2018q1shareholderletter.htm)

Önce incelenen Box müşteri hikâyesi, Box'ın Zendesk müşterisi olduğunu ve Fortune 500 şirketlerine hizmet verdiğini gösteriyordu; ancak Box'ın kendisinin Fortune 500 olduğunu göstermediği için tek başına bu koşulu kanıtlamıyordu. Stanley Black & Decker SEC kanıtı bu boşluğu kapatır. [Zendesk Box müşteri hikâyesi](https://www.zendesk.com/customer/box/)

## Faz 2: maliyet ve ölçek tahmini

Zendesk'in kaynak kodu kapalıdır; aşağıdaki 300.000 satır gerçek Zendesk ölçümü değildir. Ders PDF'si/transkripti kurumsal SaaS hedefi için 300–500 bin satır büyüklük sırasını verir; ödev de yaklaşık 300 bin satırlık ürün seçilmesini ister. DestekFlow tüm ürünü değil, ödeme gerekçesi olan çekirdek akışı uygular.

| Ölçü | Sonuç | Dayanak / sınır |
|---|---:|---|
| Seçilen SaaS'ın tahmini kod satırı | 300.000 | Dersin hedef büyüklüğü; kapalı Zendesk kaynağının ölçümü değildir. |
| DestekFlow gerçek kod büyüklüğü | 1.260 fiziksel satır; 1.089 boş olmayan satır, 56 dosya | `app`, `config`, `db`, `lib`, `test`, `bin` altındaki Git'e izlenen `.rb/.erb/.css/.js/.yml/.yaml` dosyaları 15 Ekim 2026'da PowerShell ile sayıldı. Markdown ve bağımlılık kilit dosyaları kapsam dışıdır; test ve yapılandırma kapsamdadır. |
| Coding agent ile tahmini süre | 2–3 gün | Ödev metnindeki ders hesabı; gerçekleşmiş süre değildir. |
| Örnek fiyatlandırma modeli | GPT-5 API: girdi $1,25/M, önbellekli girdi $0,125/M, çıktı $10/M token | [Resmî OpenAI GPT-5 fiyatı](https://developers.openai.com/api/docs/models/gpt-5); bu projedeki Codex abonelik faturasını temsil etmez. |
| Tahmini token maliyeti | En az $30 çıktı; toplam hesaplanamaz | 300.000 satır × varsayımsal 10 çıktı tokenı = 3M çıktı tokenı; 3 × $10 = $30. Girdi, reasoning, araç çağrıları ve düzeltme turları ölçülmediği için toplam verilmez. |
| Abonelik bazlı alternatif maliyet | Ölçülmedi | Alternatif senaryo bir aylık plan ücreti × 1 ay olurdu; kullanılan Codex/ChatGPT planı ve proje payı kaydedilmediği için USD rakamı uydurulmadı. |
| Gerçek geliştirme süresi | Aynı takvim günü; aktif saat ölçülmedi | Git geçmişi ilk commit'i ve çalışan çekirdeği 15 Ekim 2026'da gösterir; bu, kesintisiz emek süresi değildir. |
| Gerçekte ölçülen ayrı nakit maliyet | $0 | GitHub public depo ve Render web/PostgreSQL ücretsiz plan; mevcut Codex aboneliğinin payı bu sayıya dahil değildir. |
| Ölçülemeyenler | Gerçek token sayısı, reasoning tokenı, düzeltme turu başı tüketim, abonelik payı, insan doğrulama saati | Bu veriler için proje bazlı fatura/zaman kaydı yok; rakam uydurulmadı. |

## Kurulum

Gereksinimler: Ruby 3.4.7+, Rails 8.1+, PostgreSQL 17+.

```powershell
bundle install
$env:DB_HOST="127.0.0.1"
$env:DB_USER="postgres"
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Ardından `http://localhost:3000` adresini açın.

## Test

```powershell
bin/rails test
bin/rails zeitwerk:check
```

15 Ekim 2026 yeni özellik sonrası yerel sonucu: **18 test, 77 assertion, 0 failure, 0 error**. Benzerlik, farklı e-posta, ilgisiz kayıt, deterministik puan, ilişkilendirme/geri alma, yinelenen ilişki, işlem geçmişi ve SLA/durum korunumu kapsanır. Özellik commit'inin [GitHub Actions koşusu 38773363080](https://github.com/mrtynk/destekflow/actions/runs/38773363080) içindeki test, system-test, lint ve güvenlik job'larının tamamı geçti. Ayrıntılar [docs/TEST_KANITLARI.md](docs/TEST_KANITLARI.md) dosyasındadır.

25 Ekim 2026 son GitHub Actions koşusu **45 test, 190 assertion, 0 failure, 0 error** sonucu verdi. Oluşturma, onaylama, reddetme, yasak geçiş, 30 dakika sınırı, idempotent eskalasyon, eşzamanlı çift karar, agent API doğrulama/yetkilendirme, RAG orkestrasyonu ve HTTP istemcisi regresyonu ile eski akışlar kapsanır. Aynı [CI koşusunda](https://github.com/mrtynk/destekflow/actions/runs/40199897119) test, system-test, lint, Ruby ve JavaScript güvenlik işlerinin tamamı geçti.

## Deploy

`render.yaml`, Frankfurt bölgesinde ücretsiz Ruby web servisi ve PostgreSQL 17 veritabanını tanımlar. Migration ve idempotent seed ücretsiz planla uyumlu biçimde build sırasında çalışır. `DATABASE_URL` Blueprint veritabanından bağlanır; `SECRET_KEY_BASE` Render tarafından gizli ve rastgele üretilir.

Canlı dağıtım 15 Ekim 2026 tarihinde Rails 8.1.4 ve Ruby 3.4.7 ile başarıyla açıldı. `/up` sağlık kontrolü HTTP 200 döndürdü. Canlı ortamda #2 numaralı yüksek öncelikli talep oluşturuldu, Mehmet Kaya'ya atandı, yanıtlandı, çözüldü ve beş işlem geçmişi kaydı doğrulandı. Akıllı SLA Öncelik Asistanı açık yüksek öncelikli talebi ilk sırada, kalan ilk yanıt süresi ve gerekçesiyle gösterdi.

16 Ekim 2026'da `e373bb7` Render'a manuel deploy edildi; PostgreSQL `CreateTicketLinks` migrationı ve idempotent sahte seed başarılı oldu. `/up` HTTP 200 döndürdü. Canlı #4/#5 farklı `.example` e-postalı taleplerde %73 puan ve sekiz ortak terim görüldü; ilişki kuruldu, iki detayda da ayrı kayıt/durum/SLA korundu, ilişki geri alındı ve her iki olay geçmişte doğrulandı. Eski #2 oluştur–ata–yanıtla–çöz akışı ve beş olay da yeni deploy altında aynen görüntülendi.

25 Ekim 2026'da `3de863c` Render'a manuel deploy edildi. `GEMINI_API_KEY` secret olarak, üretim modeli `gemini-3.5-flash-lite` olarak yapılandırıldı. Sahte demo talebinde canlı RAG çağrısı tamamlandı; #9 (%94), #11 (%86) ve #8 (%79) kanıt kayıtları getirildi, Türkçe benzerlik/fark açıklaması üretildi ve nihai kararın insanda olduğu açıkça belirtildi.

## Belgeler

- [Plan](PLAN.md)
- [Ajan rehberi](AGENT.md)
- [Kod haritası](docs/KOD_HARITASI.md)
- [Test kanıtları](docs/TEST_KANITLARI.md)
- [Ajan ölçüm raporu](docs/AJAN_OLCUM_RAPORU.md)
- [G1-G5 görev kodları denetimi](docs/GOREV_KODLARI_DENETIM.md)
- [Son teslim denetimi](docs/SON_DENETIM.md)
- [TASK 17 yayın öncesi denetimi](docs/TASK17_YAYIN_ONCESI_DENETIM.md)
- [Fortune 500 Market Value analizi](docs/FORTUNE500_ANALIZ.md)
- [Kaynaklar](docs/KAYNAKLAR.md)

## Yapamadıklarım

- Ücretsiz Render planında cron hizmeti bulunmadığından 48 saatlik otomatik kapanış canlıda zamanlanmamıştır; job ve davranışı testlerde doğrulanmıştır.
- Ücretsiz Render web servisi hareketsizlikte uyur ve ilk isteği geciktirebilir. Ücretsiz PostgreSQL veritabanı Render'ın süre ve saklama sınırlarına tabidir.
- Gerçek kullanıcı hesabı ve rol yetkilendirmesi yoktur. Production demosu site geneli HTTP Basic ile sınırlandırılır; bu koruma gerçek çok kullanıcılı auth/RBAC yerine geçmez. Gerçek müşteri verisi kullanılmamalıdır.
- RAG canlıda yalnız sahte demo verisiyle doğrulanmıştır. Ücretsiz Gemini katmanında gönderilen içerik sağlayıcının ürün geliştirmesinde kullanılabildiğinden gerçek müşteri veya kişisel veri gönderilmemelidir.
- Agent-first intake akışı kod ve CI testlerinde doğrulanmıştır; henüz Render'da doğru tokenla pozitif uçtan uca çağrı yapılmadığı sürece canlıda doğrulandı diye sunulmamalıdır. Regex maskeleme tam anonimleştirme veya mevzuat uyumu garantisi değildir.
- Onay/eskalasyon sürümünde gerçek zamanlayıcı yoktur; 30 dakika taraması yetkili demo ekranından manuel servis çağrısıyla gösterilir. Canlı DEMO-B kaydı 30 dakikadan eski olduktan sonra eskale edilmiştir; bu, cron bulunduğu anlamına gelmez.
- Fortune 500'ün 500 satırı incelendi; 28 satırda Market Value boş olduğu için min–max 472 sayısal şirketi kapsar. Özel/boş şirketlere tahmini değer atanmadı; sonuç tüm 500 şirketin eksiksiz değerleme aralığı değildir.
- Ders materyali G2, G3 ve G4 belgelerinin resmî tanımını vermiyor. Dosyalar bunu açıkça belirterek ödevin doğrulanabilir isterlerine dayalı öneri içerikleri sunuyor; bunlar hocanın resmî tanımı diye gösterilmiyor.
- Windows Ruby kurulumunda kullanılmayan libvips eklentileri için uyarılar var; test sonucunu etkilemiyor.
