part of 'smart_assistant_bloc.dart';

abstract class SmartAssistantEvent {}

class AnalyzeDocument extends SmartAssistantEvent {
  final String documentText;

  AnalyzeDocument(this.documentText);
}

class ProcessFollowUpQuery extends SmartAssistantEvent {
  final String query;

  ProcessFollowUpQuery(this.query);
}

class ResetAssistant extends SmartAssistantEvent {}