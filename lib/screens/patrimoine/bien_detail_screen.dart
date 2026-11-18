import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/bien_patrimoine.dart';
import '../../models/creance.dart';
import '../../widgets/empty_placeholder.dart';

class BienDetailScreen extends StatefulWidget {
  final String bienId;

  const BienDetailScreen({super.key, required this.bienId});

  static List<BienPatrimoine> biensFromCreances(List<Creance> creances) {
    final biens = <BienPatrimoine>[];
    for (final c in creances) {
      for (var index = 0; index < c.garanties.length; index++) {
        biens.add(
          BienPatrimoine(
            id: 'garantie-${c.id}-$index',
            libelle: c.garanties[index],
            type: TypeBien.garantie,
            ville: '',
            valeurEstimee: 0,
            creanceId: c.id,
            statut: 'Garantie déclarée',
          ),
        );
      }
    }
    return biens;
  }

  @override
  State<BienDetailScreen> createState() => _BienDetailScreenState();
}

class _BienDetailScreenState extends State<BienDetailScreen> {
  final _repo = SnrRepository.instance;
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.creances.isEmpty ? _repo.refreshAll() : Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bien')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Erreur de chargement du bien.';
          return Scaffold(
            appBar: AppBar(title: const Text('Bien')),
            body: Center(
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
            ),
          );
        }
        BienPatrimoine? bien;
        for (final candidat in BienDetailScreen.biensFromCreances(_repo.creances)) {
          if (candidat.id == widget.bienId) {
            bien = candidat;
            break;
          }
        }
        if (bien == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bien')),
            body: const EmptyPlaceholder(message: 'Bien introuvable.'),
          );
        }
        final creance = bien.creanceId != null
            ? SnrRepository.instance.creanceParId(bien.creanceId!)
            : null;
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
      },
    );
  }
}
