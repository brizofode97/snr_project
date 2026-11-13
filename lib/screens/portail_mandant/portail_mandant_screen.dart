import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/creance.dart';
import '../../models/transaction.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/status_badge.dart';

class PortailMandantScreen extends StatelessWidget {
  const PortailMandantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.primary,
            child: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Synthèse'),
                Tab(text: 'Dossiers'),
                Tab(text: 'Reversements'),
                Tab(text: 'Rapports'),
                Tab(text: 'Messages'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _SyntheseTab(),
                _DossiersTab(),
                _ReversementsTab(),
                _RapportsTab(),
                _MessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyntheseTab extends StatelessWidget {
  const _SyntheseTab();

  @override
  Widget build(BuildContext context) {
    final dossiers = MockData.creances.where((c) => c.mandant == 'Banque Atlantique Sénégal').toList();
    final confie = dossiers.fold<int>(0, (s, c) => s + c.montantTotal);
    final encours = dossiers.fold<int>(0, (s, c) => s + c.soldeRestant);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Portefeuille Banque Atlantique Sénégal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.3,
          children: [
            KpiCard(label: 'Montant confié', value: formatFcfa(confie), icon: Icons.account_balance_wallet_outlined, color: Colors.indigo),
            KpiCard(label: 'Encours', value: formatFcfa(encours), icon: Icons.hourglass_bottom, color: Colors.orange),
            KpiCard(label: 'Dossiers', value: '${dossiers.length}', icon: Icons.folder_outlined, color: Colors.blueGrey),
            KpiCard(label: 'Taux de recouvrement', value: confie == 0 ? '0 %' : '${(((confie - encours) / confie) * 100).toStringAsFixed(0)} %', icon: Icons.trending_up, color: Colors.green),
          ],
        ),
      ],
    );
  }
}

class _DossiersTab extends StatelessWidget {
  const _DossiersTab();

  @override
  Widget build(BuildContext context) {
    final dossiers = MockData.creances.where((c) => c.mandant == 'Banque Atlantique Sénégal').toList();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: dossiers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final c = dossiers[index];
        return Card(
          child: ListTile(
            title: Text(c.reference),
            subtitle: Text('${c.nature} · ${formatFcfa(c.soldeRestant)} restant'),
            trailing: StatusBadge(label: c.phase.libelle, color: Colors.blueGrey),
          ),
        );
      },
    );
  }
}

class _ReversementsTab extends StatelessWidget {
  const _ReversementsTab();

  @override
  Widget build(BuildContext context) {
    final reversements = MockData.reversements.where((r) => r.mandant == 'Banque Atlantique Sénégal').toList();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reversements.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = reversements[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.compare_arrows_outlined),
            title: Text(r.mois),
            subtitle: Text(formatFcfa(r.montant)),
            trailing: StatusBadge(label: r.statut.libelle, color: Colors.blueGrey),
          ),
        );
      },
    );
  }
}

class _RapportsTab extends StatelessWidget {
  const _RapportsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.rapports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = MockData.rapports[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(r.titre),
            subtitle: Text(r.description),
          ),
        );
      },
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: MockData.messagesMandant.length,
            itemBuilder: (context, index) {
              final m = MockData.messagesMandant[index];
              return Align(
                alignment: m.deMoi ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 280),
                  decoration: BoxDecoration(
                    color: m.deMoi ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.contenu),
                      const SizedBox(height: 4),
                      Text(formatDate(m.date), style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Expanded(
                child: TextField(decoration: InputDecoration(hintText: 'Écrire un message...', border: OutlineInputBorder())),
              ),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: () {}, icon: const Icon(Icons.send)),
            ],
          ),
        ),
      ],
    );
  }
}
