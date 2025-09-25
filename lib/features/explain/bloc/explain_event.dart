part of 'explain_bloc.dart';

abstract class ExplainEvent {}

class GenerateExplanation extends ExplainEvent {
  final String text;
  GenerateExplanation(this.text);
}

class ImproveAccuracy extends ExplainEvent {
  final String text;
  ImproveAccuracy(this.text);
}
