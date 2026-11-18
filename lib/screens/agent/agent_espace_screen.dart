import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/creance.dart';
import '../../models/tache.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class AgentEspaceScreen extends StatefulWidget {
  const AgentEspaceScreen({super.key});

  @override
  State<AgentEspaceScreen> createState() => _AgentEspaceScreenState();
}

class _AgentEspaceScreenState extends State<AgentEspaceScreen> {
  final _repo = SnrRepository.instance;
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Erreur de chargement des données agent.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(() => _future = _repo.refreshAll()),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final aAffecter = _repo.creances
            .where((c) => c.agentAffecte == null || c.agentAffecte!.isEmpty)
            .toList();
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
                    _TachesTab(taches: _repo.taches),
                    _PromessesTab(promesses: _repo.promesses),
                    _ACollecterTab(dossiers: aAffecter),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TachesTab extends StatelessWidget {
  final List<Tache> taches;

  const _TachesTab({required this.taches});

  @override
  Widget build(BuildContext context) {
    if (taches.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune tâche.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: taches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = taches[index];
        return Card(
          child: ListTile(
            leading: Icon(
              t.statut == StatutTache.faite
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              color: t.statut == StatutTache.faite
                  ? Colors.green
                  : (t.enRetard ? Colors.red : Colors.grey),
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
  final List<Promesse> promesses;

  const _PromessesTab({required this.promesses});

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
    if (promesses.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune promesse enregistrée.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: promesses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = promesses[index];
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
  final List<Creance> dossiers;

  const _ACollecterTab({required this.dossiers});

  @override
  Widget build(BuildContext context) {
    if (dossiers.isEmpty) {
      return const EmptyPlaceholder(
        message: 'Aucun dossier en attente d\'affectation.',
      );
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
            trailing: OutlinedButton(
              onPressed: () => context.push('/creances/${c.id}'),
              child: const Text('Affecter'),
            ),
          ),
        );
      },
    );
  }
}
