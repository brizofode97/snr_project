import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/transaction.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    final t = MockData.transactionParId(transactionId);
    if (t == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction')),
        body: const EmptyPlaceholder(message: 'Transaction introuvable.'),
      );
    }
    final creance = t.creanceId != null ? MockData.creanceParId(t.creanceId!) : null;

    return Scaffold(
      appBar: AppBar(title: Text(t.reference)),
      body: ListView(
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
                      Text(formatFcfa(t.montant), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      StatusBadge(label: t.statut.libelle, color: Colors.blueGrey),
                    ],
                  ),
                  const Divider(height: 24),
                  _Ligne('Payeur', t.payeur),
                  _Ligne('Canal', t.canal),
                  _Ligne('Date', formatDate(t.date)),
                  _Ligne('Créance liée', creance?.reference ?? 'Non affectée'),
                  _Ligne('Comptabilisé', t.comptabilise ? 'Oui' : 'Non'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmer'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call_split),
                  label: const Text('Affecter'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  final String label;
  final String value;

  const _Ligne(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
