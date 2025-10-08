import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../core/models/document_type.dart';
import '../../../core/services/smart_assistant_service.dart';

part 'smart_assistant_event.dart';
part 'smart_assistant_state.dart';

class SmartAssistantBloc extends Bloc<SmartAssistantEvent, SmartAssistantState> {
  final SmartAssistantService _smartAssistantService;
  late final Dio _dio;
  String? _currentDocumentText;
  SmartAnalysis? _currentAnalysis;
  
  // Backend URL - same as AI service
  String get _baseUrl => 'http://192.168.1.149:8000';

  SmartAssistantBloc(this._smartAssistantService) : super(SmartAssistantInitial()) {
    // Configure Dio with proper timeouts
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60), // Increased for follow-up queries
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    on<AnalyzeDocument>(_onAnalyzeDocument);
    on<ProcessFollowUpQuery>(_onProcessFollowUpQuery);
    on<ResetAssistant>(_onResetAssistant);
  }

  Future<void> _onAnalyzeDocument(
    AnalyzeDocument event,
    Emitter<SmartAssistantState> emit,
  ) async {
    emit(SmartAssistantAnalyzing());
    
    try {
      print('🤖 SmartAssistant: Analyzing document...');
      
      final analysis = _smartAssistantService.analyzeDocument(event.documentText);
      _currentDocumentText = event.documentText;
      _currentAnalysis = analysis;
      
      print('🤖 SmartAssistant: Document type detected: ${analysis.documentType.displayName}');
      print('🤖 SmartAssistant: Confidence: ${(analysis.confidence * 100).toStringAsFixed(1)}%');
      
      emit(SmartAssistantAnalysisComplete(analysis));
    } catch (e) {
      print('❌ SmartAssistant: Analysis error: $e');
      emit(SmartAssistantError('Failed to analyze document: $e'));
    }
  }

  Future<void> _onProcessFollowUpQuery(
    ProcessFollowUpQuery event,
    Emitter<SmartAssistantState> emit,
  ) async {
    if (_currentDocumentText == null || _currentAnalysis == null) {
      emit(const SmartAssistantError('No document analyzed yet'));
      return;
    }

    emit(SmartAssistantProcessingQuery());
    
    try {
      print('🤖 SmartAssistant: Processing query: ${event.query}');
      print('📡 SmartAssistant: Sending request to backend...');
      
      // Send request to backend API
      final response = await _dio.post(
        '$_baseUrl/follow-up',
        data: {
          'query': event.query,
          'original_text': _currentDocumentText!,
          'document_type': _currentAnalysis!.documentType.name,
        },
      );
      
      print('✅ SmartAssistant: Backend response received');
      print('📄 SmartAssistant: Response data: ${response.data}');
      final responseText = response.data['response'] ?? 'No response available';
      print('💬 SmartAssistant: Extracted response: $responseText');
      
      emit(SmartAssistantQueryResponse(event.query, responseText));
    } catch (e) {
      print('❌ SmartAssistant: Query processing error: $e');
      
      String errorMessage = 'Failed to process query';
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            errorMessage = 'Connection timeout - please check your network';
            break;
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Response timeout - server is taking too long';
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'Connection error - please check if backend is running';
            break;
          default:
            errorMessage = 'Network error: ${e.message}';
        }
      }
      
      // Fallback to local processing if backend fails
      try {
        print('🔄 SmartAssistant: Backend failed, using local fallback');
        final localResponse = _smartAssistantService.processFollowUpQuery(
          event.query,
          _currentDocumentText!,
          _currentAnalysis!,
        );
        print('✅ SmartAssistant: Local fallback successful');
        emit(SmartAssistantQueryResponse(event.query, localResponse as String));
      } catch (localError) {
        print('❌ SmartAssistant: Local fallback also failed: $localError');
        emit(SmartAssistantError('$errorMessage. Local processing also failed.'));
      }
    }
  }

  void _onResetAssistant(
    ResetAssistant event,
    Emitter<SmartAssistantState> emit,
  ) {
    _currentDocumentText = null;
    _currentAnalysis = null;
    emit(SmartAssistantInitial());
  }
}