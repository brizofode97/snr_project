import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../models/document_item.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class AttestationDetailScreen extends StatelessWidget {
  final String attestationId;

  const AttestationDetailScreen({super.key, required this.attestationId});

  @override
  Widget build(BuildContext context) {
    final a = MockData.attestationParId(attestationId);
    if (a == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Attestation')),
        body: const EmptyPlaceholder(message: 'Attestation introuvable.'),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(a.reference)),
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
                      Text(a.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                      StatusBadge(label: a.statut.libelle, color: Colors.blueGrey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Débiteur : ${a.debiteurNom}'),
                  Text('Code de vérification : ${a.codeVerification}'),
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
                  label: const Text('Délivrer'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                  label: const Text('Refuser'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
