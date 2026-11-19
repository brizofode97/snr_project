import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../app/menu.dart';
import '../app/navigation_history.dart';
import '../app/theme.dart';
import '../core/auth/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final String currentPath;
  final VoidCallback? onFermer;

  const AppDrawer({super.key, required this.currentPath, this.onFermer});

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
            for (final section in sectionsVisibles(AuthService.instance.currentUser)) ...[
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
                  title: Text(libelleEntree(
                      entry, AuthService.instance.currentUser)),
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

  void _fermer(BuildContext context) {
    final onFermer = this.onFermer;
    if (onFermer != null) {
      onFermer();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _navigate(BuildContext context, String path) {
    final router = GoRouter.of(context);
    _fermer(context);
    navigationHistory.push(currentPath);
    router.go(path);
  }

  Future<void> _deconnecter(BuildContext context) async {
    final router = GoRouter.of(context);
    _fermer(context);
    await AuthService.instance.logout();
    navigationHistory.reset();
    router.go('/login');
  }
}
