# Fortune 500 Market Value Analizi

Denetim tarihi: 15 Ekim 2026.

## Kapsam ve yöntem

Resmî kaynak [Fortune 500 2026 sıralamasıdır](https://fortune.com/ranking/fortune500/). Fortune 500 şirketleri **gelire göre** sıralar; bu çalışma sıralama ölçütünü değiştirmez. İncelenen `Market Value ($M)` alanı, halka açık şirketlerin özsermaye piyasa değeridir; gelir, şirket değeri (enterprise value) veya özel şirket değerleme tahmini değildir.

Sayfanın herkese açık `__NEXT_DATA__` bloğundaki `franchiseSearch.items` dizisinden sıra numarası 1–500 olan satırlar alındı. `$`, binlik ayraç ve ondalık işareti dışında karakter içeren ya da boş değerler sayısal analize alınmadı. Boş özel/mutual şirket değerleri tahmin edilmedi.

## Sonuç

| Ölçü | Sonuç |
|---|---:|
| Fortune 500 satırı | 500 |
| Sayısal `Market Value ($M)` bulunan | 472 |
| Boş/kapsam dışı | 28 |
| Minimum | QVC Group — Fortune sırası 433 — **18,9 milyon USD** |
| Maksimum | Nvidia — Fortune sırası 16 — **4.237.920 milyon USD (4,23792 trilyon USD)** |

- Minimum kaynakları: [Fortune 500 tam tablo](https://fortune.com/ranking/fortune500/), [QVC Group profili](https://fortune.com/company/qurate-retail/).
- Maksimum kaynakları: [Fortune 500 tam tablo](https://fortune.com/ranking/fortune500/), [Nvidia profili](https://fortune.com/company/nvidia/).
- Birim: Fortune alan adındaki `$M` nedeniyle **milyon ABD doları**.
- Tarih: 2026 sıralama veri setindeki piyasa değerleri **31 Mart 2026** kesitidir. QVC profilindeki dipnot bu tarihi açıkça verir. Şirket profil sayfaları daha sonra güncellenebildiği için yeniden üretimde sıralama sayfasının 2026 gömülü veri seti esas alınır.

28 boş satırın sıraları: 32, 62, 69, 72, 93, 94, 95, 100, 109, 130, 140, 226, 232, 240, 241, 242, 249, 271, 273, 288, 308, 321, 342, 387, 392, 419, 457 ve 493. Bunlara tahmin atanmadı.

## Yeniden üretim

```powershell
ruby script/fortune500_market_value.rb
```

Beklenen özet:

```text
Fortune 500 satırı: 500
Sayısal Market Value: 472
Kapsam dışı/boş Market Value: 28
Minimum: #433 QVC Group $18.9 milyon USD
Maksimum: #16 Nvidia $4,237,920 milyon USD
```

Sayfanın HTML/JSON yapısı veya Fortune verisi değişirse betik farklı sonuç verebilir ya da güvenli biçimde hata verir. Bu belge 15 Ekim 2026'da elde edilen kesiti kaydeder.
