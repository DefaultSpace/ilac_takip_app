import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine_model.dart';
import 'notification_service.dart';
import 'text_to_speech_service.dart';

class BackgroundTaskService {
  static final BackgroundTaskService _instance = BackgroundTaskService._internal();
  factory BackgroundTaskService() => _instance;
  BackgroundTaskService._internal();

  final NotificationService _notificationService = NotificationService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  
  Timer? _dailyTimer;
  Timer? _notificationTimer;
  
  // Servisi başlat
  Future<void> init() async {
    await _notificationService.init();
    await _ttsService.init();
    
    // Günlük ilaç azaltma işlemi için zamanlayıcı ayarla
    _setupDailyMedicineDecreaseTimer();
    
    // Bildirim zamanı kontrolü için zamanlayıcı ayarla
    _setupNotificationCheckTimer();
  }
  
  // Günlük ilaç azaltma işlemi için zamanlayıcı
  void _setupDailyMedicineDecreaseTimer() {
    // Mevcut zamanlayıcıyı iptal et
    _dailyTimer?.cancel();
    
    // Gece yarısına kaç saniye kaldığını hesapla
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final secondsUntilMidnight = midnight.difference(now).inSeconds;
    
    // Gece yarısında çalışacak zamanlayıcı ayarla
    _dailyTimer = Timer(Duration(seconds: secondsUntilMidnight), () {
      _decreaseAllMedicines();
      
      // Sonraki gün için tekrar zamanlayıcı ayarla (24 saat = 86400 saniye)
      _dailyTimer = Timer.periodic(const Duration(seconds: 86400), (_) {
        _decreaseAllMedicines();
      });
    });
  }
  
  // Bildirim zamanı kontrolü için zamanlayıcı
  void _setupNotificationCheckTimer() {
    // Mevcut zamanlayıcıyı iptal et
    _notificationTimer?.cancel();
    
    // Her dakika bildirim zamanını kontrol et
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkNotificationTime();
    });
  }
  
  // Tüm ilaçların miktarını azalt
  Future<void> _decreaseAllMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = prefs.getStringList('medicines') ?? [];
    
    if (medicinesJson.isEmpty) return;
    
    final List<Medicine> medicines = [];
    for (final json in medicinesJson) {
      try {
        final map = Map<String, dynamic>.from(
          Map.castFrom(jsonDecode(json) as Map)
        );
        medicines.add(Medicine.fromJson(map));
      } catch (e) {
        // ignore: avoid_print
        print('İlaç ayrıştırma hatası: $e');
      }
    }
    
    bool hasChanges = false;
    for (final medicine in medicines) {
      if (medicine.quantity > 0) {
        medicine.decreaseQuantity();
        hasChanges = true;
        
        // Eğer ilaç miktarı 1'e düştüyse düşük stok bildirimi gönder
        if (medicine.quantity == 1) {
          await _notificationService.showLowStockNotification(
            id: medicine.id.hashCode,
            medicineName: medicine.name,
          );
        }
      }
    }
    
    if (hasChanges) {
      final updatedMedicinesJson = medicines
          .map((medicine) => jsonEncode(medicine.toJson()))
          .toList();
      
      await prefs.setStringList('medicines', updatedMedicinesJson);
      
      // Log kaydı ekle
      final logs = prefs.getStringList('logs') ?? [];
      final timestamp = DateTime.now().toIso8601String();
      logs.add('$timestamp: Günlük ilaç miktarları azaltıldı');
      
      // Maksimum 100 log kaydı tut
      if (logs.length > 100) {
        logs.removeAt(0);
      }
      
      await prefs.setStringList('logs', logs);
    }
  }
  
  // Bildirim zamanını kontrol et
  Future<void> _checkNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationTimeString = prefs.getString('notification_time');
    
    if (notificationTimeString == null) return;
    
    try {
      final notificationTime = DateTime.parse(notificationTimeString);
      final now = DateTime.now();
      
      // Şu anki saat ve dakika, bildirim saati ve dakikasıyla eşleşiyorsa bildirimleri göster
      if (now.hour == notificationTime.hour && now.minute == notificationTime.minute) {
        await _showMedicineNotifications();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Bildirim zamanı kontrolü hatası: $e');
    }
  }
  
  // İlaç bildirimlerini göster
  Future<void> _showMedicineNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = prefs.getStringList('medicines') ?? [];
    
    if (medicinesJson.isEmpty) return;
    
    final List<Medicine> medicines = [];
    for (final json in medicinesJson) {
      try {
        final map = Map<String, dynamic>.from(
          Map.castFrom(jsonDecode(json) as Map)
        );
        medicines.add(Medicine.fromJson(map));
      } catch (e) {
        // ignore: avoid_print
        print('İlaç ayrıştırma hatası: $e');
      }
    }
    
    // TTS için ilaç listesi
    final List<Map<String, dynamic>> medicineDataForTts = [];
    
    // Her ilaç için bildirim göster
    for (int i = 0; i < medicines.length; i++) {
      final medicine = medicines[i];
      
      String notificationBody;
      if (medicine.quantity <= 1) {
        notificationBody = '${medicine.name} ilacından son 1 tane kaldı, ilacı yazdırmayı unutmayın!';
      } else {
        notificationBody = '${medicine.name} ilacından ${medicine.quantity} tane kaldı.';
      }
      
      await _notificationService.scheduleDailyNotification(
        id: 1000 + i, // Benzersiz ID
        title: 'İlaç Hatırlatması',
        body: notificationBody,
        scheduledTime: DateTime.now().add(const Duration(seconds: 5)), // 5 saniye sonra göster
      );
      
      medicineDataForTts.add({
        'name': medicine.name,
        'quantity': medicine.quantity,
      });
    }
    
    // Tüm ilaçlar için sesli bildirim
    await _ttsService.speakAllMedicines(medicineDataForTts);
  }
  
  // Servisi durdur
  void dispose() {
    _dailyTimer?.cancel();
    _notificationTimer?.cancel();
    _ttsService.dispose();
  }
}
