import 'package:flutter_test/flutter_test.dart';

import 'package:g2k_gestion_recouvrement_creances_mobile/app/menu.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/models/current_user.dart';

void main() {
  test('le profil ADMIN ne voit que le menu Système', () {
    const admin = CurrentUser(
      id: '1',
      username: 'snr.admin',
      profil: 'ADMIN',
      roles: ['ADMIN'],
      permissions: ['admin.users', 'admin.params', 'audit.view', 'mandant.manage'],
    );

    final sections = sectionsVisibles(admin);

    expect(sections.map((section) => section.title), ['Système']);
    expect(
      sections.single.entries.map((entry) => entry.label),
      ['Administration', 'Utilisateurs', 'Profils et rôles', 'Mandants'],
    );
  });

  test('le profil AGENT voit le recouvrement mais pas les modules Système', () {
    const agent = CurrentUser(
      id: '2',
      username: 'snr.agent',
      profil: 'AGENT',
      roles: ['AGENT'],
      permissions: ['creance.view', 'action.log', 'doc.view'],
    );

    final sections = sectionsVisibles(agent);

    expect(sections.map((section) => section.title), [
      'Recouvrement',
      'Documents',
    ]);
    expect(
      sections.first.entries.map((entry) => libelleEntree(entry, agent)),
      [
        'Mon espace de travail',
        'Créances',
        'Débiteurs',
        'Échéanciers et accords',
      ],
    );
    expect(peutAccederChemin(agent, '/administration'), isFalse);
    expect(peutAccederChemin(agent, '/creances/C-1'), isTrue);
  });

  test('les profils de direction voient les modules de pilotage et utilisateurs', () {
    const dg = CurrentUser(
      id: '3',
      username: 'snr.dg',
      profil: 'DG',
      roles: ['DG'],
      permissions: ['dash.view', 'creance.view', 'report.view', 'doc.view'],
    );

    final sections = sectionsVisibles(dg);

    expect(sections.map((section) => section.title), contains('Pilotage'));
    expect(sections.map((section) => section.title), contains('Système'));
    expect(
      sections
          .firstWhere((section) => section.title == 'Système')
          .entries
          .map((entry) => entry.label),
      ['Utilisateurs'],
    );
    expect(peutVoirValidations(dg), isTrue);
  });
}
