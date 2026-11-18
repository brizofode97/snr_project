import 'package:flutter_test/flutter_test.dart';

import 'package:g2k_gestion_recouvrement_creances_mobile/core/auth/auth_service.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/main.dart';

void main() {
  testWidgets('un visiteur non connecté voit la page d’accueil publique', (
    WidgetTester tester,
  ) async {
    AuthService.instance.session.value = null;

    await tester.pumpWidget(const SnrMobileApp());
    await tester.pumpAndSettle();

    expect(find.text('SNR 360'), findsWidgets);
    expect(find.text('Société Nationale de Recouvrement'), findsWidgets);
    expect(find.text('Accéder à mon espace'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Bienvenue sur SNR 360'), findsNothing);
  });
}
