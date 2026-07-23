import 'package:flutter_test/flutter_test.dart';
import 'package:finswitch/app/app.dart';

void main() {
  testWidgets('App builds without crashing', (tester) async {
    await tester.pumpWidget(const FinSwitchApp());
    await tester.pump();
    expect(find.byType(FinSwitchApp), findsOneWidget);
  });
}
