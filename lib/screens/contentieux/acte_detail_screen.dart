import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/acte_contentieux.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class ActeDetailScreen extends StatelessWidget {
  final String acteId;

  const ActeDetailScreen({super.key, required this.acteId});

  @override
  Widget build(BuildContext context) {
    final acte = MockData.acteParId(acteId);
    if (acte == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acte contentieux')),
        body: const EmptyPlaceholder(message: 'Acte introuvable.'),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(acte.type)),
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
                      Text(acte.debiteurNom, style: const TextStyle(fontWeight: FontWeight.bold)),
                      StatusBadge(label: acte.statut.libelle, color: Colors.blueGrey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Échéance du délai : ${formatDate(acte.echeanceDelai)}'),
                  if (acte.dateSignature != null) Text('Signé le : ${formatDate(acte.dateSignature!)}'),
                  if (acte.dateNotification != null) Text('Notifié le : ${formatDate(acte.dateNotification!)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Circuit de visa', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (acte.circuitVisa.isEmpty)
            const EmptyPlaceholder(message: 'Aucun circuit de visa défini.')
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final etape in acte.circuitVisa)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              etape.valide ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: etape.valide ? Colors.green : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(etape.fonction, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(etape.acteur, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
