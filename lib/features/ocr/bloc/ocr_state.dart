part of 'ocr_bloc.dart';

abstract class OcrState {
  const OcrState();
}

class OcrInitial extends OcrState {}

class OcrLoading extends OcrState {}

class OcrSuccess extends OcrState {
  final String extractedText;
  const OcrSuccess(this.extractedText);
}

class OcrError extends OcrState {
  final String message;
  const OcrError(this.message);
}
