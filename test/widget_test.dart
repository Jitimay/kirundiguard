import 'package:flutter_test/flutter_test.dart';
import 'package:kirundiguard/main.dart';
import 'package:kirundiguard/core/services/storage_service.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final storageService = StorageService();
    await storageService.initialize();
    
    await tester.pumpWidget(MyApp(storageService: storageService));

    expect(find.text('Scan Document'), findsOneWidget);
    expect(find.text('Import PDF'), findsOneWidget);
  });
}
