import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;
  TextToSpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  // TTS servisini başlat
  Future<void> init() async {
    if (_isInitialized) return;

    // Türkçe dil ayarı
    await _flutterTts.setLanguage('tr-TR');
    
    // Ses ayarları
    await _flutterTts.setSpeechRate(0.5); // Konuşma hızı (0.0-1.0)
    await _flutterTts.setVolume(1.0); // Ses seviyesi (0.0-1.0)
    await _flutterTts.setPitch(1.0); // Ses tonu (0.5-2.0)

    _isInitialized = true;
  }

  // İlaç bildirimi için sesli uyarı
  Future<void> speakMedicineNotification(String medicineName, int quantity) async {
    await init();
    
    String message;
    if (quantity <= 1) {
      message = '$medicineName ilacından son 1 tane kaldı, ilacı yazdırmayı unutmayın.';
    } else {
      message = '$medicineName ilacından $quantity tane kaldı.';
    }
    
    await speak(message);
  }

  // Tüm ilaçlar için sesli bildirim
  Future<void> speakAllMedicines(List<Map<String, dynamic>> medicines) async {
    await init();
    
    for (final medicine in medicines) {
      final name = medicine['name'] as String;
      final quantity = medicine['quantity'] as int;
      
      await speakMedicineNotification(name, quantity);
      
      // Her ilaç arasında kısa bir bekleme
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Genel metni seslendir
  Future<void> speak(String text) async {
    await init();
    await _flutterTts.speak(text);
  }

  // Seslendirmeyi durdur
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  // Servis kapatılırken kaynakları temizle
  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
