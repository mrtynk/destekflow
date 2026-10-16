# Ajan Ölçüm Raporu

Bu tablo, `kaynaklar/ruby_rails_ders.pdf` sayfa 31'deki şablonu izler. Ders tablosunun amacı bir özelliğin yalnız üretim hızını değil, çıktı tokenı, düzeltme ve insan doğrulama maliyetini birlikte ölçmektir. Kayıt altına alınmayan değerler Git commit sayısından veya tahminden türetilmemiştir.

| Ölçüt | Rails (DestekFlow) | Seçilen diğer yığın |
|---|---:|---:|
| Çıktı token sayısı (ajan arayüzünden) | Ölçülmedi | Ölçülmedi |
| Düzeltme turu sayısı | Ölçülmedi | Ölçülmedi |
| CI'da yeşil test sayısı | 18 test, 77 assertion | Ölçülmedi |
| Yakalanan uydurma (G5) | 2 doğrulanmış yanlış iddia | Ölçülmedi |
| Kodu okuyup onaylama süresi (dk) | Ölçülmedi | Ölçülmedi |

## Kanıt ve kapsam

- CI değeri: commit `bd070d0`, GitHub Actions koşusu [38813269064](https://github.com/mrtynk/destekflow/actions/runs/38813269064), `test` job'u: `18 runs, 77 assertions, 0 failures, 0 errors, 0 skips`. `system-test` job'u başarılıdır fakat `0 runs` raporladığı için 18 sayısına eklenmemiştir.
- G5 sayısı yalnız Git geçmişinde gerçekten yazılıp sonra düzeltilen iki yanlış iddiayı kapsar: doğrulanamayan Ryan P. kullanıcı atfı ve canlı işlem geçmişinin dört olay olduğu ifadesi. Ayrıntı `docs/G5.md` içindedir.
- `c33edf4` ve `206c78f` CI yapılandırma düzeltmeleridir; ancak bunların her biri bir ajan “düzeltme turu” ölçümü değildir. Bu yüzden düzeltme turu hücresi doldurulmadı.
- Git commit zamanları kodu okuyup onaylamaya ayrılan insan süresini veya ajan çıktı tokenını ölçmez.
- Aynı görev başka bir teknoloji yığınıyla yürütülmedi. Karşılaştırma sütununa sonuç uydurulmadı.

## Ders bağlantısı

- PDF sayfa 28: büyük çıktı penceresi üretimi ucuzlatırken okuyup onaylamayı ucuzlatmaz.
- PDF sayfa 29: dar boğaz “Sen doğrula” aşamasına taşınır.
- PDF sayfa 30: doğrulanmamış test raporu uydurma örneği olarak verilir.
- PDF sayfa 31: yukarıdaki beş ölçüt ve karşılaştırmalı tablo doğrudan istenir.
- Transkript 120:18: token ekonomisi giriş ve çıkış tokenlarının toplamı olarak anlatılır; gizli doğrulama maliyeti ayrıca vurgulanır.
