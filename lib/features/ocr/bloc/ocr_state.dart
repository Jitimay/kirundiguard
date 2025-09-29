part of 'ocr_bloc.dart';

abstract class OcrState {
  const OcrState();
}

class OcrInitial extends OcrState {}

class OcrImageSelected extends OcrState {
  final int imageCount;
  const OcrImageSelected(this.imageCount);
}


class OcrLoading extends OcrState {}

class OcrSuccess extends OcrState {
  final List<String> extractedTexts;
  const OcrSuccess(this.extractedTexts);
}

class OcrError extends OcrState {
  final String message;
  const OcrError(this.message);
}
