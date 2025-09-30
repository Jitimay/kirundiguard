import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../models/document_explanation.dart';

class AiService {
  static const MethodChannel _channel = MethodChannel('kirundiguard/ai');
  late final Dio _dio;
  
  AiService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
  }
  
  // Use host machine's IP address for Android emulator
  String get _baseUrl => 'http://192.168.1.59:8000';

  Future<DocumentExplanation> generateExplanation(String text) async {
    try {
      print('🚀 Calling API: $_baseUrl/explain');
      print('📝 Text length: ${text.length}');
      
      final response = await _dio.post(
        '$_baseUrl/explain',
        data: {'text': text},
      );
      
      print('✅ API Success: ${response.statusCode}');
      return DocumentExplanation.fromJson(response.data);
    } catch (e) {
      print('❌ API Error: $e');
      // Fallback to dummy data if server fails
      return _getDummyExplanation();
    }
  }

  Future<DocumentExplanation> improveAccuracy(String text) async {
    try {
      print('🔄 Improving accuracy via API: $_baseUrl/explain');
      final response = await _dio.post(
        '$_baseUrl/explain',
        data: {'text': text},
      );
      print('✅ Accuracy API Success: ${response.statusCode}');
      return DocumentExplanation.fromJson(response.data);
    } catch (e) {
      print('❌ Accuracy API Error: $e');
      return _getDummyExplanation();
    }
  }

  DocumentExplanation _getDummyExplanation() {
    print('⚠️ Using dummy explanation (API failed)');
    return DocumentExplanation.fromJson({
      'summary_rn': 'Ibi bisobanuro by\'icyemezo cy\'ubwiyunge bw\'abaturage',
      'sections_rn': [
        {'title': 'Ibisobanuro', 'text': 'Iki cyemezo gishingiye ku mategeko y\'igihugu'},
        {'title': 'Inshingano', 'text': 'Abaturage bagomba kubahiriza amategeko yose'},
      ],
      'checklist_rn': [
        'Soma cyangwa umve inyandiko yose',
        'Baza ibibazo niba hari icyo utumva',
        'Kubana n\'abunganira mu mategeko niba bikenewe',
      ],
      'disclaimer_rn': 'Ibi si inama z\'abunganira mu mategeko.',
    });
  }
}
