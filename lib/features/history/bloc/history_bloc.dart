import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/document_explanation.dart';
import '../../../core/services/storage_service.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final StorageService _storageService;

  HistoryBloc(this._storageService) : super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
  }

  void _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) {
    try {
      final explanations = _storageService.getRecentExplanations();
      emit(HistoryLoaded(explanations));
    } catch (e) {
      emit(HistoryError('Error loading history: $e'));
    }
  }
}
