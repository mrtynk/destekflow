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

15 Ekim 2026 yerel sonucu: **9 test, 29 assertion, 0 failure, 0 error**. GitHub Actions'ta lint, Ruby güvenlik taramaları, JavaScript dependency audit, test ve system-test job'larının tamamı geçti: [başarılı CI koşusu](https://github.com/mrtynk/destekflow/actions/runs/38714995821). Ayrıntılar [docs/TEST_KANITLARI.md](docs/TEST_KANITLARI.md) dosyasındadır.

## Deploy

`render.yaml`, Frankfurt bölgesinde ücretsiz Ruby web servisi ve PostgreSQL 17 veritabanını tanımlar. Migration ve idempotent seed ücretsiz planla uyumlu biçimde build sırasında çalışır. `DATABASE_URL` Blueprint veritabanından bağlanır; `SECRET_KEY_BASE` Render tarafından gizli ve rastgele üretilir.

Canlı dağıtım 15 Ekim 2026 tarihinde Rails 8.1.4 ve Ruby 3.4.7 ile başarıyla açıldı. `/up` sağlık kontrolü HTTP 200 döndürdü. Canlı ortamda #2 numaralı yüksek öncelikli talep oluşturuldu, Mehmet Kaya'ya atandı, yanıtlandı, çözüldü ve beş işlem geçmişi kaydı doğrulandı. Akıllı SLA Öncelik Asistanı açık yüksek öncelikli talebi ilk sırada, kalan ilk yanıt süresi ve gerekçesiyle gösterdi.

## Belgeler

- [Plan](PLAN.md)
- [Ajan rehberi](AGENT.md)
- [Sunum metni](docs/SUNUM.md)
- [Kod haritası](docs/KOD_HARITASI.md)
- [Test kanıtları](docs/TEST_KANITLARI.md)
- [Son teslim denetimi](docs/SON_DENETIM.md)
- [Fortune 500 Market Value analizi](docs/FORTUNE500_ANALIZ.md)
- [Kaynaklar](docs/KAYNAKLAR.md)

## Yapamadıklarım

- Ücretsiz Render planında cron hizmeti bulunmadığından 48 saatlik otomatik kapanış canlıda zamanlanmamıştır; job ve davranışı testlerde doğrulanmıştır.
- Ücretsiz Render web servisi hareketsizlikte uyur ve ilk isteği geciktirebilir. Ücretsiz PostgreSQL veritabanı Render'ın süre ve saklama sınırlarına tabidir.
- Canlı yönetim ekranında kimlik doğrulama ve rol yetkilendirmesi yoktur. Uygulama yalnız ders demosudur; gerçek müşteri verisiyle veya herkese açık üretim hizmeti olarak kullanılmamalıdır.
- Fortune 500'ün 500 satırı incelendi; 28 satırda Market Value boş olduğu için min–max 472 sayısal şirketi kapsar. Özel/boş şirketlere tahmini değer atanmadı; sonuç tüm 500 şirketin eksiksiz değerleme aralığı değildir.
- Ders materyali G2, G3 ve G4 belgelerinin resmî tanımını vermiyor. Dosyalar bunu açıkça belirterek ödevin doğrulanabilir isterlerine dayalı öneri içerikleri sunuyor; bunlar hocanın resmî tanımı diye gösterilmiyor.
- Windows Ruby kurulumunda kullanılmayan libvips eklentileri için uyarılar var; test sonucunu etkilemiyor.
