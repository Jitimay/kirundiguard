import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

part 'ocr_event.dart';
part 'ocr_state.dart';

class OcrBloc extends Bloc<OcrEvent, OcrState> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _images = [];

  OcrBloc() : super(OcrInitial()) {
    on<ScanImage>(_onScanImage);
    on<AddPage>(_onAddPage);
    on<ProcessImages>(_onProcessImages);
    on<ImportPdf>(_onImportPdf);
  }

  Future<void> _onScanImage(ScanImage event, Emitter<OcrState> emit) async {
    emit(OcrLoading());
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _images.clear();
        _images.add(image);
        emit(OcrImageSelected(_images.length));
      } else {
        emit(OcrInitial());
      }
    } catch (e) {
      emit(OcrError('Error scanning document: $e'));
    }
  }

  Future<void> _onAddPage(AddPage event, Emitter<OcrState> emit) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _images.add(image);
        emit(OcrImageSelected(_images.length));
      }
    } catch (e) {
      emit(OcrError('Error adding page: $e'));
    }
  }

  Future<void> _onProcessImages(ProcessImages event, Emitter<OcrState> emit) async {
    emit(OcrLoading());
    try {
      final List<String> extractedTexts = [];
      for (final image in _images) {
        final inputImage = InputImage.fromFilePath(image.path);
        final recognizedText = await _textRecognizer.processImage(inputImage);
        final cleanText = _cleanText(recognizedText.text);
        extractedTexts.add(cleanText);
      }
      emit(OcrSuccess(extractedTexts));
      _images.clear();
    } catch (e) {
      emit(OcrError('Error processing images: $e'));
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
        emit(const OcrSuccess(['Dummy PDF text extracted']));
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
