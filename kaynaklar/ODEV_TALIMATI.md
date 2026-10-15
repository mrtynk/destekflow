# RUBY PROGRAMLAMA ÖDEV TALİMATI

## TESLİM VE SUNUM
19 Ekim 2026 Pazartesi, ders saatinde, sınıfta canlı sunum.
Linkler (canlı URL + GitHub repo) ders başlamadan önce bu ödeve eklenmiş olmalı.
Bireysel ödevdir. Grup çalışması yoktur.
Bu ödevin puanı sınav notu olarak sisteme girer.

## ÖN KOŞUL
Try Ruby ile temel Ruby seviyesi tamamlanmış kabul edilir. Derste bunun üzerine inşa ediyoruz; her an habersiz kısa sınav yapılabilir.
Ders slaytları ve dersin transkripti bu ödevin ekindedir. Önce ikisini okuyun.

## NEDEN BU ÖDEV
Bir Fortune 500 firması onlarca, yüzlerce SaaS ürününe yılda büyük paralar ödüyor. Bugünün coding agent'ları ile bu ürünlerin çekirdeğini kopyalamak ucuzladı. Bu hafta bunu kendiniz test edeceksiniz.
Ama asıl soru kopyalamak değil: o ürünün kullanıcısına "tam ayağına gelen pası" kim atacak? Ödevin 100 puanlık kısmı tam olarak burası.

## NE YAPACAKSINIZ

### 1) Faz 1 - Küçük araştırma (README'de, kaynaklı)
Fortune 500 firmaları için genel tablo, tek bir firma değil:
a. Değerleme aralığı (en küçük - en büyük)
b. Çalışan sayısı aralığı
c. Bir firmanın kullandığı SaaS ürünü sayısı (yaklaşık)
d. SaaS aboneliklerine yıllık ödenen para (yaklaşık)
Her rakamın yanında kaynağı olacak. Kaynaksız rakam yok sayılır.

### 2) SaaS seçimi
- En az bir Fortune 500 firmasının para ödediği bir SaaS seçin ve bunu kanıtlayın (link).
- Mümkünse çok sayıda Fortune 500 firmasının kullandığı bir ürünü seçin.
- Ölçek: yaklaşık 300.000 satır kod büyüklüğünde, gerçek bir kurumsal ürün. 10.000 satırlık oyuncak ürünlere talip olmayın.
- Örnekler: Zendesk (talep gelir, atanır, yanıtlanır, çözülür), Salesforce (aday müşteri bul, odaklan, paralı müşteriye dönüştür), Workday izin modülü, DocuSign, Greenhouse, Stripe Billing. Liste dışı seçim serbesttir.

### 3) Faz 2 - Maliyet tahmini (README'de)
- Seçtiğiniz SaaS'ın yaklaşık satır sayısı ve bu tahmini nasıl yaptığınız.
- Bu ürünün çekirdeğini bugünün coding agent'ları ile üretmek kaç dolar token/abonelik, kaç gün sürer? Kendi tahmininiz ve gerçekte harcadığınız.

### 4) Aort dilimi - canlıya alın
Ürünün tamamını değil, müşterinin o ürüne para ödemesinin asıl nedeni olan ana iş akışını (aort dilimi) uçtan uca çalışır hâle getirin.
- Ruby on Rails 8+ kullanılacak. Ajan, model ve araç serbest.
- Uygulama canlıda olacak. Daha önce kullanmadığınız bir deploy platformunu deneyin (ör. Render). "Hocam kendi bilgisayarımda göstereyim" = 0.
- Kendi ürün adınız ve logonuz olacak. Orijinal markanın adı ve logosu uygulamada görünmeyecek; sadece README'de "ilham kaynağı" olarak geçecek.
- Aort dilimi en az bir zaman kuralı (ör. SLA süresi, deneme süresinin bitmesi) ve bir durum akışı (ör. new > open > solved) içermeli.
- Ödeme alan bir dilim seçtiyseniz gerçek kart bilgisi toplamayın; test modu veya sahte sağlayıcı kullanın.

### 5) 100 puan için: kullanılabilir pas
Seçtiğiniz SaaS'ın gerçek kullanıcı yorumlarını okuyun (G2, Capterra, App Store vb.; linkleriyle). "Şunu yapıyor ama şunu yapamıyor" dedikleri bir acıyı bulun ve klonunuzda çözün.
Sunumda tek cümleyle söyleyebilmelisiniz: kimin acısı, hangi yorumdan, sizin çözümünüz ne.

## PUANLAMA
Sadece üç puan vardır: 0, 85, 100 ve üzeri. 84,9 veya 90 yoktur. Gidiş yolunuza, harcadığınız emeğe puan verilmez.

### 0 puan (aşağıdakilerden biri yeterli)
- Canlı URL yok
- Aort dilimi uçtan uca çalışmıyor
- Sunumda "var" denip çalışmayan bir özellik
- Ajanın uydurduğu, gerçekte çalıştırılmamış bir test raporu veya sonuç
- Orijinal marka adı veya logosu uygulamada

### 85 puan (hepsi)
- Fortune 500 kanıtı + Faz 1 ve Faz 2 cevapları README'de, kaynaklı
- Aort dilimi canlıda, uçtan uca çalışıyor
- Testler GitHub Actions'ta çalışıyor ve yeşil (rozet README'de)
- Zaman kuralı ve durum geçişi için testler var (travel_to kullanın)
- AGENT.md (ajanınızla birlikte siz ürettiniz; şablon verilmeyecek)
- README'de "Yapamadıklarım" bölümü

### 100 ve üzeri
- 85'in tamamı + kullanıcı yorumlarından gelen bir acının klonunuzda çözülmüş olması

Önemli: "Yapamadıklarım" listesine yazdığınız eksik puan düşürmez. Gizlediğiniz ve sunumda ortaya çıkan eksik notu sıfırlar. Ajanınız "yaptım" dediğinde siz kontrol etmeden inanmayın.

## SUNUM (5 dakika, canlı URL üzerinden)
1. Hangi SaaS, hangi aort dilimi, orijinaline kim neden para ödüyor (30 sn)
2. Canlı uygulamada aort dilimi baştan sona (2 dk)
3. Bir zaman kuralının ve bir durum geçişinin kodu (1 dk)
4. Çözdüğünüz kullanıcı acısı veya yapamadıklarınız (1 dk)
5. Kod yeri sorusu: bir kural değişikliği söyleyeceğim (ör. "SLA hafta sonunu saymasın"). Değişikliğin hangi dosya ve satıra dokunacağını göstereceksiniz; uygulamanız gerekmiyor (30 sn)

Herkesin tahtaya çıkması zorunlu değildir; ama sunum yapmayanın notu 0'dır.

## TESLİM EDİLECEKLER
- Canlı uygulama URL'si
- GitHub repo linki (README, AGENT.md, CI rozeti içinde)

Bir haftanız var. Hesaplarımıza göre bu iş 2-3 günde biter. Ona göre talip olun.
