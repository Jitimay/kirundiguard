import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../core/models/document_type.dart';
import '../../../core/services/smart_assistant_service.dart';

part 'smart_assistant_event.dart';
part 'smart_assistant_state.dart';

class SmartAssistantBloc extends Bloc<SmartAssistantEvent, SmartAssistantState> {
  final SmartAssistantService _smartAssistantService;
  final Dio _dio = Dio();
  String? _currentDocumentText;
  SmartAnalysis? _currentAnalysis;
  
  // Backend URL - same as AI service
  String get _baseUrl => 'http://192.168.1.149:8000';

  SmartAssistantBloc(this._smartAssistantService) : super(SmartAssistantInitial()) {
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
      final responseText = response.data['response'] ?? 'No response available';
      
      emit(SmartAssistantQueryResponse(event.query, responseText));
    } catch (e) {
      print('❌ SmartAssistant: Query processing error: $e');
      
      // Fallback to local processing if backend fails
      try {
        final localResponse = _smartAssistantService.processFollowUpQuery(
          event.query,
          _currentDocumentText!,
          _currentAnalysis!,
        );
        print('🔄 SmartAssistant: Using local fallback');
        emit(SmartAssistantQueryResponse(event.query, localResponse));
      } catch (localError) {
        emit(SmartAssistantError('Failed to process query: $localError'));
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