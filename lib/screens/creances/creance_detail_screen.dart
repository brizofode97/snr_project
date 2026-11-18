import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/creance.dart';
import '../../models/echeancier.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class CreanceDetailScreen extends StatefulWidget {
  final String creanceId;

  const CreanceDetailScreen({super.key, required this.creanceId});

  @override
  State<CreanceDetailScreen> createState() => _CreanceDetailScreenState();
}

class _CreanceDetailScreenState extends State<CreanceDetailScreen> {
  late Future<Creance> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchCreance(widget.creanceId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Creance>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(title: const Text('Créance')), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Erreur de chargement.';
          return Scaffold(
            appBar: AppBar(title: const Text('Créance')),
            body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(msg, textAlign: TextAlign.center))),
          );
        }
        final creance = snapshot.data!;
        final debiteur = _repo.debiteurParId(creance.debiteurId);

        return DefaultTabController(
          length: 7,
          child: Scaffold(
            appBar: AppBar(
              title: Text(creance.reference),
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Synthèse'),
                  Tab(text: 'Financier'),
                  Tab(text: 'Échéancier'),
                  Tab(text: 'Chronologie'),
                  Tab(text: 'Documents'),
                  Tab(text: 'Garanties'),
                  Tab(text: 'Actions'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _SyntheseTab(creance: creance, debiteurNom: debiteur?.nom ?? 'Inconnu'),
                _FinancierTab(creance: creance),
                _EcheancierTab(creanceId: creance.id),
                _ChronologieTab(creance: creance),
                _DocumentsTab(creance: creance),
                _GarantiesTab(creance: creance),
                const _ActionsTab(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SyntheseTab extends StatelessWidget {
  final Creance creance;
  final String debiteurNom;

  const _SyntheseTab({required this.creance, required this.debiteurNom});

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
                    Text(debiteurNom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    StatusBadge(label: creance.situation.libelle, color: Colors.blueGrey),
                  ],
                ),
                const SizedBox(height: 8),
                _InfoLine('Nature', creance.nature),
                _InfoLine('Mandant', creance.mandant),
                _InfoLine('Portefeuille', creance.portefeuille),
                _InfoLine('Agent affecté', creance.agentAffecte ?? 'Non affecté'),
                _InfoLine('Date créance', formatDate(creance.dateCreance)),
                _InfoLine('Date échéance', formatDate(creance.dateEcheance)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Avancement du dossier', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final phase in PhaseCreance.values)
                  _StepRow(
                    label: phase.libelle,
                    atteinte: phase.index <= creance.phase.index,
                    actuelle: phase == creance.phase,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.flag_outlined, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(child: Text('Prochaine action : ${creance.prochaineAction}')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FinancierTab extends StatelessWidget {
  final Creance creance;

  const _FinancierTab({required this.creance});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoLine('Principal', formatFcfa(creance.principal)),
                _InfoLine('Intérêts', formatFcfa(creance.interets)),
                _InfoLine('Frais', formatFcfa(creance.frais)),
                const Divider(),
                _InfoLine('Montant total', formatFcfa(creance.montantTotal), gras: true),
                _InfoLine('Solde restant', formatFcfa(creance.soldeRestant), gras: true, couleur: Colors.red),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: creance.montantTotal == 0 ? 0 : 1 - (creance.soldeRestant / creance.montantTotal),
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(((creance.montantTotal - creance.soldeRestant) / creance.montantTotal) * 100).toStringAsFixed(0)} % recouvré',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _EcheancierTab extends StatelessWidget {
  final String creanceId;

  const _EcheancierTab({required this.creanceId});

  @override
  Widget build(BuildContext context) {
    final e = SnrRepository.instance.echeancierParCreanceId(creanceId);
    if (e == null) {
      return const EmptyPlaceholder(message: 'Aucun échéancier pour cette créance.');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoLine('Statut', e.statut.libelle),
                _InfoLine('Acompte', formatFcfa(e.acompte)),
                _InfoLine('Nombre d\'échéances', '${e.nombreEcheances}'),
                _InfoLine('Fréquence', e.frequence),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final ligne in e.echeances)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: ligne.payee ? Colors.green.shade100 : Colors.grey.shade200,
                child: Icon(
                  ligne.payee ? Icons.check : Icons.schedule,
                  color: ligne.payee ? Colors.green : Colors.grey.shade600,
                  size: 18,
                ),
              ),
              title: Text('Échéance ${ligne.numero} — ${formatFcfa(ligne.montant)}'),
              subtitle: Text('Avant le ${formatDate(ligne.dateLimite)}'),
              trailing: StatusBadge(
                label: ligne.payee ? 'Payée' : 'À venir',
                color: ligne.payee ? Colors.green : Colors.orange,
              ),
            ),
          ),
      ],
    );
  }
}

class _ChronologieTab extends StatelessWidget {
  final Creance creance;

  const _ChronologieTab({required this.creance});

  @override
  Widget build(BuildContext context) {
    if (creance.chronologie.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun événement enregistré.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: creance.chronologie.length,
      itemBuilder: (context, index) {
        final ev = creance.chronologie[creance.chronologie.length - 1 - index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, shape: BoxShape.circle),
                  ),
                  Container(width: 2, height: 46, color: Colors.grey.shade300),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ev.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(ev.description, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDate(ev.date)} — ${ev.auteur}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
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

class _DocumentsTab extends StatelessWidget {
  final Creance creance;

  const _DocumentsTab({required this.creance});

  @override
  Widget build(BuildContext context) {
    final docs = SnrRepository.instance.documents
        .where((d) => creance.documentIds.contains(d.id))
        .toList();
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
            subtitle: Text('${d.type} · ${d.versionCourante} · ${formatDate(d.dateDepot)}'),
          ),
        );
      },
    );
  }
}

class _GarantiesTab extends StatelessWidget {
  final Creance creance;

  const _GarantiesTab({required this.creance});

  @override
  Widget build(BuildContext context) {
    if (creance.garanties.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune garantie associée.', icon: Icons.shield_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: creance.garanties.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          leading: const Icon(Icons.shield_outlined),
          title: Text(creance.garanties[index]),
        ),
      ),
    );
  }
}

class _ActionsTab extends StatelessWidget {
  const _ActionsTab();

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Enregistrer une action', Icons.edit_note_outlined),
      ('Enregistrer une promesse', Icons.handshake_outlined),
      ('Enregistrer un paiement', Icons.payments_outlined),
      ('Proposer un échéancier', Icons.event_note_outlined),
      ('Proposer un ajustement', Icons.tune_outlined),
      ('Contester la créance', Icons.report_gmailerrorred_outlined),
      ('Ouvrir un acte contentieux', Icons.gavel_outlined),
      ('Demander la clôture', Icons.task_alt_outlined),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: actions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final (label, icon) = actions[index];
        return OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Action "$label" — maquette visuelle uniquement')),
            );
          },
          icon: Icon(icon),
          label: Align(alignment: Alignment.centerLeft, child: Text(label)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            alignment: Alignment.centerLeft,
          ),
        );
      },
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final bool gras;
  final Color? couleur;

  const _InfoLine(this.label, this.value, {this.gras = false, this.couleur});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(
            value,
            style: TextStyle(fontWeight: gras ? FontWeight.bold : FontWeight.normal, color: couleur),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final bool atteinte;
  final bool actuelle;

  const _StepRow({required this.label, required this.atteinte, required this.actuelle});

  @override
  Widget build(BuildContext context) {
    final color = atteinte ? Theme.of(context).colorScheme.secondary : Colors.grey.shade300;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(atteinte ? Icons.check_circle : Icons.radio_button_unchecked, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontWeight: actuelle ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
