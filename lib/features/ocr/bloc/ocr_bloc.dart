import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

part 'ocr_event.dart';
part 'ocr_state.dart';

class OcrBloc extends Bloc<OcrEvent, OcrState> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  OcrBloc() : super(OcrInitial()) {
    on<ScanDocument>(_onScanDocument);
    on<ImportPdf>(_onImportPdf);
  }

  Future<void> _onScanDocument(ScanDocument event, Emitter<OcrState> emit) async {
    emit(OcrLoading());
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final inputImage = InputImage.fromFilePath(image.path);
        final recognizedText = await _textRecognizer.processImage(inputImage);
        final cleanText = _cleanText(recognizedText.text);
        emit(OcrSuccess(cleanText));
      } else {
        emit(const OcrError('No image selected'));
      }
    } catch (e) {
      emit(OcrError('Error scanning document: $e'));
    }
  }

  Future<void> _onImportPdf(ImportPdf event, Emitter<OcrState> emit) async {
    emit(OcrLoading());
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        // For prototype, return dummy text
        emit(const OcrSuccess('Dummy PDF text extracted'));
      } else {
        emit(const OcrError('No PDF selected'));
      }
    } catch (e) {
      emit(OcrError('Error importing PDF: $e'));
    }
  }

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Future<void> close() {
    _textRecognizer.close();
    return super.close();
  }
}
