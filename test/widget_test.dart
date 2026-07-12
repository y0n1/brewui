import 'package:flutter_test/flutter_test.dart';

import 'package:brewui/main.dart';

void main() {
  testWidgets('BrewUI scaffold smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrewUiApp());

    expect(find.text('BrewUI'), findsOneWidget);
  });
}
