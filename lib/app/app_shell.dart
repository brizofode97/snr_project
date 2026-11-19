import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/auth/auth_service.dart';
import '../widgets/app_drawer.dart';
import 'menu.dart';
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

class AppShell extends StatefulWidget {
  final String path;
  final Widget child;

  const AppShell({super.key, required this.path, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _menuOuvert = false;

  void _basculerMenu() => setState(() => _menuOuvert = !_menuOuvert);

  void _fermerMenu() => setState(() => _menuOuvert = false);

  Future<void> _deconnecter(BuildContext context) async {
    final router = GoRouter.of(context);
    await AuthService.instance.logout();
    navigationHistory.reset();
    router.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.path;
    final estAccueil = path == '/home';
    final largeurMenu =
        (MediaQuery.sizeOf(context).width * 0.82).clamp(0.0, 304.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        leading: estAccueil
            ? IconButton(
                tooltip: _menuOuvert ? 'Fermer le menu' : 'Ouvrir le menu',
                icon: Icon(_menuOuvert ? Icons.close : Icons.menu),
                onPressed: _basculerMenu,
              )
            : const _RetourButton(),
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
      drawer: estAccueil ? null : AppDrawer(currentPath: path),
      body: PopScope(
        canPop: !_menuOuvert,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _menuOuvert) _fermerMenu();
        },
        child: Stack(
          children: [
            widget.child,
            if (_menuOuvert) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: _fermerMenu,
                  child: Container(color: Colors.black54),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                top: 0,
                bottom: 0,
                left: 0,
                width: largeurMenu,
                child: AppDrawer(currentPath: path, onFermer: _fermerMenu),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RetourButton extends StatelessWidget {
  const _RetourButton();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return IconButton(
      tooltip: 'Retour',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        final precedente = navigationHistory.pop();
        router.go(precedente ?? '/home');
      },
    );
  }
}
