import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/medicine_service.dart';

class MedicineProvider extends ChangeNotifier {
  final MedicineService _medicineService = MedicineService();
  List<Medicine> _medicines = [];
  DateTime? _notificationTime;
  bool _isLoading = false;

  List<Medicine> get medicines => _medicines;
  DateTime? get notificationTime => _notificationTime;
  bool get isLoading => _isLoading;

  // Başlangıçta verileri yükle
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _medicines = await _medicineService.getAllMedicines();
    _notificationTime = await _medicineService.getNotificationTime();

    _isLoading = false;
    notifyListeners();
  }

  // Yeni ilaç ekle
  Future<void> addMedicine(String name, int quantity) async {
    await _medicineService.addMedicine(name, quantity);
    _medicines = await _medicineService.getAllMedicines();
    notifyListeners();
  }

  // İlaç sil
  Future<void> deleteMedicine(String id) async {
    await _medicineService.deleteMedicine(id);
    _medicines = await _medicineService.getAllMedicines();
    notifyListeners();
  }

  // İlaç güncelle
  Future<void> updateMedicine(Medicine medicine) async {
    await _medicineService.updateMedicine(medicine);
    _medicines = await _medicineService.getAllMedicines();
    notifyListeners();
  }

    // İlacı ID'ye göre getir
  Future<Medicine?> getMedicineById(String id) async {
    _isLoading = true;
    notifyListeners();

    Medicine? medicine = _medicines.firstWhere((med) => med.id == id);

    _isLoading = false;
    notifyListeners();

    return medicine;
  }

  // Tüm ilaçların miktarını azalt
  Future<void> decreaseAllMedicines() async {
    await _medicineService.decreaseAllMedicines();
    _medicines = await _medicineService.getAllMedicines();
    notifyListeners();
  }

  // Bildirim saatini ayarla
  Future<void> setNotificationTime(DateTime time) async {
    await _medicineService.saveNotificationTime(time);
    _notificationTime = time;
    notifyListeners();
  }

  // Logları getir
  Future<List<String>> getLogs() async {
    return await _medicineService.getAllLogs();
  }

  // Verileri dışa aktar
  Future<String> exportData() async {
    return await _medicineService.exportData();
  }
}
