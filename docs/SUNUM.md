# Beş Dakikalık Sunum Metni

## 0:00–0:30 — Ürün ve aort dilimi

DestekFlow, Zendesk'in destek talebi akışından ilham alan özgün bir Rails uygulaması. Kurumlar tüm müşteri mesajlarını tek yerde görmek, sorumluyu belirlemek, yanıt süresini izlemek ve talebi kontrollü biçimde kapatmak için bu sınıf ürünlere ödeme yapıyor. Göstereceğim aort dilimi talep açma, atama, yanıtlama ve çözme akışı.

## 0:30–2:30 — Canlı akış

Yeni talep ekranında müşteri adı, e-posta, başlık, açıklama, kategori ve önceliği gir. Talebi oluştur. Detay sayfasında SLA son zamanını ve oluşturma olayını göster. Bir temsilci ata; durumun Yeni'den Açık'a geçtiğini ve iki yeni geçmiş kaydını göster. Temsilci yanıtı ekle. Durumu Çözüldü yap ve zaman çizelgesini göster. Listeye dönüp durum filtresini ve Akıllı SLA Öncelik Asistanı'nın açıklamasını göster.

## 2:30–3:30 — Zaman ve durum kuralı

`app/services/sla/deadline_calculator.rb` içindeki 4 ve 24 saatlik merkezi tabloyu göster. Ardından `app/models/ticket.rb` içindeki izinli geçiş haritasını ve `app/services/tickets/transition.rb` içindeki yasak geçiş hatasını göster. `test/models/ticket_test.rb` dosyasındaki `travel_to` testlerinden birini çalıştır.

## 3:30–4:30 — Kullanılabilir pas ve açıklar

Capterra'daki kurumsal kullanıcı, özel metriklerin zor çıkarıldığını ve panonun kalabalık olduğunu söylüyor. Asistan ayrı rapor kurulumu istemeden hangi talebin önce ele alınacağını Türkçe gerekçeyle gösteriyor. Zendesk'in SLA özelliği olduğunu saklama; farkın küçük ekip için yapılandırmasız açıklama olduğunu söyle. GitHub/Render henüz doğrulanmadıysa bunu açıkça Yapamadıklarım listesinden göster.

## 4:30–5:00 — Kod yeri sorusu

"SLA hafta sonunu saymasın" değişikliği için önce `Sla::DeadlineCalculator.call` değiştirilir, sonra `test/models/ticket_test.rb` içindeki yüksek ve normal öncelik zaman testlerine cuma/hafta sonu örnekleri eklenir. Durum kuralı değişirse `Ticket::TRANSITIONS` ve geçiş testleri güncellenir.
