import 'package:material_ui/material_ui.dart';

import '../models/current_user.dart';

class DrawerEntry {
  final String path;
  final String label;
  final IconData icon;
  final List<String> permissions;
  final List<String> roles;
  final String? rule;

  const DrawerEntry(
    this.path,
    this.label,
    this.icon, {
    this.permissions = const <String>[],
    this.roles = const <String>[],
    this.rule,
  });
}

class DrawerSection {
  final String title;
  final List<DrawerEntry> entries;

  const DrawerSection(this.title, this.entries);
}

const List<DrawerSection> drawerSections = [
  DrawerSection('Pilotage', [
    DrawerEntry('/dashboard', 'Tableau de bord', Icons.dashboard_outlined,
        permissions: ['dash.view']),
    DrawerEntry('/validations', 'Validations', Icons.fact_check_outlined,
        rule: 'validations'),
    DrawerEntry('/rapports', 'Rapports', Icons.bar_chart_outlined,
        permissions: ['report.view']),
  ]),
  DrawerSection('Recouvrement', [
    DrawerEntry('/agent', 'Espace agents', Icons.badge_outlined,
        permissions: ['action.log']),
    DrawerEntry('/creances', 'Créances', Icons.account_balance_wallet_outlined,
        permissions: ['creance.view']),
    DrawerEntry('/debiteurs', 'Débiteurs', Icons.people_outline,
        permissions: ['creance.view']),
    DrawerEntry('/echeanciers', 'Échéanciers et accords', Icons.event_note_outlined,
        permissions: ['creance.view']),
  ]),
  DrawerSection('Finance', [
    DrawerEntry('/encaissements', 'Encaissements', Icons.payments_outlined,
        permissions: ['pay.record', 'pay.confirm']),
    DrawerEntry('/reversements', 'Reversements', Icons.compare_arrows_outlined,
        permissions: ['pay.allocate', 'pay.export']),
  ]),
  DrawerSection('Juridique', [
    DrawerEntry('/contentieux', 'Contentieux', Icons.gavel_outlined,
        permissions: ['legal.view']),
  ]),
  DrawerSection('Patrimoine', [
    DrawerEntry('/patrimoine', 'Garanties et patrimoine', Icons.apartment_outlined,
        permissions: ['asset.view']),
  ]),
  DrawerSection('Documents', [
    DrawerEntry('/documents', 'Documents et attestations', Icons.folder_open_outlined,
        permissions: ['doc.view']),
  ]),
  DrawerSection('Système', [
    DrawerEntry('/administration', 'Administration', Icons.admin_panel_settings_outlined,
        permissions: ['admin.users', 'audit.view']),
    DrawerEntry('/utilisateurs', 'Utilisateurs', Icons.manage_accounts_outlined,
        rule: 'annuaire', roles: ['ADMIN', 'DG', 'RESP_REC', 'AUDITEUR']),
    DrawerEntry('/profils', 'Profils et rôles', Icons.badge_outlined,
        permissions: ['admin.users']),
    DrawerEntry('/mandants', 'Mandants', Icons.apartment_outlined,
        permissions: ['mandant.manage']),
  ]),
  DrawerSection('Portails externes', [
    DrawerEntry('/portail-debiteur', 'Portail Débiteur', Icons.person_pin_circle_outlined,
        rule: 'portail-debiteur'),
    DrawerEntry('/portail-mandant', 'Portail Mandant', Icons.handshake_outlined,
        rule: 'portail-mandant'),
  ]),
];

const Set<String> modulesMasques = <String>{'/patrimoine'};

const List<String> profilsValidateurs = <String>[
  'RESP_REC',
  'DG',
  'JURIDIQUE',
  'COMPTABLE',
];

bool aPermission(CurrentUser? user, String permission) =>
    user != null && user.permissions.contains(permission);

bool aProfil(CurrentUser? user, String profil) {
  if (user == null) return false;
  final code = profil.toUpperCase();
  return user.profil.toUpperCase() == code ||
      user.roles.any((role) => role.toUpperCase() == code);
}

bool peutVoirValidations(CurrentUser? user) =>
    profilsValidateurs.any((profil) => aProfil(user, profil));

bool estEntreeVisible(DrawerEntry entry, CurrentUser? user) {
  if (user == null || modulesMasques.contains(entry.path)) return false;

  if (entry.rule == 'annuaire') {
    return aPermission(user, 'admin.users') ||
        entry.roles.any((profil) => aProfil(user, profil));
  }
  if (entry.rule == 'validations' && !peutVoirValidations(user)) return false;
  if (entry.rule == 'portail-debiteur' && !aProfil(user, 'DEBITEUR')) return false;
  if (entry.rule == 'portail-mandant' && !aProfil(user, 'MANDANT')) return false;

  if (entry.permissions.isNotEmpty &&
      !entry.permissions.any((permission) => aPermission(user, permission))) {
    return false;
  }
  if (entry.roles.isNotEmpty &&
      !entry.roles.any((profil) => aProfil(user, profil))) {
    return false;
  }
  return true;
}

List<DrawerSection> sectionsVisibles(CurrentUser? user) {
  return [
    for (final section in drawerSections)
      if (section.entries.any((entry) => estEntreeVisible(entry, user)))
        DrawerSection(
          section.title,
          section.entries.where((entry) => estEntreeVisible(entry, user)).toList(),
        ),
  ];
}

String libelleEntree(DrawerEntry entry, CurrentUser? user) {
  if (entry.path == '/agent' && aProfil(user, 'AGENT')) {
    return 'Mon espace de travail';
  }
  return entry.label;
}

bool peutAccederChemin(CurrentUser? user, String location) {
  if (location == '/home' || location == '/' || location == '/login') return true;
  final path = location.split(RegExp(r'[?#]')).first;

  if (path.startsWith('/attestations')) {
    return estEntreeVisible(
      drawerSections
          .expand((section) => section.entries)
          .firstWhere((entry) => entry.path == '/documents'),
      user,
    );
  }

  for (final entry in drawerSections.expand((section) => section.entries)) {
    if (path == entry.path || path.startsWith('${entry.path}/')) {
      return estEntreeVisible(entry, user);
    }
  }
  return true;
}
