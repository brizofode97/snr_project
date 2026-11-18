import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/bien_patrimoine.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';
import 'bien_detail_screen.dart';

class PatrimoineListScreen extends StatefulWidget {
  const PatrimoineListScreen({super.key});

  @override
  State<PatrimoineListScreen> createState() => _PatrimoineListScreenState();
}

class _PatrimoineListScreenState extends State<PatrimoineListScreen> {
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
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Erreur de chargement du patrimoine.';
          return Center(
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
          );
        }
        final biens = BienDetailScreen.biensFromCreances(_repo.creances);
        if (biens.isEmpty) {
          return const EmptyPlaceholder(message: 'Aucun bien enregistré.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: biens.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final b = biens[index];
            return Card(
              child: ListTile(
                onTap: () => context.push('/patrimoine/${b.id}'),
                leading: Icon(b.type == TypeBien.snr ? Icons.apartment_outlined : Icons.shield_outlined),
                title: Text(b.libelle),
                subtitle: Text('${b.ville} · ${formatFcfa(b.valeurEstimee)}'),
                trailing: StatusBadge(
                  label: b.type == TypeBien.snr ? 'Bien SNR' : 'Garantie',
                  color: b.type == TypeBien.snr ? Colors.indigo : Colors.teal,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
