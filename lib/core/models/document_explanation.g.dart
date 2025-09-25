// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_explanation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentExplanationAdapter extends TypeAdapter<DocumentExplanation> {
  @override
  final int typeId = 0;

  @override
  DocumentExplanation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentExplanation(
      id: fields[0] as String,
      summaryRn: fields[1] as String,
      sectionsRn: (fields[2] as List).cast<DocumentSection>(),
      checklistRn: (fields[3] as List).cast<String>(),
      disclaimerRn: fields[4] as String,
      createdAt: fields[5] as DateTime,
      title: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentExplanation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.summaryRn)
      ..writeByte(2)
      ..write(obj.sectionsRn)
      ..writeByte(3)
      ..write(obj.checklistRn)
      ..writeByte(4)
      ..write(obj.disclaimerRn)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentExplanationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentSectionAdapter extends TypeAdapter<DocumentSection> {
  @override
  final int typeId = 1;

  @override
  DocumentSection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentSection(
      title: fields[0] as String,
      text: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentSection obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentSectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
