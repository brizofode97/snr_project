import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../app/navigation_history.dart';
import '../app/theme.dart';
import '../core/auth/auth_service.dart';

class DrawerEntry {
  final String path;
  final String label;
  final IconData icon;

  const DrawerEntry(this.path, this.label, this.icon);
}

class DrawerSection {
  final String title;
  final List<DrawerEntry> entries;

  const DrawerSection(this.title, this.entries);
}

const List<DrawerSection> drawerSections = [
  DrawerSection('Pilotage', [
    DrawerEntry('/dashboard', 'Tableau de bord', Icons.dashboard_outlined),
    DrawerEntry('/rapports', 'Rapports', Icons.bar_chart_outlined),
    DrawerEntry('/validations', 'Validations', Icons.fact_check_outlined),
  ]),
  DrawerSection('Gestion des créances', [
    DrawerEntry('/creances', 'Créances', Icons.account_balance_wallet_outlined),
    DrawerEntry('/debiteurs', 'Débiteurs', Icons.people_outline),
    DrawerEntry('/echeanciers', 'Échéanciers', Icons.event_note_outlined),
  ]),
  DrawerSection('Finance', [
    DrawerEntry('/encaissements', 'Encaissements', Icons.payments_outlined),
    DrawerEntry('/reversements', 'Reversements', Icons.compare_arrows_outlined),
  ]),
  DrawerSection('Juridique & Patrimoine', [
    DrawerEntry('/contentieux', 'Contentieux', Icons.gavel_outlined),
    DrawerEntry('/patrimoine', 'Patrimoine', Icons.apartment_outlined),
  ]),
  DrawerSection('Documents', [
    DrawerEntry('/documents', 'Documents & attestations', Icons.folder_open_outlined),
  ]),
  DrawerSection('Organisation', [
    DrawerEntry('/agent', 'Espace agent', Icons.badge_outlined),
    DrawerEntry('/utilisateurs', 'Utilisateurs', Icons.manage_accounts_outlined),
    DrawerEntry('/administration', 'Administration', Icons.admin_panel_settings_outlined),
  ]),
  DrawerSection('Portails externes', [
    DrawerEntry('/portail-debiteur', 'Portail Débiteur', Icons.person_pin_circle_outlined),
    DrawerEntry('/portail-mandant', 'Portail Mandant', Icons.handshake_outlined),
  ]),
];

class AppDrawer extends StatelessWidget {
  final String currentPath;

  const AppDrawer({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ValueListenableBuilder(
              valueListenable: AuthService.instance.session,
              builder: (context, session, _) {
                final user = session?.user;
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [snrGradientStart, snrAccent],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          user == null
                              ? '360'
                              : user.displayName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'SNR 360',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              user == null
                                  ? 'Recouvrement des créances'
                                  : '${user.profil} · ${user.email ?? user.username}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Accueil'),
              selected: currentPath == '/home',
              onTap: () => _navigate(context, '/home'),
            ),
            for (final section in drawerSections) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  section.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              for (final entry in section.entries)
                ListTile(
                  leading: Icon(entry.icon),
                  title: Text(entry.label),
                  selected: currentPath == entry.path,
                  onTap: () => _navigate(context, entry.path),
                ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Se déconnecter'),
              onTap: () => _deconnecter(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String path) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    navigationHistory.push(currentPath);
    router.go(path);
  }

  Future<void> _deconnecter(BuildContext context) async {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    await AuthService.instance.logout();
    navigationHistory.reset();
    router.go('/login');
  }
}
