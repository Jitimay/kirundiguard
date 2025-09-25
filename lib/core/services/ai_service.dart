import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../models/document_explanation.dart';

class AiService {
  static const MethodChannel _channel = MethodChannel('kirundiguard/ai');
  final Dio _dio = Dio();

  Future<DocumentExplanation> generateExplanation(String text) async {
    try {
      final result = await _channel.invokeMethod('generateExplanation', {'text': text});
      return DocumentExplanation.fromJson(Map<String, dynamic>.from(result));
    } catch (e) {
      // Return dummy data if method channel fails
      return _getDummyExplanation();
    }
  }

  Future<DocumentExplanation> improveAccuracy(String text) async {
    try {
      final response = await _dio.post(
        'https://api.example.com/explain',
        data: {'text': text},
      );
      return DocumentExplanation.fromJson(response.data);
    } catch (e) {
      return _getDummyExplanation();
    }
  }

  DocumentExplanation _getDummyExplanation() {
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
