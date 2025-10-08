// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentTypeAdapter extends TypeAdapter<DocumentType> {
  @override
  final int typeId = 2;

  @override
  DocumentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DocumentType.contract;
      case 1:
        return DocumentType.law;
      case 2:
        return DocumentType.idForm;
      case 3:
        return DocumentType.governmentNotice;
      case 4:
        return DocumentType.courtDocument;
      case 5:
        return DocumentType.businessLicense;
      case 6:
        return DocumentType.propertyDocument;
      case 7:
        return DocumentType.unknown;
      default:
        return DocumentType.unknown;
    }
  }

  @override
  void write(BinaryWriter writer, DocumentType obj) {
    switch (obj) {
      case DocumentType.contract:
        writer.writeByte(0);
        break;
      case DocumentType.law:
        writer.writeByte(1);
        break;
      case DocumentType.idForm:
        writer.writeByte(2);
        break;
      case DocumentType.governmentNotice:
        writer.writeByte(3);
        break;
      case DocumentType.courtDocument:
        writer.writeByte(4);
        break;
      case DocumentType.businessLicense:
        writer.writeByte(5);
        break;
      case DocumentType.propertyDocument:
        writer.writeByte(6);
        break;
      case DocumentType.unknown:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SmartAnalysisAdapter extends TypeAdapter<SmartAnalysis> {
  @override
  final int typeId = 3;

  @override
  SmartAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmartAnalysis(
      documentType: fields[0] as DocumentType,
      confidence: fields[1] as double,
      keyTerms: (fields[2] as List).cast<String>(),
      relevantSections: (fields[3] as List).cast<String>(),
      suggestedQuestions: (fields[4] as List).cast<String>(),
      quickFacts: (fields[5] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SmartAnalysis obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.documentType)
      ..writeByte(1)
      ..write(obj.confidence)
      ..writeByte(2)
      ..write(obj.keyTerms)
      ..writeByte(3)
      ..write(obj.relevantSections)
      ..writeByte(4)
      ..write(obj.suggestedQuestions)
      ..writeByte(5)
      ..write(obj.quickFacts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}