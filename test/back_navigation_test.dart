import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:g2k_gestion_recouvrement_creances_mobile/app/navigation_history.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/app/router.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/core/auth/auth_service.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/core/auth/auth_session.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/main.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/models/current_user.dart';

void main() {
  testWidgets('le bouton Retour ramène à la page précédente', (tester) async {
    AuthService.instance.session.value = AuthSession(
      accessToken: 'token',
      user: const CurrentUser(id: '1', username: 'agent', profil: 'Agent'),
    );
    navigationHistory.reset();

    await tester.pumpWidget(const SnrMobileApp());
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue sur SNR 360'), findsOneWidget);

    navigationHistory.push('/home');
    appRouter.go('/rapports');
    await tester.pumpAndSettle();
    expect(find.text('Rapports'), findsWidgets);

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue sur SNR 360'), findsOneWidget);
  });

  testWidgets('une page de détail affiche un bouton de retour', (tester) async {
    AuthService.instance.session.value = AuthSession(
      accessToken: 'token',
      user: const CurrentUser(id: '1', username: 'agent', profil: 'Agent'),
    );

    await tester.pumpWidget(const SnrMobileApp());
    await tester.pumpAndSettle();

    appRouter.push('/utilisateurs/nouveau');
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsWidgets);
  });
}
