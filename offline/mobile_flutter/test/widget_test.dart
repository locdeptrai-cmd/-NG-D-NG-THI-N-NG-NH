import 'package:flutter_test/flutter_test.dart';

import 'package:atc_offline_mobile/main.dart';

void main() {
  testWidgets('app boots to start page', (WidgetTester tester) async {
    await tester.pumpWidget(const OfflineExamApp());
    expect(find.text('Thi thử offline'), findsOneWidget);
  });
}
