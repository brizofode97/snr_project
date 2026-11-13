import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/bien_patrimoine.dart';
import '../../widgets/empty_placeholder.dart';

class BienDetailScreen extends StatelessWidget {
  final String bienId;

  const BienDetailScreen({super.key, required this.bienId});

  @override
  Widget build(BuildContext context) {
    final bien = MockData.bienParId(bienId);
    if (bien == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bien')),
        body: const EmptyPlaceholder(message: 'Bien introuvable.'),
      );
    }
    final creance = bien.creanceId != null ? MockData.creanceParId(bien.creanceId!) : null;

    return Scaffold(
      appBar: AppBar(title: Text(bien.libelle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    bien.type == TypeBien.snr ? Icons.apartment_outlined : Icons.shield_outlined,
                    size: 36,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 10),
                  Text(bien.type == TypeBien.snr ? 'Bien propre SNR' : 'Garantie de créance'),
                  const Divider(height: 20),
                  Text('Ville : ${bien.ville}'),
                  Text('Valeur estimée : ${formatFcfa(bien.valeurEstimee)}'),
                  Text('Statut : ${bien.statut}'),
                  if (creance != null) Text('Créance couverte : ${creance.reference}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
