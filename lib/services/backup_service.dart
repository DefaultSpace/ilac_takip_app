import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  // Verileri JSON formatında dışa aktar
  Future<String> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // İlaç verileri
    final medicinesJson = prefs.getStringList('medicines') ?? [];
    final medicines = medicinesJson.map((json) => jsonDecode(json)).toList();
    
    // Log kayıtları
    final logs = prefs.getStringList('logs') ?? [];
    
    // Bildirim saati
    final notificationTimeString = prefs.getString('notification_time');
    
    // Dil ayarı
    final language = prefs.getString('language') ?? 'tr';
    
    // Tüm verileri içeren JSON
    final exportData = {
      'medicines': medicines,
      'logs': logs,
      'notification_time': notificationTimeString,
      'language': language,
      'export_date': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
    };
    
    return jsonEncode(exportData);
  }
  
  // Verileri dosyaya kaydet
  Future<String> saveBackupToFile() async {
    try {
      final jsonData = await exportData();
      
      // İndirilebilir dosyalar dizinini al
      final directory = await getExternalStorageDirectory() ?? 
                        await getApplicationDocumentsDirectory();
      
      // Dosya adı oluştur (tarih ve saat ile)
      final now = DateTime.now();
      final fileName = 'ilac_takip_yedek_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.json';
      
      // Dosya yolu
      final filePath = '${directory.path}/$fileName';
      
      // Dosyaya yaz
      final file = File(filePath);
      await file.writeAsString(jsonData);
      
      return filePath;
    } catch (e) {
      throw Exception('Yedekleme hatası: $e');
    }
  }
  
  // Yedekten verileri geri yükle
  Future<bool> restoreFromJson(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      
      // İlaç verileri
      if (data.containsKey('medicines') && data['medicines'] is List) {
        final medicines = (data['medicines'] as List)
            .map((item) => jsonEncode(item))
            .toList()
            .cast<String>();
        await prefs.setStringList('medicines', medicines);
      }
      
      // Log kayıtları
      if (data.containsKey('logs') && data['logs'] is List) {
        final logs = (data['logs'] as List).cast<String>();
        await prefs.setStringList('logs', logs);
      }
      
      // Bildirim saati
      if (data.containsKey('notification_time') && data['notification_time'] != null) {
        await prefs.setString('notification_time', data['notification_time'] as String);
      }
      
      // Dil ayarı
      if (data.containsKey('language') && data['language'] != null) {
        await prefs.setString('language', data['language'] as String);
      }
      
      return true;
    } catch (e) {
      throw Exception('Geri yükleme hatası: $e');
    }
  }
  
  // Dosyadan verileri geri yükle
  Future<bool> restoreFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonData = await file.readAsString();
      return await restoreFromJson(jsonData);
    } catch (e) {
      throw Exception('Dosyadan geri yükleme hatası: $e');
    }
  }
}
