# Kod Haritası

| Konu | Gerçek yer | Değişiklik noktası |
|---|---|---|
| Durum geçiş haritası | `app/models/ticket.rb:5` | `TRANSITIONS` sabiti |
| Durum geçişinin uygulanması | `app/services/tickets/transition.rb:5` | `call` metodu |
| 4/24 saat SLA | `app/services/sla/deadline_calculator.rb:3` | `DURATIONS` sabiti |
| SLA öncelik açıklaması | `app/services/sla/priority_assistant.rb:5` | skor ve Türkçe gerekçe |
| 48 saat kapanma uygunluğu | `app/models/ticket.rb:37` | `closable?` |
| Otomatik kapanış | `app/jobs/close_resolved_tickets_job.rb:4` | `perform` |
| Talep oluşturma | `app/services/tickets/create.rb:3` | `call` |
| Atama | `app/services/tickets/assign.rb:3` | `call` |
| İlk yanıt | `app/services/tickets/reply.rb:3` | `call` |
| HTTP akışı | `app/controllers/tickets_controller.rb:1` | controller eylemleri |
| Zaman testleri | `test/models/ticket_test.rb:11` | dört `travel_to` senaryosu |
| Özgün özellik testi | `test/services/sla_priority_assistant_test.rb:7` | risk sırası ve açıklama |
| Listeleme, filtre ve asistan çağrısı | `app/controllers/tickets_controller.rb:4` | `index` eylemi; asistan çağrısı satır 8 |
| Canlı asistan paneli | `app/views/tickets/index.html.erb:19` | sıralı gerekçe görünümü |
| Atama/yanıt/geçiş HTTP uçları | `app/controllers/tickets_controller.rb:27` | `assign`, `reply`, `transition` |
| İşlem geçmişi görünümü | `app/views/tickets/show.html.erb:8` | `TicketEvent` zaman çizelgesi |
| Route'lar ve sağlık kontrolü | `config/routes.rb:2` | ticket member uçları; `/up` satır 14 |
| Sunum örnek verisi | `db/seeds.rb:10` | iki temsilci ve açık yüksek öncelikli #1 senaryosu |
| Uçtan uca servis testi | `test/services/ticket_workflow_test.rb:4` | atama, yanıt, çözüm ve olay sırası |
| Yasak geçiş testi | `test/models/ticket_test.rb:44` | `new → closed` hatası ve durumun korunması |

Satırlar 15 Ekim 2026 son teslim çalışma ağacına göre `rg -n` ile doğrulanmıştır. Kod değişirse sunumdan önce yeniden üretilmelidir.
