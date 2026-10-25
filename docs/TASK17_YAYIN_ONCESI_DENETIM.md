# TASK 17 — Yayın Öncesi Son Denetim

## Sonuç

Kod, migration, yerel testler ve production asset build yayın adayıdır. Push/deploy henüz yapılmadığından GitHub Actions ve Render canlı doğrulaması beklemektedir. Gerçek kullanıcı auth/RBAC yoktur; yalnız site geneli HTTP Basic ile korunan, sahte verili ders demosu olarak yayınlanabilir.

## Commit ve belge denetimi

TASK 16'nın üç yerel commit'i temiz sıradadır:

| Commit | İçerik | Denetim |
|---|---|---|
| `6efedbd` | Onay/eskalasyon modelleri, servisleri, UI, API ve testler | Tam paket ve statik denetimler geçti |
| `ea1bd07` | README, AGENT, CHALLENGE_LOG ve test kanıtları | Zorunlu sınırlar yazılı |
| `77ed349` | Gerçek uygulama commit kanıtı | CHALLENGE_LOG içinde `6efedbd` doğrulandı |

CHALLENGE_LOG zorunlu başlıkların tamamını içerir: `Başlangıç noktası`, `Acı`, `Bu haftanın vaadi`, `Yapılanlar ve kanıt`, `Zaman`, `Karar`. Başlangıç commit'i `7e8c6b1`, gerçek kullanıcı kaynağı, ölçülmüş test sonuçları ve yapılamayanlar açıkça yazılıdır. TASK 17 güvenlik düzeltmesi `8b2c879` commit'indedir.

## Güvenlik kararı

- Web: Production'da `DEMO_SITE_AUTH_ENABLED=true` varsayılır. `DEMO_SITE_USERNAME` veya en az 20 bayt `DEMO_SITE_PASSWORD` yoksa uygulama `/up` dışında 503 ile kapalı kalır. Yanlış/eksik Basic kimlik bilgisi 401 verir.
- Agent API: `AGENT_API_TOKEN` en az 32 bayt değilse endpoint 503 ile devre dışıdır. Eksik/yanlış Bearer token 401 verir. Token hiçbir yanıtta gösterilmez.
- Loglar: `authorization`, `token`, `agent_api_token`, parola ve secret alanları filtrelenir.
- Sınır: HTTP Basic, gerçek kullanıcı hesabı/RBAC ve kişi bazlı yetki izi değildir. Demo aktörleri gerçek yetkili kişi olarak sunulmaz; gerçek müşteri verisi kullanılmaz.
- Zaman: Production'da saat veya `created_at` değiştiren demo parametresi yoktur. `travel_to` yalnız test dosyalarında kullanılır. Canlı eskalasyon demosu için kayıt en az 30 dakika önceden hazırlanır.

## Migration güvenliği

`20261025120000_create_approval_requests.rb` yalnız iki yeni tablo, indeks, check constraint ve foreign key ekler. Mevcut tabloyu silmez, yeniden adlandırmaz veya mevcut satırları güncellemez. Yeni foreign key yeni ve boş `approval_requests` tablosundan mevcut `tickets` tablosuna gider; mevcut Ticket kayıtlarını silmez. Test PostgreSQL'de üç migration da `up` durumundadır. Render öncesinde yine de veritabanı yedeği/geri dönüş noktası alınmalıdır; `db:rollback` üretim verisini geri getirme yöntemi değildir.

## GitHub Actions ve Render sırası

1. Render'da güçlü ve birbirinden farklı `DEMO_SITE_USERNAME`, `DEMO_SITE_PASSWORD` ve rastgele en az 32 bayt `AGENT_API_TOKEN` secretlarını hazırla; chat, commit veya URL içinde paylaşma.
2. PostgreSQL için Render yedeği/geri dönüş noktası al ve mevcut servis commit'ini kaydet.
3. Yerel temiz ağacı ve son commitleri doğrula.
4. Kullanıcı izniyle `master` dalını GitHub'a push et.
5. GitHub Actions'ta `test`, `system-test`, `lint`, `scan_js`, `scan_ruby` job'larını kontrol et. `system-test` job'ının test dosyası olmadığı için 0 test çalıştırdığını gizleme.
6. CI yeşilse Render Blueprint secretlarını gir; deploy başlat.
7. Build logunda migration ve asset build başarısını; `/up` için HTTP 200'ü doğrula.
8. Kimliksiz `/tickets` isteğinin 401, doğru Basic kimlikle 200 verdiğini doğrula. Agent endpoint'inde tokensız 401 ve doğru tokenla 201 doğrula; tokenı ekran görüntüsü veya loga alma.
9. Sahte demo kayıtlarıyla oluştur–onay iste–onayla/reddet–zaman çizelgesi akışını çalıştır.
10. En az 30 dakika önceden hazırlanmış bekleyen kaydı manuel taramayla bir kez eskale et; ikinci taramada yeni olay oluşmadığını doğrula.
11. Sonuçları gerçek CI run URL'si, Render deploy ID'si ve canlı HTTP kanıtıyla belgele.

## Üç dakikalık güvenli canlı demo verisi

Gerçek kişi/e-posta kullanılmaz. Sunumdan en az 35 dakika önce Basic koruma arkasında şu kayıtlar hazırlanır:

- `DEMO-A`: “5.000 TL üzeri iade” — sahte `demo-a@example.com`; bekleyen onay, sunumda onaylanır.
- `DEMO-B`: “Kurumsal erişim talebi” — sahte `demo-b@example.com`; en az 30 dakika bekletilir, sunumda eskale edilip reddedilir.
- `DEMO-C`: Mevcut normal talep akışının regresyonunu göstermek için sahte kayıt; onay akışından bağımsız kalır.

Erişim yöntemi: öğretmene HTTPS URL ve HTTP Basic kullanıcı/parolası ayrı, özel kanaldan verilir. Agent API tokenı öğretmene veya tarayıcıya verilmez; agent çağrısı gerekiyorsa terminalde environment variable üzerinden yapılır ve terminal geçmişi/sunum ekranı tokenı göstermeyecek şekilde hazırlanır.

## 85 puan kanıt matrisi

| Kriter | Kanıt | Durum |
|---|---|---|
| Fortune 500 şirketinin seçilen SaaS'ı kullanması | Stanley Black & Decker SEC mektubu, README | Tamamlandı |
| Faz 1 kaynaklı araştırma | README ve `docs/FORTUNE500_ANALIZ.md`; 472 sayısal Market Value örneklemi ve sınırlar | Tamamlandı |
| Faz 2 süre/maliyet/ölçek hesabı | README; tahmin ile ölçülen değerler ayrılmış | Tamamlandı |
| Çalışan ana aort dilimi | Oluştur–ata–yanıtla–çöz–geçmiş servisleri ve önceki canlı kanıt | Tamamlandı; yeni deploy sonrası tekrar doğrulanmalı |
| Üç zaman kuralı ve yasak geçişler | `ticket_test.rb` travel_to ve transition testleri | Tamamlandı |
| GitHub Actions | Önceki sürüm yeşil; TASK 17 commitleri henüz push edilmedi | Bekliyor |
| Render canlı sürüm | Önceki sürüm canlı; TASK 17 deploy edilmedi | Bekliyor |
| AGENT.md ve dürüst sınırlar | AGENT.md, README, CHALLENGE_LOG | Tamamlandı |

## 100+ puan kanıt matrisi

| Kriter | Kanıt | Durum |
|---|---|---|
| Gerçek kullanıcı yorumundan ek acı | G2 Eleanor T. yanlış/geri alınamayan birleştirme; Zendesk Community Nayden11 onay akışı katılığı | Tamamlandı |
| Kopyadan farklı çalışan adaptasyon | Geri alınabilir ilişkilendirme; agent-first insan onaylı ve idempotent eskalasyon | Yerelde tamamlandı |
| İnsan kararı olmadan kritik aksiyon yok | Agent response `critical_action_executed: false`, servis ve API testleri | Tamamlandı |
| Yarış koşulu ve çift karar koruması | `with_lock`, transaction, concurrency testi | Tamamlandı |
| Uçtan uca canlı kanıt | Güvenli Basic erişim, canlı onay/ret/eskalasyon ve geçmiş | Deploy sonrası bekliyor |

## Kalan riskler

- Gerçek kullanıcı auth/RBAC ve kişi bazlı audit kimliği yoktur; HTTP Basic yalnız ders demosu sınırıdır.
- Gerçek cron/worker yoktur; eskalasyon taraması manuel tetiklenir.
- Sistem test dosyası yoktur; `rails test:system` 0 test çalıştırır.
- Ücretsiz Render uyuyabilir; ilk istek gecikebilir.
- TASK 17 için CI ve canlı kanıt push/deploy izninden sonra üretilebilir.
