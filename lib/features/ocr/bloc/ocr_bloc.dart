import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

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
    on<ProcessPdf>(_onProcessPdf);
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
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        emit(OcrPdfSelected(filePath, fileName));
      } else {
        emit(const OcrError('No PDF selected'));
      }
    } catch (e) {
      emit(OcrError('Error importing PDF: $e'));
    }
  }

  Future<void> _onProcessPdf(ProcessPdf event, Emitter<OcrState> emit) async {
    emit(OcrLoading());
    try {
      print('🔍 Processing PDF: ${event.filePath}');
      
      // Load the PDF document
      final File file = File(event.filePath);
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      final List<String> extractedTexts = [];
      
      // Extract text from each page
      for (int i = 0; i < document.pages.count; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        
        if (pageText.trim().isNotEmpty) {
          final cleanText = _cleanText(pageText);
          extractedTexts.add(cleanText);
          print('📄 Extracted text from page ${i + 1}: ${cleanText.length} characters');
        }
      }
      
      // Dispose the document
      document.dispose();
      
      if (extractedTexts.isEmpty) {
        emit(const OcrError('No text found in PDF. The PDF might be image-based or encrypted.'));
      } else {
        print('✅ Successfully extracted text from ${extractedTexts.length} pages');
        emit(OcrSuccess(extractedTexts));
      }
    } catch (e) {
      print('❌ Error processing PDF: $e');
      emit(OcrError('Error processing PDF: $e'));
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
