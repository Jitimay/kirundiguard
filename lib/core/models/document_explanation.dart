import 'package:hive/hive.dart';
import 'document_type.dart';

part 'document_explanation.g.dart';

@HiveType(typeId: 0)
class DocumentExplanation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String summaryRn;

  @HiveField(2)
  final List<DocumentSection> sectionsRn;

  @HiveField(3)
  final List<String> checklistRn;

  @HiveField(4)
  final String disclaimerRn;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String title;

  @HiveField(7)
  final SmartAnalysis? smartAnalysis;

  DocumentExplanation({
    required this.id,
    required this.summaryRn,
    required this.sectionsRn,
    required this.checklistRn,
    required this.disclaimerRn,
    required this.createdAt,
    required this.title,
    this.smartAnalysis,
  });

  factory DocumentExplanation.fromJson(Map<String, dynamic> json, {SmartAnalysis? smartAnalysis}) {
    return DocumentExplanation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      summaryRn: json['summary_rn'] ?? '',
      sectionsRn: (json['sections_rn'] as List?)
          ?.map((e) => DocumentSection.fromJson(e))
          .toList() ?? [],
      checklistRn: List<String>.from(json['checklist_rn'] ?? []),
      disclaimerRn: json['disclaimer_rn'] ?? '',
      createdAt: DateTime.now(),
      title: json['summary_rn']?.substring(0, 30) ?? 'Document',
      smartAnalysis: smartAnalysis,
    );
  }
}

@HiveType(typeId: 1)
class DocumentSection extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String text;

  DocumentSection({required this.title, required this.text});

  factory DocumentSection.fromJson(Map<String, dynamic> json) {
    return DocumentSection(
      title: json['title'] ?? '',
      text: json['text'] ?? '',
    );
  }
}
