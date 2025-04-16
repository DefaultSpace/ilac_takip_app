# İlaç Takip Uygulaması Test Süreci

Bu dokümanda, İlaç Takip uygulamasının test edilmesi için gerekli adımlar ve yöntemler Türkçe olarak açıklanmaktadır.

## 1. Kurulum ve Çalıştırma

Uygulamayı test etmek için öncelikle geliştirme ortamınızın hazır olduğundan emin olun:

```bash
# Flutter SDK'nın kurulu olduğunu kontrol edin
flutter --version

# Proje dizinine gidin
cd ilac_takip_app

# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

## 2. Test Edilecek Özellikler

### 2.1. İlaç Ekleme ve Listeleme

1. Ana ekranda sağ alt köşedeki "+" butonuna tıklayın.
2. İlaç adı ve miktar bilgilerini girin (örneğin: "Parasetamol", "10").
3. "KAYDET" butonuna tıklayın.
4. Ana ekrana döndüğünüzde, eklediğiniz ilacın listelendiğini kontrol edin.
5. Birkaç ilaç daha ekleyerek listeleme özelliğini test edin.

### 2.2. İlaç Düzenleme ve Silme

1. Ana ekranda listelenen bir ilacın yanındaki düzenleme (kalem) ikonuna tıklayın.
2. İlaç adını veya miktarını değiştirin ve "Kaydet" butonuna tıklayın.
3. Değişikliklerin ana ekranda görüntülendiğini kontrol edin.
4. Bir ilacın yanındaki silme (çöp kutusu) ikonuna tıklayın.
5. Onay diyaloğunda "Sil" butonuna tıklayın.
6. İlacın listeden kaldırıldığını kontrol edin.

### 2.3. Bildirim Ayarları

1. Ana ekranın sağ üst köşesindeki ayarlar ikonuna tıklayın.
2. "Bildirim Saati" bölümünde "Saat Seç" butonuna tıklayın.
3. Bir saat seçin ve "TAMAM" butonuna tıklayın.
4. Bildirim saatinin güncellendiğini kontrol edin.

### 2.4. İlaç Sayısını Manuel Azaltma

1. Ayarlar ekranında "İLAÇLARI AZALT" butonuna tıklayın.
2. Onay diyaloğunda "AZALT" butonuna tıklayın.
3. Ana ekrana dönün ve ilaç miktarlarının bir azaldığını kontrol edin.

### 2.5. Veri Yedekleme

1. Ayarlar ekranında "VERİLERİ YEDEKLE" butonuna tıklayın.
2. İşlem başarılı olduğunda bir bildirim gösterildiğini kontrol edin.

### 2.6. İşlem Geçmişi

1. Ana ekranın sağ üst köşesindeki geçmiş (saat) ikonuna tıklayın.
2. Yapılan işlemlerin (ilaç ekleme, silme, düzenleme, azaltma) geçmişte listelendiğini kontrol edin.

### 2.7. Düşük Stok Uyarıları

1. Bir ilacın miktarını 1'e düşürün (düzenleme veya azaltma yoluyla).
2. İlacın kırmızı renkle vurgulandığını ve "İlacı yazdırmayı unutmayın!" uyarısının gösterildiğini kontrol edin.

## 3. Otomatik Özellikler Testi

Aşağıdaki otomatik özelliklerin test edilmesi için uygulamanın belirli bir süre açık kalması veya belirli zamanlarda kontrol edilmesi gerekir:

### 3.1. Günlük İlaç Azaltma

Uygulama, gece yarısında (00:00) otomatik olarak tüm ilaçların sayısını bir azaltır. Bu özelliği test etmek için:

1. Cihazınızın saatini gece yarısına yakın bir zamana ayarlayın.
2. Uygulamayı açık bırakın ve gece yarısını geçtikten sonra ilaç miktarlarının azaldığını kontrol edin.

### 3.2. Bildirim ve Sesli Uyarılar

Ayarladığınız bildirim saatinde uygulamanın bildirim göstermesi ve sesli uyarı vermesi gerekir. Bu özelliği test etmek için:

1. Bildirim saatini, test sırasında birkaç dakika sonrasına ayarlayın.
2. Belirlenen saatte bildirimlerin gösterildiğini ve sesli uyarıların verildiğini kontrol edin.

## 4. Sorun Giderme

### 4.1. Bildirimler Çalışmıyor

- Cihazınızın bildirim ayarlarını kontrol edin ve uygulamaya bildirim izni verildiğinden emin olun.
- Ses ayarlarınızı kontrol edin ve medya sesinin açık olduğundan emin olun.

### 4.2. Sesli Uyarılar Çalışmıyor

- Cihazınızın ses ayarlarını kontrol edin.
- Uygulamaya mikrofon izni verildiğinden emin olun.
- Text-to-Speech motorunun cihazınızda düzgün çalıştığından emin olun.

### 4.3. Gece Yarısı Azaltma Çalışmıyor

- Uygulamanın arka planda çalışmasına izin verildiğinden emin olun.
- Pil optimizasyonu ayarlarını kontrol edin ve uygulamanın pil optimizasyonundan muaf tutulduğundan emin olun.

### 4.4. Uygulama Çöküyor veya Donuyor

- Uygulamayı kapatıp yeniden açın.
- Cihazınızı yeniden başlatın.
- Uygulamayı kaldırıp yeniden yükleyin (verilerinizi kaybetmemek için önce yedekleme yapın).

## 5. Performans Testi

Uygulamanın performansını test etmek için:

1. Çok sayıda ilaç ekleyin (örneğin 20-30 ilaç).
2. Ana ekranda kaydırma işleminin sorunsuz çalıştığını kontrol edin.
3. İlaç ekleme, düzenleme ve silme işlemlerinin hızlı ve sorunsuz çalıştığını kontrol edin.
4. Uygulamanın bellek kullanımını ve pil tüketimini izleyin.

## 6. Farklı Cihazlarda Test

Mümkünse, uygulamayı farklı Android sürümlerine ve ekran boyutlarına sahip cihazlarda test edin:

1. Küçük ekranlı telefonlar (5 inç ve altı)
2. Büyük ekranlı telefonlar (6 inç ve üzeri)
3. Tabletler
4. Farklı Android sürümleri (Android 5.0 ve üzeri)

## 7. APK Oluşturma ve Yükleme

Test sürecini tamamladıktan sonra, uygulamanın APK dosyasını oluşturmak için:

```bash
# APK oluşturma
flutter build apk

# APK dosyasının konumu
# build/app/outputs/flutter-apk/app-release.apk
```

Oluşturulan APK dosyasını Android cihazınıza yükleyerek son bir test yapabilirsiniz.

## 8. Test Sonuçları

Test sürecinde karşılaştığınız sorunları ve çözümleri not edin. Ayrıca, uygulamanın performansı, kullanıcı deneyimi ve işlevselliği hakkında geri bildirimlerinizi kaydedin.

Bu test süreci, İlaç Takip uygulamasının tüm özelliklerinin doğru çalıştığından emin olmanıza yardımcı olacaktır. Herhangi bir sorunla karşılaşırsanız, yukarıdaki sorun giderme adımlarını izleyin veya geliştirici ile iletişime geçin.
