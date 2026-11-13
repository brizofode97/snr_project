import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../widgets/empty_placeholder.dart';

class AdministrationScreen extends StatelessWidget {
  const AdministrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.primary,
            child: const TabBar(
              tabs: [
                Tab(text: 'Paramètres métier'),
                Tab(text: 'Journal d\'audit'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _ParametresTab(),
                _JournalAuditTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParametresTab extends StatelessWidget {
  const _ParametresTab();

  @override
  Widget build(BuildContext context) {
    final parametres = [
      ('Délai de grâce', '15 jours'),
      ('Seuil d\'inactivité', '30 jours'),
      ('Fréquence des relances', 'Hebdomadaire'),
      ('Règle d\'imputation', 'Frais puis intérêts puis principal'),
      ('Pièces obligatoires', 'CNI / NINEA + justificatif de créance'),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: parametres.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final (label, value) = parametres[index];
        return Card(
          child: ListTile(
            title: Text(label),
            subtitle: Text(value),
            trailing: const Icon(Icons.edit_outlined),
          ),
        );
      },
    );
  }
}

class _JournalAuditTab extends StatelessWidget {
  const _JournalAuditTab();

  @override
  Widget build(BuildContext context) {
    if (MockData.journalAudit.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune entrée dans le journal.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.journalAudit.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final j = MockData.journalAudit[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text('${j.action} — ${j.objet}'),
            subtitle: Text('${j.acteur} · ${formatDateTime(j.horodatage)}'),
          ),
        );
      },
    );
  }
}
