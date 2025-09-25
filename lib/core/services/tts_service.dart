import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _tts.setLanguage('rn');
    final languages = await _tts.getLanguages;
    
    if (!languages.contains('rn')) {
      await _tts.setLanguage('sw-KE');
    }
    
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    await initialize();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
