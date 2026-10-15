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

Satırlar 15 Ekim 2026 çalışma ağacına göredir. Kod değişirse sunumdan önce `rg -n` ile yenilenmelidir.
