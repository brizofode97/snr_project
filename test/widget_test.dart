import 'package:flutter_test/flutter_test.dart';

import 'package:g2k_gestion_recouvrement_creances_mobile/main.dart';

void main() {
  testWidgets('L\'application démarre sur l\'écran d\'accueil', (WidgetTester tester) async {
    await tester.pumpWidget(const SnrMobileApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue sur SNR 360'), findsOneWidget);
  });
}
