part of 'ocr_bloc.dart';

abstract class OcrEvent {}

class ScanDocument extends OcrEvent {}

class ImportPdf extends OcrEvent {}
