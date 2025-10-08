import '../models/document_type.dart';
import 'package:dio/dio.dart';

class SmartAssistantService {
  late final Dio _dio;

  SmartAssistantService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  String get _baseUrl => 'http://192.168.1.149:8000';
  static const Map<DocumentType, List<String>> _documentKeywords = {
    DocumentType.contract: [
      'contract', 'agreement', 'party', 'obligation', 'terms', 'conditions',
      'payment', 'delivery', 'breach', 'termination', 'signature', 'witness'
    ],
    DocumentType.law: [
      'article', 'section', 'law', 'regulation', 'statute', 'code',
      'shall', 'must', 'prohibited', 'penalty', 'fine', 'imprisonment'
    ],
    DocumentType.idForm: [
      'identity', 'passport', 'license', 'registration', 'application',
      'birth certificate', 'national id', 'voter', 'form', 'number'
    ],
    DocumentType.governmentNotice: [
      'notice', 'announcement', 'government', 'ministry', 'department',
      'public', 'citizen', 'deadline', 'requirement', 'procedure'
    ],
    DocumentType.courtDocument: [
      'court', 'judge', 'plaintiff', 'defendant', 'case', 'hearing',
      'verdict', 'appeal', 'evidence', 'witness', 'testimony', 'ruling'
    ],
    DocumentType.businessLicense: [
      'license', 'permit', 'business', 'trade', 'commerce', 'registration',
      'tax', 'revenue', 'authority', 'valid', 'expire', 'renewal'
    ],
    DocumentType.propertyDocument: [
      'property', 'land', 'title', 'deed', 'ownership', 'transfer',
      'mortgage', 'lease', 'rent', 'boundary', 'survey', 'plot'
    ],
  };

  static const Map<DocumentType, List<String>> _suggestedQuestions = {
    DocumentType.contract: [
      'What are my main obligations?',
      'When do I need to make payments?',
      'What happens if I breach this contract?',
      'How can I terminate this agreement?',
      'What are the penalties mentioned?'
    ],
    DocumentType.law: [
      'How does this law affect me?',
      'What are the penalties for violation?',
      'When does this law take effect?',
      'Who is responsible for enforcement?',
      'Are there any exemptions?'
    ],
    DocumentType.idForm: [
      'What documents do I need to provide?',
      'How long does processing take?',
      'What are the fees involved?',
      'Where do I submit this form?',
      'What happens after submission?'
    ],
    DocumentType.governmentNotice: [
      'What action do I need to take?',
      'What is the deadline?',
      'Who does this notice apply to?',
      'What are the consequences of non-compliance?',
      'Where can I get more information?'
    ],
    DocumentType.courtDocument: [
      'What is my role in this case?',
      'When is the next hearing?',
      'What evidence do I need?',
      'Can I appeal this decision?',
      'What are my legal rights?'
    ],
    DocumentType.businessLicense: [
      'What business activities does this cover?',
      'When does this license expire?',
      'What are the renewal requirements?',
      'What are the operating conditions?',
      'What taxes do I need to pay?'
    ],
    DocumentType.propertyDocument: [
      'What are the property boundaries?',
      'What are my ownership rights?',
      'Are there any restrictions?',
      'What taxes are applicable?',
      'How can I transfer ownership?'
    ],
  };

  /// Analyzes document text to determine type and extract key information
  SmartAnalysis analyzeDocument(String text) {
    final lowercaseText = text.toLowerCase();
    final words = lowercaseText.split(RegExp(r'\W+'));
    
    DocumentType bestMatch = DocumentType.unknown;
    double highestScore = 0.0;
    List<String> foundKeywords = [];

    // Score each document type based on keyword matches
    for (final entry in _documentKeywords.entries) {
      final keywords = entry.value;
      final matches = keywords.where((keyword) => 
        lowercaseText.contains(keyword.toLowerCase())).toList();
      
      final score = matches.length / keywords.length;
      
      if (score > highestScore) {
        highestScore = score;
        bestMatch = entry.key;
        foundKeywords = matches;
      }
    }

    // Extract relevant sections based on document type
    final relevantSections = _extractRelevantSections(text, bestMatch);
    
    // Generate quick facts
    final quickFacts = _generateQuickFacts(text, bestMatch);

    return SmartAnalysis(
      documentType: bestMatch,
      confidence: highestScore,
      keyTerms: foundKeywords,
      relevantSections: relevantSections,
      suggestedQuestions: _suggestedQuestions[bestMatch] ?? [],
      quickFacts: quickFacts,
    );
  }

  /// Extracts relevant sections based on document type
  List<String> _extractRelevantSections(String text, DocumentType type) {
    final sections = <String>[];
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    switch (type) {
      case DocumentType.contract:
        sections.addAll(_findSections(lines, ['payment', 'obligation', 'term', 'condition']));
        break;
      case DocumentType.law:
        sections.addAll(_findSections(lines, ['article', 'section', 'penalty', 'fine']));
        break;
      case DocumentType.idForm:
        sections.addAll(_findSections(lines, ['requirement', 'document', 'fee', 'process']));
        break;
      case DocumentType.governmentNotice:
        sections.addAll(_findSections(lines, ['deadline', 'requirement', 'procedure', 'contact']));
        break;
      case DocumentType.courtDocument:
        sections.addAll(_findSections(lines, ['hearing', 'evidence', 'ruling', 'appeal']));
        break;
      case DocumentType.businessLicense:
        sections.addAll(_findSections(lines, ['condition', 'validity', 'renewal', 'fee']));
        break;
      case DocumentType.propertyDocument:
        sections.addAll(_findSections(lines, ['boundary', 'ownership', 'restriction', 'tax']));
        break;
      case DocumentType.unknown:
        // Extract first few meaningful lines
        sections.addAll(lines.take(3));
        break;
    }

    return sections.take(5).toList();
  }

  /// Finds lines containing specific keywords
  List<String> _findSections(List<String> lines, List<String> keywords) {
    final relevantLines = <String>[];
    
    for (final line in lines) {
      final lowercaseLine = line.toLowerCase();
      if (keywords.any((keyword) => lowercaseLine.contains(keyword))) {
        relevantLines.add(line.trim());
      }
    }
    
    return relevantLines;
  }

  /// Generates quick facts based on document type
  Map<String, String> _generateQuickFacts(String text, DocumentType type) {
    final facts = <String, String>{};
    final lowercaseText = text.toLowerCase();

    switch (type) {
      case DocumentType.contract:
        if (lowercaseText.contains('payment')) {
          facts['Payment Terms'] = 'Payment terms are specified in this contract';
        }
        if (lowercaseText.contains('termination')) {
          facts['Termination'] = 'Contract includes termination clauses';
        }
        break;
      case DocumentType.law:
        if (lowercaseText.contains('penalty') || lowercaseText.contains('fine')) {
          facts['Penalties'] = 'This law includes penalty provisions';
        }
        if (lowercaseText.contains('effective')) {
          facts['Effective Date'] = 'Law has specific effective date';
        }
        break;
      case DocumentType.idForm:
        if (lowercaseText.contains('fee') || lowercaseText.contains('cost')) {
          facts['Fees Required'] = 'This form requires payment of fees';
        }
        if (lowercaseText.contains('document')) {
          facts['Supporting Documents'] = 'Additional documents required';
        }
        break;
      default:
        facts['Document Type'] = type.displayName;
        break;
    }

    return facts;
  }

  /// Processes follow-up questions via API
  Future<String> processFollowUpQuery(String query, String originalText, SmartAnalysis analysis) async {
    try {
      print('🤖 Calling follow-up API: $_baseUrl/follow-up');
      
      final response = await _dio.post(
        '$_baseUrl/follow-up',
        data: {
          'query': query,
          'original_text': originalText,
          'document_type': analysis.documentType,
        },
      );

      print('✅ Follow-up API Success: ${response.statusCode}');
      return response.data['response'] ?? 'Ntabwo nasobanuye neza ikibazo cyawe.';
    } catch (e) {
      print('❌ Follow-up API Error: $e');
      return _getLocalResponse(query, originalText, analysis);
    }
  }

  /// Local fallback processing
  String _getLocalResponse(String query, String originalText, SmartAnalysis analysis) {
    final lowercaseQuery = query.toLowerCase();
    final lowercaseText = originalText.toLowerCase();

    // Simple rule-based responses
    if (lowercaseQuery.contains('article') && lowercaseQuery.contains('mean')) {
      return _findArticleExplanation(query, originalText);
    }
    
    if (lowercaseQuery.contains('obligation') || lowercaseQuery.contains('responsibility')) {
      return _findObligations(originalText, analysis.documentType);
    }
    
    if (lowercaseQuery.contains('penalty') || lowercaseQuery.contains('fine')) {
      return _findPenalties(originalText);
    }
    
    if (lowercaseQuery.contains('deadline') || lowercaseQuery.contains('when')) {
      return _findDeadlines(originalText);
    }
    
    if (lowercaseQuery.contains('fee') || lowercaseQuery.contains('cost')) {
      return _findFees(originalText);
    }

    // Default response
    return 'I understand you\'re asking about "${query}". Based on the document type (${analysis.documentType.displayName}), I recommend reviewing the relevant sections I\'ve highlighted above.';
  }

  String _findArticleExplanation(String query, String text) {
    // Extract article number from query
    final articleMatch = RegExp(r'article\s+(\d+)', caseSensitive: false).firstMatch(query);
    if (articleMatch != null) {
      final articleNum = articleMatch.group(1);
      final lines = text.split('\n');
      
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].toLowerCase().contains('article $articleNum')) {
          // Return the article and next few lines
          final explanation = lines.skip(i).take(3).join(' ').trim();
          return 'Article $articleNum states: $explanation';
        }
      }
    }
    
    return 'I couldn\'t find the specific article you mentioned. Please check the document for the exact article number.';
  }

  String _findObligations(String text, DocumentType type) {
    final lines = text.split('\n');
    final obligations = <String>[];
    
    for (final line in lines) {
      final lowercaseLine = line.toLowerCase();
      if (lowercaseLine.contains('shall') || 
          lowercaseLine.contains('must') || 
          lowercaseLine.contains('obligation') ||
          lowercaseLine.contains('responsible')) {
        obligations.add(line.trim());
      }
    }
    
    if (obligations.isNotEmpty) {
      return 'Your main obligations include: ${obligations.take(3).join('; ')}';
    }
    
    return 'No specific obligations were clearly identified in this document.';
  }

  String _findPenalties(String text) {
    final lines = text.split('\n');
    final penalties = <String>[];
    
    for (final line in lines) {
      final lowercaseLine = line.toLowerCase();
      if (lowercaseLine.contains('penalty') || 
          lowercaseLine.contains('fine') || 
          lowercaseLine.contains('punishment')) {
        penalties.add(line.trim());
      }
    }
    
    if (penalties.isNotEmpty) {
      return 'Penalties mentioned: ${penalties.take(2).join('; ')}';
    }
    
    return 'No specific penalties were found in this document.';
  }

  String _findDeadlines(String text) {
    final lines = text.split('\n');
    final deadlines = <String>[];
    
    for (final line in lines) {
      final lowercaseLine = line.toLowerCase();
      if (lowercaseLine.contains('deadline') || 
          lowercaseLine.contains('due') || 
          lowercaseLine.contains('before') ||
          lowercaseLine.contains('within')) {
        deadlines.add(line.trim());
      }
    }
    
    if (deadlines.isNotEmpty) {
      return 'Important deadlines: ${deadlines.take(2).join('; ')}';
    }
    
    return 'No specific deadlines were clearly mentioned in this document.';
  }

  String _findFees(String text) {
    final lines = text.split('\n');
    final fees = <String>[];
    
    for (final line in lines) {
      final lowercaseLine = line.toLowerCase();
      if (lowercaseLine.contains('fee') || 
          lowercaseLine.contains('cost') || 
          lowercaseLine.contains('payment') ||
          lowercaseLine.contains('amount')) {
        fees.add(line.trim());
      }
    }
    
    if (fees.isNotEmpty) {
      return 'Fees and costs: ${fees.take(2).join('; ')}';
    }
    
    return 'No specific fees or costs were mentioned in this document.';
  }
}