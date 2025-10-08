part of 'smart_assistant_bloc.dart';

abstract class SmartAssistantState {
  const SmartAssistantState();
}

class SmartAssistantInitial extends SmartAssistantState {}

class SmartAssistantAnalyzing extends SmartAssistantState {}

class SmartAssistantAnalysisComplete extends SmartAssistantState {
  final SmartAnalysis analysis;

  const SmartAssistantAnalysisComplete(this.analysis);
}

class SmartAssistantProcessingQuery extends SmartAssistantState {}

class SmartAssistantQueryResponse extends SmartAssistantState {
  final String query;
  final String response;

  const SmartAssistantQueryResponse(this.query, this.response);
}

class SmartAssistantError extends SmartAssistantState {
  final String message;

  const SmartAssistantError(this.message);
}