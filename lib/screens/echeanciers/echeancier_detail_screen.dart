import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/echeancier.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class EcheancierDetailScreen extends StatelessWidget {
  final String echeancierId;

  const EcheancierDetailScreen({super.key, required this.echeancierId});

  @override
  Widget build(BuildContext context) {
    final e = MockData.echeancierParId(echeancierId);
    if (e == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Échéancier')),
        body: const EmptyPlaceholder(message: 'Échéancier introuvable.'),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Échéancier — ${e.debiteurNom}')),
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
                      Text('Version ${e.version}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      StatusBadge(label: e.statut.libelle, color: Colors.blueGrey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Montant total : ${formatFcfa(e.montantTotal)}'),
                  Text('Acompte : ${formatFcfa(e.acompte)}'),
                  Text('${e.nombreEcheances} échéances — ${e.frequence}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Détail des échéances', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
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
              ),
            ),
          if (e.statut == StatutEcheancier.soumis) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check),
                    label: const Text('Valider'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close),
                    label: const Text('Rejeter'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
