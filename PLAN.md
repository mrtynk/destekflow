# DestekFlow Uygulama Planı

## Kabul Kriterleri

- Rails 8+ ve PostgreSQL ile Türkçe, responsive uygulama.
- Talep oluşturma, atama, yanıt, kontrollü durum geçişi, çözme ve işlem geçmişi.
- Yönetim listesi, filtreleme ve detay görünümü.
- Yüksek öncelikte 4 saat, normal öncelikte 24 saat ilk yanıt SLA'sı.
- Çözümden 48 saat sonra otomatik kapanmaya uygunluk.
- Üç zaman kuralı için `travel_to`; yasak geçişler için otomatik test.
- Kullanıcı yorumuyla kaynaklandırılmış, çalışan ve test edilen özgün özellik.
- GitHub Actions, gerçek rozet, Render yapılandırması ve doğrulanmış canlı URL.
- Kaynaklı Faz 1/Faz 2 araştırması, Yapamadıklarım bölümü ve sunum belgeleri.
- G1-G5 tanımları kaynakta doğrulanabildiği ölçüde belgelenir; belirsizlik uydurulmaz.

## Aşamalar

1. Kaynakları ve ortamı doğrula, ilk `AGENT.md` sürümünü ayrı commit et.
2. Rails uygulamasını PostgreSQL ile kur ve temel veri modelini oluştur.
3. Aort dilimini açık servisler ve durum geçiş kurallarıyla geliştir.
4. SLA kuralları, kapanış işi ve testlerini ekle.
5. Akıllı SLA Öncelik Asistanı için gerçek kullanıcı yorumunu araştır, kapsamı doğrula ve uygula.
6. Türkçe responsive arayüzü tamamla; çalışmayan öğeleri kaldır.
7. Tüm testleri çalıştır, CI ve Render dosyalarını ekle.
8. Kaynaklı README ve docs belgelerini gerçek dosya/satır bilgileriyle tamamla.
9. GitHub ve Render hesap erişimi gerektiğinde kullanıcıdan yetki iste; CI ve canlı URL'yi gerçek sonuçla doğrula.
10. 0/85/100+ kontrol listesini kanıtlarla kapat ve beş dakikalık sunumu hazırla.

## Bilinen Başlangıç Riskleri

- Ruby kurulumları diskte mevcut fakat PATH yapılandırması tutarsız; komutlarda doğrulanmış Ruby yolu kullanılacak.
- G2-G4 tanımları sağlanan kaynaklarda açıkça görünmüyor; ek kaynak bulunmazsa bu durum belgelerde eksik olarak yazılacak.
- GitHub ve Render işlemleri hesap bağlantısı gerektirir; yerel geliştirme bunlardan bağımsız sürdürülecek.
