import 'package:flutter_test/flutter_test.dart';
import 'package:api_consumer/main.dart';

void main() {
  testWidgets('Smoke test - App runs and displays title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyAppOld());
    expect(find.byType(MyAppOld), findsOneWidget);
  });
}
