// This is a basic Flutter widget test for ReelsDown App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:dowload/main.dart';

void main() {
  testWidgets('ReelsDown app launches smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TikTokDownloaderApp());

    // Verify that the app launches and shows the main screen
    expect(find.text('Descargador TikTok'), findsOneWidget);
    expect(find.text('Descargar Videos TikTok'), findsOneWidget);

    // Verify navigation bar exists
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
  });
}
