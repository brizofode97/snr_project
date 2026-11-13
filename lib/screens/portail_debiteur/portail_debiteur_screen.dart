import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/creance.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class PortailDebiteurScreen extends StatelessWidget {
  const PortailDebiteurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.primary,
            child: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Accueil'),
                Tab(text: 'Payer'),
                Tab(text: 'Demandes'),
                Tab(text: 'Messages'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _AccueilTab(),
                _PayerTab(),
                _DemandesTab(),
                _MessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccueilTab extends StatelessWidget {
  const _AccueilTab();

  @override
  Widget build(BuildContext context) {
    final mesDossiers = MockData.creancesDuDebiteur('d1');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Bonjour Moussa Diop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text('Vous avez ${mesDossiers.length} dossier(s) en cours.', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        for (final c in mesDossiers)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.reference, style: const TextStyle(fontWeight: FontWeight.bold)),
                      StatusBadge(label: c.situation.libelle, color: Colors.blueGrey),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(c.nature),
                  const SizedBox(height: 6),
                  Text('Solde restant : ${formatFcfa(c.soldeRestant)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        if (mesDossiers.isEmpty) const EmptyPlaceholder(message: 'Aucun dossier.'),
      ],
    );
  }
}

class _PayerTab extends StatefulWidget {
  const _PayerTab();

  @override
  State<_PayerTab> createState() => _PayerTabState();
}

class _PayerTabState extends State<_PayerTab> {
  String _canal = 'Wave';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Effectuer un paiement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _canal,
          decoration: const InputDecoration(labelText: 'Moyen de paiement', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'Wave', child: Text('Wave')),
            DropdownMenuItem(value: 'Orange Money', child: Text('Orange Money')),
            DropdownMenuItem(value: 'Carte bancaire', child: Text('Carte bancaire')),
          ],
          onChanged: (v) => setState(() => _canal = v ?? _canal),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(labelText: 'Montant (FCFA)', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Paiement via $_canal — maquette visuelle uniquement')),
            );
          },
          icon: const Icon(Icons.payment_outlined),
          label: const Text('Payer maintenant'),
        ),
      ],
    );
  }
}

class _DemandesTab extends StatelessWidget {
  const _DemandesTab();

  @override
  Widget build(BuildContext context) {
    final demandes = [
      ('Demande d\'échéancier', Icons.event_note_outlined),
      ('Demande d\'attestation', Icons.verified_outlined),
      ('Contester une créance', Icons.report_gmailerrorred_outlined),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: demandes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final (label, icon) = demandes[index];
        return Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
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
            itemCount: MockData.messagesDebiteur.length,
            itemBuilder: (context, index) {
              final m = MockData.messagesDebiteur[index];
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
