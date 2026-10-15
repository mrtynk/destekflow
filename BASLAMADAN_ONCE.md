# DestekFlow - Codex Başlangıç Paketi

Bu klasör henüz bir Rails uygulaması DEĞİLDİR. Kaynak materyaller hazırdır; uygulamayı Codex oluşturacak.

## Dosyalar
- `kaynaklar/ODEV_TALIMATI.md`: Hocanın gönderdiğin tam ödev metni.
- `kaynaklar/ruby_rails_ders.pdf`: Ruby/Rails dersi ve ödev açıklamasını içeren sunum.
- `kaynaklar/ai_ajanlari_ders.pptx`: Ajanlar ders sunumu.
- `kaynaklar/ders_transkripti.txt`: Ders kaydının otomatik dökümü (yazım hataları olabilir).

## Windows 11 / VS Code adımları
1. ZIP dosyasını çıkar; `destekflow_baslangic` klasörünü istediğin yere taşı. İstersen klasörü `destekflow` olarak yeniden adlandır.
2. VS Code -> File -> Open Folder ile bu klasörü aç.
3. Terminal -> New Terminal aç; `Get-ChildItem .\kaynaklar` ile kaynakların orada olduğunu doğrula.
4. Codex'i bu klasörde başlat.
5. Önce `kaynaklar/ODEV_TALIMATI.md` dosyasını ve PDF/slayt/transkripti okumasını iste. Gerekirse daha önce hazırlanan kapsamlı DestekFlow promptunu Codex'e yapıştır.
6. GitHub ve Render hesaplarını sen oluştur/bağla. Şifre veya API anahtarı kaynak dosyalara yazma.
7. Codex'in yaptığı her şeyi yerel test, gerçek GitHub Actions ve canlı URL ile denetle.

## Kasıtlı olarak oluşturulmayan dosyalar
- `AGENT.md`: Ödev bunu ajanla birlikte üretmeni istiyor. İlk sürümü Codex ile üretip commit et; sonra değişikliklerin diff'ini koru.
- `README.md`, Rails dosyaları, `docs/G1-G5`: Codex gerçek araştırma ve proje kodu ile üretecek. İsim ve içerikler ders kaynaklarına göre teyit edilmeli.

## Kritik kural
Sunumdan önce canlı URL + GitHub repo linkini ödeve ekle. Uydurma test sonucu, sahte kaynak, tamamlanmamış özelliğe 'çalışıyor' deme.
