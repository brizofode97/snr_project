import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/creance.dart';
import '../../models/debiteur.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class DebiteurDetailScreen extends StatelessWidget {
  final String debiteurId;

  const DebiteurDetailScreen({super.key, required this.debiteurId});

  @override
  Widget build(BuildContext context) {
    final debiteur = MockData.debiteurParId(debiteurId);
    if (debiteur == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Débiteur')),
        body: const EmptyPlaceholder(message: 'Débiteur introuvable.'),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(debiteur.nom),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Créances'),
              Tab(text: 'Documents'),
              Tab(text: 'Demandes'),
              Tab(text: 'Historique'),
              Tab(text: 'Accès portail'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CreancesTab(debiteurId: debiteur.id),
            _DocumentsTab(debiteurId: debiteur.id),
            const EmptyPlaceholder(message: 'Aucune demande en cours (échéancier, attestation, contestation).'),
            const EmptyPlaceholder(message: 'Aucun historique additionnel.', icon: Icons.history),
            _AccesPortailTab(debiteur: debiteur),
          ],
        ),
      ),
    );
  }
}

class _CreancesTab extends StatelessWidget {
  final String debiteurId;

  const _CreancesTab({required this.debiteurId});

  @override
  Widget build(BuildContext context) {
    final creances = MockData.creancesDuDebiteur(debiteurId);
    if (creances.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune créance pour ce débiteur.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: creances.length,
      itemBuilder: (context, index) {
        final c = creances[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/creances/${c.id}'),
            title: Text(c.reference),
            subtitle: Text('${c.nature} — ${formatFcfa(c.soldeRestant)} restant'),
            trailing: StatusBadge(label: c.phase.libelle, color: Colors.blueGrey),
          ),
        );
      },
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  final String debiteurId;

  const _DocumentsTab({required this.debiteurId});

  @override
  Widget build(BuildContext context) {
    final creanceIds = MockData.creancesDuDebiteur(debiteurId).map((c) => c.id).toSet();
    final docs = MockData.documents.where((d) => creanceIds.contains(d.creanceId)).toList();
    if (docs.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun document rattaché.', icon: Icons.folder_open_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final d = docs[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(d.titre),
            subtitle: Text(d.type),
          ),
        );
      },
    );
  }
}

class _AccesPortailTab extends StatelessWidget {
  final Debiteur debiteur;

  const _AccesPortailTab({required this.debiteur});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Accès au portail débiteur', style: TextStyle(fontWeight: FontWeight.bold)),
                    StatusBadge(
                      label: debiteur.accesPortailActif ? 'Actif' : 'Suspendu',
                      color: debiteur.accesPortailActif ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Email : ${debiteur.email}'),
                Text('Téléphone : ${debiteur.telephone}'),
                Text('Identifiant : ${debiteur.identifiant}'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(debiteur.accesPortailActif ? Icons.pause_circle_outline : Icons.play_circle_outline),
                        label: Text(debiteur.accesPortailActif ? 'Suspendre' : 'Réactiver'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.mail_outline),
                        label: const Text('Inviter'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
