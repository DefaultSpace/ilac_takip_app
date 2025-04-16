# İlaç Takip Uygulaması

İlaç Takip, kullanıcıların ilaçlarını ve miktarlarını takip etmelerine, günlük bildirimler almalarına ve ilaç miktarı azaldığında uyarılar görmelerine olanak sağlayan bir Flutter uygulamasıdır.

## Özellikler

- **İlaç Yönetimi**: İlaçları ekleme, düzenleme ve silme
- **Otomatik Sayaç**: Her gün gece yarısında ilaç miktarlarını otomatik olarak azaltma
- **Bildirimler**: Kullanıcının belirlediği saatte günlük bildirimler
- **Sesli Uyarılar**: İlaç miktarları hakkında sesli bilgilendirme
- **Düşük Stok Uyarıları**: İlaç miktarı azaldığında görsel ve sesli uyarılar
- **Çoklu Dil Desteği**: Türkçe ve İngilizce dil seçenekleri
- **Veri Yedekleme**: İlaç verilerini ve ayarları JSON formatında dışa aktarma
- **İşlem Geçmişi**: Yapılan tüm işlemlerin kaydını tutma

## Kurulum

### Gereksinimler

- Flutter SDK (3.16.0 veya üzeri)
- Dart SDK (3.2.0 veya üzeri)
- Android Studio veya VS Code

### Adımlar

1. Projeyi klonlayın veya indirin:
```bash
git clone https://github.com/kullanici/ilac_takip.git
```

2. Proje dizinine gidin:
```bash
cd ilac_takip
```

3. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

4. Uygulamayı çalıştırın:
```bash
flutter run
```

## Kullanım

### İlaç Ekleme

1. Ana ekranda sağ alt köşedeki "+" butonuna tıklayın
2. İlaç adı ve miktar bilgilerini girin
3. "KAYDET" butonuna tıklayın

### Bildirim Saati Ayarlama

1. Sağ üst köşedeki ayarlar ikonuna tıklayın
2. "Bildirim Saati" bölümünde "Saat Seç" butonuna tıklayın
3. İstediğiniz saati seçin

### İlaç Miktarını Manuel Azaltma

1. Ayarlar ekranında "İLAÇLARI AZALT" butonuna tıklayın
2. Onay diyaloğunda "AZALT" butonuna tıklayın

### Verileri Yedekleme

1. Ayarlar ekranında "VERİLERİ YEDEKLE" butonuna tıklayın
2. Veriler cihazınızın indirilebilir dosyalar dizinine kaydedilecektir

## Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── models/
│   └── medicine_model.dart      # İlaç veri modeli
├── providers/
│   └── medicine_provider.dart   # Durum yönetimi
├── screens/
│   ├── home_screen.dart         # Ana ekran
│   ├── add_medicine_screen.dart # İlaç ekleme ekranı
│   ├── settings_screen.dart     # Ayarlar ekranı
│   └── logs_screen.dart         # İşlem geçmişi ekranı
├── services/
│   ├── medicine_service.dart    # İlaç verileri yönetimi
│   ├── notification_service.dart # Bildirim yönetimi
│   ├── text_to_speech_service.dart # Sesli uyarı yönetimi
│   ├── background_task_service.dart # Arka plan görevleri
│   └── backup_service.dart      # Veri yedekleme
└── localization/
    └── app_localizations.dart   # Çoklu dil desteği
```

## Kullanılan Paketler

- `shared_preferences`: Yerel veri depolama
- `flutter_local_notifications`: Bildirimler
- `flutter_tts`: Metin-konuşma dönüşümü
- `intl`: Tarih ve saat biçimlendirme
- `path_provider`: Dosya sistemi erişimi
- `provider`: Durum yönetimi
- `uuid`: Benzersiz kimlik oluşturma
- `timezone`: Zaman dilimi yönetimi

## Test Etme

Uygulamayı test etmek için `test_sureci.md` dosyasındaki adımları izleyin.

## APK Oluşturma

APK dosyası oluşturmak için:

```bash
flutter build apk --release
```

Oluşturulan APK dosyası `build/app/outputs/flutter-apk/app-release.apk` konumunda bulunacaktır.

## Notlar

- Uygulama, gece yarısında (00:00) otomatik olarak tüm ilaçların sayısını bir azaltır.
- İlaç miktarı 1'e düştüğünde, kırmızı renkli uyarılar gösterilir.
- Bildirimler ve sesli uyarılar, kullanıcının belirlediği saatte gösterilir.
- Uygulama tamamen çevrimdışı çalışır ve internet bağlantısı gerektirmez.

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakın.
