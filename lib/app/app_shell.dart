import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/auth/auth_service.dart';
import '../widgets/app_drawer.dart';
import 'navigation_history.dart';

String titleForPath(String path) {
  if (path == '/home') return 'Accueil';
  for (final section in drawerSections) {
    for (final entry in section.entries) {
      if (path.startsWith(entry.path)) return entry.label;
    }
  }
  return 'SNR 360';
}

class AppShell extends StatelessWidget {
  final String path;
  final Widget child;

  const AppShell({super.key, required this.path, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _RetourButton(estAccueil: path == '/home'),
        title: Text(titleForPath(path)),
        actions: [
          ValueListenableBuilder(
            valueListenable: AuthService.instance.session,
            builder: (context, session, _) {
              final user = session?.user;
              if (user == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Tooltip(
                  message: '${user.displayName} · ${user.profil}',
                  child: CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: () => _deconnecter(context),
          ),
        ],
      ),
      drawer: AppDrawer(currentPath: path),
      body: child,
    );
  }

  Future<void> _deconnecter(BuildContext context) async {
    final router = GoRouter.of(context);
    await AuthService.instance.logout();
    navigationHistory.reset();
    router.go('/login');
  }
}

class _RetourButton extends StatelessWidget {
  final bool estAccueil;

  const _RetourButton({required this.estAccueil});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final peutRevenir = navigationHistory.canGoBack || !estAccueil;
    return IconButton(
      tooltip: 'Retour',
      icon: const Icon(Icons.arrow_back),
      onPressed: peutRevenir
          ? () {
              final precedente = navigationHistory.pop();
              router.go(precedente ?? '/home');
            }
          : null,
    );
  }
}
