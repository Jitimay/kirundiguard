part of 'ocr_bloc.dart';

abstract class OcrEvent {}

class ScanImage extends OcrEvent {}

class AddPage extends OcrEvent {}

class ProcessImages extends OcrEvent {}


class ImportPdf extends OcrEvent {}
