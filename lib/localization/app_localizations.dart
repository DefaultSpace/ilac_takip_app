import 'dart:async';

class AppLocalizations {
  static final AppLocalizations _instance = AppLocalizations._internal();
  factory AppLocalizations() => _instance;
  AppLocalizations._internal();

  // Varsayılan dil
  String _currentLanguage = 'tr';

  // Dil değişikliği için stream controller
  final _controller = StreamController<String>.broadcast();
  Stream<String> get onLanguageChanged => _controller.stream;

  // Mevcut dili al
  String get currentLanguage => _currentLanguage;

  // Dili değiştir
  void setLanguage(String languageCode) {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      _controller.add(languageCode);
    }
  }

  // Çeviriler
  final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      // Ana ekran
      'app_title': 'İlaç Takip',
      'no_medicines': 'Henüz ilaç eklenmemiş',
      'add_medicine': 'İlaç Ekle',
      'remaining_quantity': 'Kalan miktar',
      'low_stock_warning': 'İlacı yazdırmayı unutmayın!',
      'edit': 'Düzenle',
      'delete': 'Sil',
      
      // İlaç ekleme ekranı
      'add_medicine_title': 'İlaç Ekle',
      'medicine_name': 'İlaç Adı',
      'quantity': 'Miktar',
      'please_enter_name': 'Lütfen ilaç adını girin',
      'please_enter_quantity': 'Lütfen miktar girin',
      'enter_valid_quantity': 'Geçerli bir miktar girin',
      'save': 'KAYDET',
      'cancel': 'İptal',
      
      // Ayarlar ekranı
      'settings': 'Ayarlar',
      'notification_time': 'Bildirim Saati',
      'notification_description': 'Belirlediğiniz saatte günlük ilaç bildirimleri alacaksınız.',
      'notification_time_set': 'Bildirim saati: ',
      'notification_time_not_set': 'Bildirim saati ayarlanmadı',
      'select_time': 'Saat Seç',
      'decrease_medicines': 'İlaç Sayısını Azalt',
      'decrease_description': 'Tüm ilaçların sayısını manuel olarak azaltmak için bu butonu kullanabilirsiniz.',
      'decrease_button': 'İLAÇLARI AZALT',
      'backup_data': 'Verileri Yedekle',
      'backup_description': 'Tüm ilaç verilerinizi ve ayarlarınızı JSON formatında dışa aktarın.',
      'backup_button': 'VERİLERİ YEDEKLE',
      'about_app': 'Uygulama Hakkında',
      'about_description': 'İlaç Takip uygulaması, ilaçlarınızı takip etmenize ve zamanında hatırlatmalar almanıza yardımcı olur.',
      'version': 'Sürüm: 1.0.0',
      'language': 'Dil',
      'language_description': 'Uygulama dilini değiştirin.',
      'turkish': 'Türkçe',
      'english': 'İngilizce',
      
      // Log ekranı
      'logs': 'İşlem Geçmişi',
      'no_logs': 'Henüz işlem geçmişi bulunmuyor',
      'refresh': 'Yenile',
      'invalid_log_format': 'Geçersiz log formatı',
      'unknown_date': 'Bilinmeyen tarih',
      
      // Bildirimler
      'medicine_notification': 'İlaç Hatırlatması',
      'medicine_remaining': ' ilacından  tane kaldı.',
      'medicine_last_one': ' ilacından son 1 tane kaldı, ilacı yazdırmayı unutmayın!',
      'low_stock_alert': 'Düşük İlaç Stoku Uyarısı',
      
      // Diyaloglar
      'edit_medicine': 'İlaç Düzenle',
      'delete_medicine': 'İlacı Sil',
      'delete_confirmation': ' ilacını silmek istediğinize emin misiniz?',
      'decrease_confirmation': 'Tüm ilaçların sayısını bir azaltmak istediğinize emin misiniz?',
      'decrease_success': 'Tüm ilaçların sayısı azaltıldı',
      'backup_success': 'Veriler başarıyla dışa aktarıldı',
      'notification_updated': 'Bildirim saati güncellendi',
      'error': 'Hata: ',
    },
    'en': {
      // Main screen
      'app_title': 'Medicine Tracker',
      'no_medicines': 'No medicines added yet',
      'add_medicine': 'Add Medicine',
      'remaining_quantity': 'Remaining quantity',
      'low_stock_warning': 'Don\'t forget to prescribe!',
      'edit': 'Edit',
      'delete': 'Delete',
      
      // Add medicine screen
      'add_medicine_title': 'Add Medicine',
      'medicine_name': 'Medicine Name',
      'quantity': 'Quantity',
      'please_enter_name': 'Please enter medicine name',
      'please_enter_quantity': 'Please enter quantity',
      'enter_valid_quantity': 'Enter a valid quantity',
      'save': 'SAVE',
      'cancel': 'Cancel',
      
      // Settings screen
      'settings': 'Settings',
      'notification_time': 'Notification Time',
      'notification_description': 'You will receive daily medicine notifications at the time you set.',
      'notification_time_set': 'Notification time: ',
      'notification_time_not_set': 'Notification time not set',
      'select_time': 'Select Time',
      'decrease_medicines': 'Decrease Medicine Count',
      'decrease_description': 'Use this button to manually decrease the count of all medicines.',
      'decrease_button': 'DECREASE MEDICINES',
      'backup_data': 'Backup Data',
      'backup_description': 'Export all your medicine data and settings in JSON format.',
      'backup_button': 'BACKUP DATA',
      'about_app': 'About App',
      'about_description': 'Medicine Tracker app helps you track your medicines and receive timely reminders.',
      'version': 'Version: 1.0.0',
      'language': 'Language',
      'language_description': 'Change application language.',
      'turkish': 'Turkish',
      'english': 'English',
      
      // Logs screen
      'logs': 'Activity History',
      'no_logs': 'No activity history yet',
      'refresh': 'Refresh',
      'invalid_log_format': 'Invalid log format',
      'unknown_date': 'Unknown date',
      
      // Notifications
      'medicine_notification': 'Medicine Reminder',
      'medicine_remaining': ' medicine has  remaining.',
      'medicine_last_one': ' medicine has only 1 remaining, don\'t forget to prescribe!',
      'low_stock_alert': 'Low Medicine Stock Alert',
      
      // Dialogs
      'edit_medicine': 'Edit Medicine',
      'delete_medicine': 'Delete Medicine',
      'delete_confirmation': 'Are you sure you want to delete  medicine?',
      'decrease_confirmation': 'Are you sure you want to decrease the count of all medicines by one?',
      'decrease_success': 'All medicine counts decreased',
      'backup_success': 'Data successfully exported',
      'notification_updated': 'Notification time updated',
      'error': 'Error: ',
    },
  };

  // Çeviri al
  String translate(String key) {
    if (_localizedValues[_currentLanguage]?.containsKey(key) ?? false) {
      return _localizedValues[_currentLanguage]![key]!;
    }
    
    // Eğer çeviri bulunamazsa, varsayılan dilde ara
    if (_currentLanguage != 'tr' && (_localizedValues['tr']?.containsKey(key) ?? false)) {
      return _localizedValues['tr']![key]!;
    }
    
    // Hiçbir çeviri bulunamazsa, anahtarı döndür
    return key;
  }

  // Kaynakları temizle
  void dispose() {
    _controller.close();
  }
}
