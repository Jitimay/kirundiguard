import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/document_explanation.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/storage_service.dart';

part 'explain_event.dart';
part 'explain_state.dart';

class ExplainBloc extends Bloc<ExplainEvent, ExplainState> {
  final AiService _aiService;
  final StorageService _storageService;

  ExplainBloc(this._aiService, this._storageService) : super(ExplainInitial()) {
    on<GenerateExplanation>(_onGenerateExplanation);
    on<ImproveAccuracy>(_onImproveAccuracy);
  }

  Future<void> _onGenerateExplanation(
    GenerateExplanation event,
    Emitter<ExplainState> emit,
  ) async {
    emit(ExplainLoading());
    try {
      final explanation = await _aiService.generateExplanation(event.text);
      await _storageService.saveExplanation(explanation);
      emit(ExplainSuccess(explanation));
    } catch (e) {
      emit(ExplainError('Error generating explanation: $e'));
    }
  }

  Future<void> _onImproveAccuracy(
    ImproveAccuracy event,
    Emitter<ExplainState> emit,
  ) async {
    emit(ExplainLoading());
    try {
      final explanation = await _aiService.improveAccuracy(event.text);
      await _storageService.saveExplanation(explanation);
      emit(ExplainSuccess(explanation));
    } catch (e) {
      emit(ExplainError('Error improving accuracy: $e'));
    }
  }
}
