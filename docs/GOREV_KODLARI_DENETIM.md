# G1-G5 Görev Kodları Denetimi

Denetim tarihi: 16 Ekim 2026. İncelenen kaynaklar: `kaynaklar/ruby_rails_ders.pdf` (özellikle sayfa 24-31 ve 35-37; ayrıca bütün PDF'de kod araması), `kaynaklar/ai_ajanlari_ders.pptx`, `kaynaklar/ders_transkripti.txt` ve `kaynaklar/ODEV_TALIMATI.md`.

## Materyallerdeki bütün G1-G5 geçişleri

| Kod | Kaynak ve konum | Hocanın kullandığı tam ifade | Açık görev tanımı mı? |
|---|---|---|---|
| G1 | Ruby/Rails PDF, s.12 | “Neredeyse 1:1 bir ölçüm değil, slogan; token farkını kendin ölç (G1).” | Evet. Verilen Python ve Ruby ifadelerinin token farkını ölçme görevi açıktır. |
| G5 | Ruby/Rails PDF, s.31 | “Yakalanan uydurma (G5)” | Kısmen. Ölçüm satırı açıktır; ayrı dosyanın biçimi veya asgari olay sayısı tanımlanmaz. |
| G1-G5 | Ruby/Rails PDF, s.35 | “G1-G5 + Yapamadıklarım bölümü” | Teslim gerekliliği açıktır; G2-G4'ün içerik tanımları burada verilmez. |
| G1 | Ruby/Rails PDF, s.36 | “Bir zaman kuralının ve bir durum geçişinin kodu (G1 tablosundan)” | Sunum adımı açıktır. Bunun s.12'deki token ölçümüyle aynı `G1` kodunu ikinci anlamda kullanıp kullanmadığı belirsizdir. |
| G1-G5 | Ruby/Rails PDF, s.37 | “Teslim: gelecek ders · canlı URL + GitHub + docs/ (G1-G5) + AGENT.md” | Dosyaların teslimi açıktır; içerik tanımı değildir. |
| G2 | Ödev talimatı, “100 puan için” | “gerçek kullanıcı yorumlarını okuyun (G2, Capterra, App Store vb.; linkleriyle)” | Hayır. Buradaki G2 bir değerlendirme sitesi adıdır, görev kodu tanımı değildir. |

`ai_ajanlari_ders.pptx` slayt XML'inde ve transkriptte tam `G1`, `G2`, `G3`, `G4` veya `G5` kodu bulunmadı. Transkript yine de konuları destekler: 37:37'de doğrulanamadığı yerde uydurmak yerine durma, 120:18'de token ekonomisi ve doğrulama maliyeti, 127:05'te gerçek kullanıcı yorumlarından iyileştirme anlatılır. Bu tematik bağlantılar resmî görev kodu tanımı olarak sunulmaz.

## Kesin doğrulanan tanımlar

1. G1, PDF sayfa 12'deki iki kod ifadesi için token farkını ölçme görevidir.
2. G5, PDF sayfa 31'de ölçülecek “yakalanan uydurma” sayısıdır.
3. PDF sayfa 35 ve 37, `docs/G1-G5` teslimini şart koşar.
4. PDF sayfa 31, `docs/AJAN_OLCUM_RAPORU.md` dosyasında yeniden oluşturulan beş satırlı ölçüm tablosunu verir.

## Tanımı bulunamayan veya çelişkili kodlar

- G2, G3 ve G4 için sağlanan ders materyallerinde bağımsız resmî görev tanımı bulunamadı.
- Ödev metnindeki “G2” görev kodu değil, kullanıcı yorumu sitesidir.
- PDF sayfa 36 “G1 tablosu” ifadesini zaman kuralı/durum geçişi sunumuna bağlar; sayfa 12 ise G1'i token ölçümü olarak tanımlar. Aynı kodun iki kullanımının ilişkisi materyallerde açıklanmaz.
- Mevcut `G2.md`, `G3.md` ve `G4.md`, ödevin doğrulanabilir gereksinimlerini düzenleyen tamamlayıcı belgelerdir; hocanın resmî tanımı değildir.

## Doldurulan ölçüm tablosu

`docs/AJAN_OLCUM_RAPORU.md` içinde yalnız iki hücre sayısal doldurulabildi:

- CI'da yeşil test: 18 test ve 77 assertion; GitHub Actions 38813269064.
- Yakalanan uydurma: Git geçmişinde gerçekten yazılıp düzeltilen 2 yanlış iddia.

Çıktı token sayısı, ajan düzeltme turu ve insan onay süresi ölçülmedi. Başka teknoloji yığınıyla aynı görev yürütülmedi.

## Hocadan açıklama gereken noktalar

1. G2-G4 için beklenen girdi, çıktı ve başarı ölçütü nedir?
2. Sayfa 36'daki “G1 tablosu”, sayfa 12'deki token deneyiyle aynı görev midir; yoksa zaman ve durum kuralları için başka bir tablo mu bekleniyor?
3. G5 yalnız yanlış iddia sayısı mı, yoksa doğrulama günlüğü ve kaynak karşılaştırması da içermeli mi?
4. Sayfa 31'deki diğer teknoloji karşılaştırması zorunluysa aynı görev, model ve koşullar nasıl sabitlenecek?

## Mevcut teslimin yeterliliği

- G1, gerçek tokenizer/model bilgisi ve tekrar üretilebilir token kimlikleriyle sayfa 12 görevini karşılar.
- G5, gerçek Git farklarıyla iki yanlış iddiayı ve ayrıca uydurma sayılmayan doğrulama düzeltmelerini ayırır.
- G2-G4 dosyaları yararlı kanıt dizinleridir; resmî tanım bulunmadığı için kesin tamamlandı sayılmaz.
- Ölçüm raporu, mevcut kayıtların izin verdiği kadar doludur. Ölçülmeyen değerleri tahmin etmediği için dersin “uydurulan rapor notu sıfırlar” ilkesine uygundur.
