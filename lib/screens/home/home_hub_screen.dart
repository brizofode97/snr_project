import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../widgets/app_drawer.dart';

class HomeHubScreen extends StatelessWidget {
  const HomeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [snrGradientStart, snrAccent],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue sur SNR 360',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Maquette de navigation — toutes les pages sont accessibles librement, sans connexion.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (final section in drawerSections) ...[
          Text(section.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              for (final entry in section.entries) _ShortcutCard(entry: entry),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final DrawerEntry entry;

  const _ShortcutCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go(entry.path),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(entry.icon, color: snrPrimary),
              const SizedBox(height: 8),
              Text(
                entry.label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
