part of 'history_bloc.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<DocumentExplanation> explanations;
  HistoryLoaded(this.explanations);
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}
