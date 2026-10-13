import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nexshow_admin/widgets/splash_overlay.dart';

void main() {
  testWidgets('Splash overlay renders the logo', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashOverlay()));
    await tester.pump();

    expect(find.byType(SplashOverlay), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
