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

Capterra'da 10.001+ çalışanlı bir kurumun destek yöneticisi, özel metrikleri çıkarmanın zaman aldığını ve panoların kalabalık hissettirdiğini yazıyor. Başka kullanıcılar da yeni kullanıcılar için gezinmenin karmaşık olduğunu belirtiyor. DestekFlow, açık talepleri ayrı rapor kurulumu gerektirmeden SLA riski ve önceliğe göre sıralar; her sıra için Türkçe bir neden gösterir.

- Kullanıcı yorumu: [Capterra Zendesk değerlendirmeleri](https://www.capterra.com/p/164283/Zendesk/reviews/)
- Karşılaştırma sınırı: Zendesk zaten SLA kolonları, görünümler ve raporlama sunar. DestekFlow'un fark iddiası "Zendesk'te SLA yok" değildir; küçük ekip için yapılandırmasız, tek ekranda ve açıklamalı öncelik sırasıdır. [Zendesk SLA belgeleri](https://support.zendesk.com/hc/en-us/articles/5604663490458-Using-SLA-policies)

## Faz 1: Fortune 500 araştırması

Fortune 500, şirketleri değerlemeye göre değil gelire göre sıralar. 2026 listesi 21 trilyon dolar toplam gelir, 2,1 trilyon dolar toplam kâr, 55 trilyon dolar toplam piyasa değeri ve 30,5 milyon çalışan bildiriyor. [Fortune 500 2026](https://fortune.com/ranking/fortune500/), [Fortune toplu analiz](https://www.fortune.com/2026/06/19/fortune-500-employment-profits-revenue-hiring-jobs-ai/)

| İstenen ölçü | Kaynaklı sonuç | Sınır |
|---|---:|---|
| Değerleme aralığı | Güvenilir bir tam aralık verilemiyor | Listedeki özel şirketlerde piyasa değeri yoktur; şirket değeri, piyasa değeri ve gelir aynı ölçü değildir. Fortune'un yayımladığı doğrulanabilir toplu piyasa değeri 55 trilyon dolardır. Nvidia için 4,2 trilyon dolar en yüksek piyasa değeri olarak raporlanmıştır; tüm 500 şirket için karşılaştırılabilir minimum bulunamadı. [Fortune analizi](https://fortune.com/2026/06/03/fortune-500-2026-takeaways-nvidia-amazon-walmart/) |
| Çalışan sayısı aralığı | 603 – 2.100.000 | 2026 listesinde BitGo 603 çalışanla örneklenen en küçük işveren; Walmart şirket profilinde 2,1 milyon çalışan bildiriyor. [Fortune istihdam analizi](https://www.fortune.com/2026/06/19/fortune-500-employment-profits-revenue-hiring-jobs-ai/), [Walmart profili](https://fortune.com/company/walmart/) |
| Yaklaşık SaaS uygulaması | 660 ortalama, 641 medyan | Fortune 500'e özel ölçüm değil; 10.001+ çalışanlı büyük işletme örneklemi. [Zylo verisini aktaran 2025 rapor sunumu](https://25602359.fs1.hubspotusercontent-eu1.net/hubfs/25602359/Ibexa%20Summit%202025/Keynote-Summit-2025-web.pdf) |
| Yıllık SaaS harcaması | 284 milyon dolar ortalama | Fortune 500'e özel değil; 10.000+ çalışanlı işletmeler. Veri 40 milyon lisans ve 40 milyar dolar yönetilen harcamadan türetilmiştir. [Zylo 2025 duyurusu](https://www.prweb.com/releases/2025-saas-management-index-reveals-first-increase-in-average-saas-spend-in-three-years-amid-rising-vendor-costs-and-rapid-ai-adoption-302351642.html) |

Bu iki SaaS ölçütü Fortune 500 kesinliğiyle sunulmamıştır; en yakın, açık örneklem sınırına sahip büyük işletme kıyaslamasıdır.

## SaaS seçimi ve Fortune 500 kanıtı

Zendesk'in SEC'e sunduğu 2018 Q1 hissedar mektubu Stanley Black & Decker'ı açıkça bir Fortune 500 şirketi olarak tanımlar. Aynı bölüm, şirketin Zendesk Support, Guide, Chat ve Talk ürünlerini içeren çok ürünlü bir dağıtım için anlaşmayı onayladığını ve ekiplerin üç hafta içinde kullanıma geçtiğini bildirir. Bu, bir Fortune 500 şirketinin Zendesk ürünleri için ticari anlaşma yaptığına ilişkin birincil kaynak kanıtıdır. [SEC dosyası, sayfa 6](https://www.sec.gov/Archives/edgar/data/1463172/000162828018005523/a2018q1shareholderletter.htm)

Önce incelenen Box müşteri hikâyesi, Box'ın Zendesk müşterisi olduğunu ve Fortune 500 şirketlerine hizmet verdiğini gösteriyordu; ancak Box'ın kendisinin Fortune 500 olduğunu göstermediği için tek başına bu koşulu kanıtlamıyordu. Stanley Black & Decker SEC kanıtı bu boşluğu kapatır. [Zendesk Box müşteri hikâyesi](https://www.zendesk.com/customer/box/)

## Faz 2: maliyet ve ölçek tahmini

Zendesk'in kaynak kodu kapalıdır; 300.000 satır gerçek ölçüm değildir. Ders materyali orta ölçekli kurumsal SaaS için 300–500 bin satır büyüklük sırasını kaba varsayım olarak verir. DestekFlow tüm ürünü değil, ödeme gerekçesi olan çekirdek akışı uygular.

- Varsayım: 300.000 satır × satır başına yaklaşık 10 çıktı tokenı = yaklaşık 3 milyon çıktı tokenı. Bu yalnızca kaba büyüklük hesabıdır.
- Maliyet formülü: çıktı tokenı × kullanılan modelin güncel fiyatı + abonelik + düzeltme turları + insan doğrulama zamanı.
- Gerçek token tüketimi bu ortamda güvenilir bir proje sayacıyla ölçülmedi; sayı uydurulmamıştır.
- Gerçek geliştirme başlangıcı: 15 Ekim 2026. İlk çalışan çekirdek ve yerel test paketi aynı gün üretildi.
- Gerçek nakit harcaması: bu oturumda ölçülebilir ayrı API faturası yok; GitHub deposu ile Render web/PostgreSQL kaynakları ücretsiz planlarda oluşturuldu.

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
- [Kaynaklar](docs/KAYNAKLAR.md)

## Yapamadıklarım

- Ücretsiz Render planında cron hizmeti bulunmadığından 48 saatlik otomatik kapanış canlıda zamanlanmamıştır; job ve davranışı testlerde doğrulanmıştır.
- Ücretsiz Render web servisi hareketsizlikte uyur ve ilk isteği geciktirebilir. Ücretsiz PostgreSQL veritabanı Render'ın süre ve saklama sınırlarına tabidir.
- Fortune 500'ün tamamı için karşılaştırılabilir en düşük ve en yüksek şirket değerlemesi bulunamadı; özel şirketler nedeniyle piyasa değeri eksik.
- Ders materyali G2, G3 ve G4 belgelerinin tanımını vermiyor. Dosyalar belirsizliği kaydediyor; içerik uydurulmadı.
- Windows Ruby kurulumunda kullanılmayan libvips eklentileri için uyarılar var; test sonucunu etkilemiyor.
