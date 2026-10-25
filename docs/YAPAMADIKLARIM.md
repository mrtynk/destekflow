# Yapamadıklarım

- Ücretsiz Render planında zamanlanmış cron servisi oluşturulamadı. `CloseResolvedTicketsJob` ve 48 saat kuralı otomatik testte çalışıyor; canlıda saatlik tetikleyici yok.
- Render ücretsiz web servisi hareketsizlikte uyuduğu için uyanma penceresinde geçici 503 görülebilir. 15 Ekim 2026 son kontrolünde servis `Live`, `/up`, `/` ve `/tickets` HTTP 200 idi.
- Fortune 500'ün 500 satırı elde edildi; 472 sayısal `Market Value` analiz edildi. Kalan 28 satır boş olduğundan tahmin edilmedi. Bu nedenle sonuç bütün 500 şirketin eksiksiz “şirket değerlemesi” değil, yayımlanan özsermaye piyasa değerlerinin min–max'ıdır; gelir veya enterprise value ile karıştırılmaz.
- Sağlanan materyaller G2, G3 ve G4'ün gerçek tanımlarını vermiyor.
- Canlı demo site geneli HTTP Basic ile korunur; ancak gerçek kullanıcı hesabı ve rol tabanlı yetkilendirme yoktur. Bu koruma çok kullanıcılı auth/RBAC yerine geçmez; gerçek müşteri veya kişisel veriyle kullanım uygun değildir.
- Gemini RAG kodu ve sahte istemcili testleri yerelde tamamlandı. `GEMINI_API_KEY` güvenli biçimde yapılandırılıp gerçek API çağrısı canlıda doğrulanmadan özellik “canlı AI” olarak sunulamaz; mevcut canlı `e8bca94` sürümünde RAG yoktur. Ücretsiz katman gerçek kişisel veriye uygun kabul edilmez.
