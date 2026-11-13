import 'package:material_ui/material_ui.dart';

import '../widgets/app_drawer.dart';

String titleForPath(String path) {
  if (path == '/') return 'Accueil';
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
      appBar: AppBar(title: Text(titleForPath(path))),
      drawer: AppDrawer(currentPath: path),
      body: child,
    );
  }
}
