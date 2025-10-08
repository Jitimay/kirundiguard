import 'package:hive/hive.dart';

part 'document_type.g.dart';

@HiveType(typeId: 2)
enum DocumentType {
  @HiveField(0)
  contract,
  @HiveField(1)
  law,
  @HiveField(2)
  idForm,
  @HiveField(3)
  governmentNotice,
  @HiveField(4)
  courtDocument,
  @HiveField(5)
  businessLicense,
  @HiveField(6)
  propertyDocument,
  @HiveField(7)
  unknown
}

@HiveType(typeId: 3)
class SmartAnalysis extends HiveObject {
  @HiveField(0)
  final DocumentType documentType;

  @HiveField(1)
  final double confidence;

  @HiveField(2)
  final List<String> keyTerms;

  @HiveField(3)
  final List<String> relevantSections;

  @HiveField(4)
  final List<String> suggestedQuestions;

  @HiveField(5)
  final Map<String, String> quickFacts;

  SmartAnalysis({
    required this.documentType,
    required this.confidence,
    required this.keyTerms,
    required this.relevantSections,
    required this.suggestedQuestions,
    required this.quickFacts,
  });

  factory SmartAnalysis.fromJson(Map<String, dynamic> json) {
    return SmartAnalysis(
      documentType: DocumentType.values.firstWhere(
        (e) => e.name == json['document_type'],
        orElse: () => DocumentType.unknown,
      ),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      keyTerms: List<String>.from(json['key_terms'] ?? []),
      relevantSections: List<String>.from(json['relevant_sections'] ?? []),
      suggestedQuestions: List<String>.from(json['suggested_questions'] ?? []),
      quickFacts: Map<String, String>.from(json['quick_facts'] ?? {}),
    );
  }
}

extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.contract:
        return 'Contract';
      case DocumentType.law:
        return 'Legal Document';
      case DocumentType.idForm:
        return 'ID/Form';
      case DocumentType.governmentNotice:
        return 'Government Notice';
      case DocumentType.courtDocument:
        return 'Court Document';
      case DocumentType.businessLicense:
        return 'Business License';
      case DocumentType.propertyDocument:
        return 'Property Document';
      case DocumentType.unknown:
        return 'Unknown Document';
    }
  }

  String get icon {
    switch (this) {
      case DocumentType.contract:
        return '📄';
      case DocumentType.law:
        return '⚖️';
      case DocumentType.idForm:
        return '🆔';
      case DocumentType.governmentNotice:
        return '🏛️';
      case DocumentType.courtDocument:
        return '🏛️';
      case DocumentType.businessLicense:
        return '🏢';
      case DocumentType.propertyDocument:
        return '🏠';
      case DocumentType.unknown:
        return '📋';
    }
  }
}