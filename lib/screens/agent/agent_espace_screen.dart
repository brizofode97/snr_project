import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/tache.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class AgentEspaceScreen extends StatelessWidget {
  const AgentEspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.primary,
            child: const TabBar(
              tabs: [
                Tab(text: 'Mes tâches'),
                Tab(text: 'Mes promesses'),
                Tab(text: 'À affecter'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TachesTab(),
                _PromessesTab(),
                _ACollecterTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TachesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (MockData.taches.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune tâche.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.taches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = MockData.taches[index];
        return Card(
          child: ListTile(
            leading: Icon(
              t.statut == StatutTache.faite ? Icons.check_circle_outline : Icons.radio_button_unchecked,
              color: t.statut == StatutTache.faite ? Colors.green : (t.enRetard ? Colors.red : Colors.grey),
            ),
            title: Text(t.libelle),
            subtitle: Text('${t.type} · ${formatDate(t.date)} · ${t.assigneA}'),
            trailing: t.enRetard
                ? const StatusBadge(label: 'En retard', color: Colors.red)
                : (t.statut == StatutTache.faite
                    ? const StatusBadge(label: 'Faite', color: Colors.green)
                    : const StatusBadge(label: 'À faire', color: Colors.orange)),
          ),
        );
      },
    );
  }
}

class _PromessesTab extends StatelessWidget {
  Color _couleur(StatutPromesse statut) {
    switch (statut) {
      case StatutPromesse.enAttente:
        return Colors.orange;
      case StatutPromesse.tenue:
        return Colors.green;
      case StatutPromesse.nonTenue:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MockData.promesses.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune promesse enregistrée.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.promesses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = MockData.promesses[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.handshake_outlined),
            title: Text('${p.debiteurNom} — ${formatFcfa(p.montant)}'),
            subtitle: Text('Promis pour le ${formatDate(p.date)}'),
            trailing: StatusBadge(label: p.statut.libelle, color: _couleur(p.statut)),
          ),
        );
      },
    );
  }
}

class _ACollecterTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dossiers = MockData.creances.where((c) => c.agentAffecte == null).toList();
    if (dossiers.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun dossier en attente d\'affectation.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: dossiers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final c = dossiers[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.assignment_late_outlined),
            title: Text(c.reference),
            subtitle: Text(c.nature),
            trailing: OutlinedButton(onPressed: () {}, child: const Text('Affecter')),
          ),
        );
      },
    );
  }
}
