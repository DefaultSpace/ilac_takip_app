import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine_model.dart';
import 'package:uuid/uuid.dart';

class MedicineService {
  static const String MEDICINES_KEY = 'medicines';
  static const String NOTIFICATION_TIME_KEY = 'notification_time';
  static const String LOGS_KEY = 'logs';
  
  // Tüm ilaçları getir
  Future<List<Medicine>> getAllMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = prefs.getStringList(MEDICINES_KEY) ?? [];
    
    return medicinesJson
        .map((json) => Medicine.fromJson(jsonDecode(json)))
        .toList();
  }
  
  // Yeni ilaç ekle
  Future<void> addMedicine(String name, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = prefs.getStringList(MEDICINES_KEY) ?? [];
    
    final medicine = Medicine(
      id: const Uuid().v4(),
      name: name,
      quantity: quantity,
      addedDate: DateTime.now(),
    );
    
    medicinesJson.add(jsonEncode(medicine.toJson()));
    await prefs.setStringList(MEDICINES_KEY, medicinesJson);
    
    // Log kaydı ekle
    await addLog('$name eklendi: $quantity adet');
  }
  
  // İlaç sil
  Future<void> deleteMedicine(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = prefs.getStringList(MEDICINES_KEY) ?? [];
    
    final medicines = medicinesJson
        .map((json) => Medicine.fromJson(jsonDecode(json)))
        .toList();
    
    final medicineToDelete = medicines.firstWhere((med) => med.id == id);
    medicines.removeWhere((med) => med.id == id);
    
    final updatedMedicinesJson = medicines
        .map((medicine) => jsonEncode(medicine.toJson()))
        .toList();
    
    await prefs.setStringList(MEDICINES_KEY, updatedMedicinesJson);
    
    // Log kaydı ekle
    await addLog('${medicineToDelete.name} silindi');
  }
  
  // İlaç güncelle
  Future<void> updateMedicine(Medicine medicine) async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = prefs.getStringList(MEDICINES_KEY) ?? [];
    
    final medicines = medicinesJson
        .map((json) => Medicine.fromJson(jsonDecode(json)))
        .toList();
    
    final oldQuantity = medicines
        .firstWhere((med) => med.id == medicine.id)
        .quantity;
    
    final index = medicines.indexWhere((med) => med.id == medicine.id);
    if (index != -1) {
      medicines[index] = medicine;
      
      final updatedMedicinesJson = medicines
          .map((medicine) => jsonEncode(medicine.toJson()))
          .toList();
      
      await prefs.setStringList(MEDICINES_KEY, updatedMedicinesJson);
      
      // Log kaydı ekle
      await addLog('${medicine.name}: $oldQuantity -> ${medicine.quantity}');
    }
  }
  
  // Tüm ilaçların miktarını azalt
  Future<void> decreaseAllMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = prefs.getStringList(MEDICINES_KEY) ?? [];
    
    final medicines = medicinesJson
        .map((json) => Medicine.fromJson(jsonDecode(json)))
        .toList();
    
    for (var medicine in medicines) {
      if (medicine.quantity > 0) {
        medicine.decreaseQuantity();
        await addLog('${medicine.name}: ${medicine.quantity + 1} -> ${medicine.quantity}');
      }
    }
    
    final updatedMedicinesJson = medicines
        .map((medicine) => jsonEncode(medicine.toJson()))
        .toList();
    
    await prefs.setStringList(MEDICINES_KEY, updatedMedicinesJson);
  }
  
  // Bildirim saatini kaydet
  Future<void> saveNotificationTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(NOTIFICATION_TIME_KEY, time.toIso8601String());
  }
  
  // Bildirim saatini getir
  Future<DateTime?> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(NOTIFICATION_TIME_KEY);
    
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    
    return null;
  }
  
  // Log kaydı ekle
  Future<void> addLog(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList(LOGS_KEY) ?? [];
    
    final timestamp = DateTime.now().toIso8601String();
    logs.add('$timestamp: $message');
    
    // Maksimum 100 log kaydı tut
    if (logs.length > 100) {
      logs.removeAt(0);
    }
    
    await prefs.setStringList(LOGS_KEY, logs);
  }
  
  // Tüm logları getir
  Future<List<String>> getAllLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(LOGS_KEY) ?? [];
  }
  
  // Verileri JSON olarak dışa aktar
  Future<String> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = prefs.getStringList(MEDICINES_KEY) ?? [];
    final logs = prefs.getStringList(LOGS_KEY) ?? [];
    final notificationTimeString = prefs.getString(NOTIFICATION_TIME_KEY);
    
    final exportData = {
      'medicines': medicinesJson.map((json) => jsonDecode(json)).toList(),
      'logs': logs,
      'notification_time': notificationTimeString,
    };
    
    return jsonEncode(exportData);
  }
}
