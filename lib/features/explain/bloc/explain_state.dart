part of 'explain_bloc.dart';

abstract class ExplainState {}

class ExplainInitial extends ExplainState {}

class ExplainLoading extends ExplainState {}

class ExplainSuccess extends ExplainState {
  final DocumentExplanation explanation;
  ExplainSuccess(this.explanation);
}

class ExplainError extends ExplainState {
  final String message;
  ExplainError(this.message);
}
