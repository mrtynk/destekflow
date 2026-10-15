# Beş Dakikalık Sunum Metni

## 0:00–0:30 — Ürün ve aort dilimi

DestekFlow, Zendesk'in destek talebi akışından ilham alan özgün bir Rails uygulaması. Kurumlar tüm müşteri mesajlarını tek yerde görmek, sorumluyu belirlemek, yanıt süresini izlemek ve talebi kontrollü biçimde kapatmak için bu sınıf ürünlere ödeme yapıyor. Göstereceğim aort dilimi talep açma, atama, yanıtlama ve çözme akışı.

## 0:30–2:30 — Canlı akış

Yeni talep ekranında müşteri adı, e-posta, başlık, açıklama, kategori ve önceliği gir. Talebi oluştur. Detay sayfasında SLA son zamanını ve oluşturma olayını göster. Bir temsilci ata; durumun Yeni'den Açık'a geçtiğini ve iki yeni geçmiş kaydını göster. Temsilci yanıtı ekle. Durumu Çözüldü yap ve zaman çizelgesini göster. Listeye dönüp durum filtresini ve Akıllı SLA Öncelik Asistanı'nın açıklamasını göster.

## 2:30–3:30 — Zaman ve durum kuralı

`app/services/sla/deadline_calculator.rb` içindeki 4 ve 24 saatlik merkezi tabloyu göster. Ardından `app/models/ticket.rb` içindeki izinli geçiş haritasını ve `app/services/tickets/transition.rb` içindeki yasak geçiş hatasını göster. `test/models/ticket_test.rb` dosyasındaki `travel_to` testlerinden birini çalıştır.

## 3:30–4:30 — Kullanılabilir pas ve açıklar

Capterra'daki Hadi B. (Product Coordinator) özel metrik ve hesaplanan öznitelikleri öğrenmenin zor olduğunu söylüyor. Zendesk Explore bu işi hazır panolar, sorgular ve özel metriklerle çözüyor; bizim çözümümüz onun yerine tam analitik ürün değildir. Akıllı SLA Öncelik Asistanı küçük ekibin “önce hangi aktif talebe bakmalıyım?” kararında ayrı metrik/formül/pano kurulumu istemeden sırayı, kalan süreyi ve Türkçe gerekçeyi gösteriyor. Zendesk'in SLA ve raporlama özelliklerini saklama. Ücretsiz Render cron eksikliğini ve kimlik doğrulama olmadığını açıkça göster.

Ardından iki sahte demo talebinden birini aç. Farklı e-postalı diğer kaydın puanını ve eşleşen terimlerini göster; bunun kimlik eşleştirmesi olmadığını söyle. “İlişkilendir” ile iki ayrı kaydın korunduğunu ve geçmiş olayını göster; “İlişkiyi geri al” ile kararı tersine çevir. Zendesk'in zaten ilgili talep önerdiğini saklama: farkımız, fiziksel birleştirme yerine açıklanabilir ve geri alınabilir bağlantıdır.

## 4:30–5:00 — Kod yeri sorusu

"SLA hafta sonunu saymasın" değişikliği için önce `Sla::DeadlineCalculator.call` değiştirilir, sonra `test/models/ticket_test.rb` içindeki yüksek ve normal öncelik zaman testlerine cuma/hafta sonu örnekleri eklenir. Durum kuralı değişirse `Ticket::TRANSITIONS` ve geçiş testleri güncellenir.

## Sunuma hazır örnek veri

- #1 `Fatura ekranına erişemiyorum`: açık, yüksek öncelikli, Ayşe Yılmaz'a atanmış; SLA Asistanı gerekçesini göstermek için korunur.
- #2 `Canlı ortam SLA doğrulaması`: çözülmüş tam akış örneği.
- #3 `503 sonrası canlı doğrulama`: çözülmüş; oluşturma, Mehmet Kaya'ya atama, yanıt ve durum geçmişinin ikinci canlı kanıtı.
- Yeni bir sunum talebi gerekirse `Sunum canlı demo` başlığı ve `sunum-demo@example.com` sahte e-postası kullanılır; gerçek kişisel veri girilmez.
- `Ekim faturası ekranı boş görünüyor` ve `Ekim faturası ekranı açılmıyor`: farklı `.example` e-postalı, idempotent seed ile oluşturulan benzer talep demosu. Önce ilişkilendir, iki kaydı ve denetim izini göster, sonra geri al.
