# Beş Dakikalık Sunum Metni

## 0:00–0:30 — Ürün ve aort dilimi

DestekFlow, Zendesk'in destek talebi akışından ilham alan özgün bir Rails uygulaması. Kurumlar tüm müşteri mesajlarını tek yerde görmek, sorumluyu belirlemek, yanıt süresini izlemek ve talebi kontrollü biçimde kapatmak için bu sınıf ürünlere ödeme yapıyor. Göstereceğim aort dilimi talep açma, atama, yanıtlama ve çözme akışı.

## 0:30–2:30 — Canlı akış

Yeni talep ekranında müşteri adı, e-posta, başlık, açıklama, kategori ve önceliği gir. Talebi oluştur. Detay sayfasında SLA son zamanını ve oluşturma olayını göster. Bir temsilci ata; durumun Yeni'den Açık'a geçtiğini ve iki yeni geçmiş kaydını göster. Temsilci yanıtı ekle. Durumu Çözüldü yap ve zaman çizelgesini göster. Listeye dönüp durum filtresini ve Akıllı SLA Öncelik Asistanı'nın açıklamasını göster.

## 2:30–3:30 — Zaman ve durum kuralı

`app/services/sla/deadline_calculator.rb` içindeki 4 ve 24 saatlik merkezi tabloyu göster. Ardından `app/models/ticket.rb` içindeki izinli geçiş haritasını ve `app/services/tickets/transition.rb` içindeki yasak geçiş hatasını göster. `test/models/ticket_test.rb` dosyasındaki `travel_to` testlerinden birini çalıştır.

## 3:30–4:30 — Kullanılabilir pas ve açıklar

Capterra'daki 10.001+ çalışanlı kurum kullanıcısının acısı: özel metrikleri çıkarmak zaman alıyor ve panolar kalabalık hissediliyor. Bizim çözümümüz: Akıllı SLA Öncelik Asistanı ayrı rapor kurulumu istemeden sıradaki aktif talebi, kalan süreyi ve yüksek/normal öncelik gerekçesini Türkçe gösteriyor. Zendesk'in SLA özelliği olduğunu saklama; farkın küçük ekip için yapılandırmasız ve açıklamalı sıra olduğunu söyle. Canlı URL ile yeşil CI doğrulanmıştır; ücretsiz Render cron eksikliğini `docs/YAPAMADIKLARIM.md` üzerinden açıkça göster.

## 4:30–5:00 — Kod yeri sorusu

"SLA hafta sonunu saymasın" değişikliği için önce `Sla::DeadlineCalculator.call` değiştirilir, sonra `test/models/ticket_test.rb` içindeki yüksek ve normal öncelik zaman testlerine cuma/hafta sonu örnekleri eklenir. Durum kuralı değişirse `Ticket::TRANSITIONS` ve geçiş testleri güncellenir.

## Sunuma hazır örnek veri

- #1 `Fatura ekranına erişemiyorum`: açık, yüksek öncelikli, Ayşe Yılmaz'a atanmış; SLA Asistanı gerekçesini göstermek için korunur.
- #2 `Canlı ortam SLA doğrulaması`: çözülmüş tam akış örneği.
- #3 `503 sonrası canlı doğrulama`: çözülmüş; oluşturma, Mehmet Kaya'ya atama, yanıt ve durum geçmişinin ikinci canlı kanıtı.
- Yeni bir sunum talebi gerekirse `Sunum canlı demo` başlığı ve `sunum-demo@example.com` sahte e-postası kullanılır; gerçek kişisel veri girilmez.
