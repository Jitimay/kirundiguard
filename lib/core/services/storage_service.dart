import 'package:hive_flutter/hive_flutter.dart';
import '../models/document_explanation.dart';

class StorageService {
  static const String _boxName = 'explanations';
  late Box<DocumentExplanation> _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DocumentExplanationAdapter());
    Hive.registerAdapter(DocumentSectionAdapter());
    _box = await Hive.openBox<DocumentExplanation>(_boxName);
  }

  Future<void> saveExplanation(DocumentExplanation explanation) async {
    await _box.put(explanation.id, explanation);
    await _cleanupOldEntries();
  }

  List<DocumentExplanation> getRecentExplanations() {
    final explanations = _box.values.toList();
    explanations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return explanations.take(5).toList();
  }

  Future<void> _cleanupOldEntries() async {
    final explanations = _box.values.toList();
    if (explanations.length > 5) {
      explanations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (int i = 0; i < explanations.length - 5; i++) {
        await _box.delete(explanations[i].id);
      }
    }
  }
}
