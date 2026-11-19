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
      user: const CurrentUser(
        id: '1',
        username: 'agent',
        profil: 'AGENT',
        permissions: ['report.view', 'creance.view'],
      ),
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

  testWidgets('la page Accueil ouvre et ferme le menu latéral', (tester) async {
    AuthService.instance.session.value = AuthSession(
      accessToken: 'token',
      user: const CurrentUser(
        id: '1',
        username: 'snr.admin',
        profil: 'ADMIN',
        roles: ['ADMIN'],
        permissions: ['admin.users', 'admin.params', 'audit.view', 'mandant.manage'],
      ),
    );
    navigationHistory.reset();

    await tester.pumpWidget(const SnrMobileApp());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Retour'), findsNothing);
    expect(find.byTooltip('Ouvrir le menu'), findsOneWidget);

    await tester.tap(find.byTooltip('Ouvrir le menu'));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
    final drawer = find.byType(Drawer);
    expect(find.descendant(of: drawer, matching: find.text('SYSTÈME')), findsOneWidget);
    expect(
      find.descendant(of: drawer, matching: find.text('Profils et rôles')),
      findsOneWidget,
    );
    expect(find.descendant(of: drawer, matching: find.text('Mandants')), findsOneWidget);
    expect(find.descendant(of: drawer, matching: find.text('Créances')), findsNothing);
    expect(find.byTooltip('Fermer le menu'), findsOneWidget);

    await tester.tap(find.byTooltip('Fermer le menu'));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);
    expect(find.byTooltip('Ouvrir le menu'), findsOneWidget);
  });

  testWidgets('une page de détail affiche un bouton de retour', (tester) async {
    AuthService.instance.session.value = AuthSession(
      accessToken: 'token',
      user: const CurrentUser(
        id: '1',
        username: 'admin',
        profil: 'ADMIN',
        permissions: ['admin.users'],
      ),
    );

    await tester.pumpWidget(const SnrMobileApp());
    await tester.pumpAndSettle();

    appRouter.push('/utilisateurs/nouveau');
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsWidgets);
  });
}
