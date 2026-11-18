import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/transaction.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class ReversementsScreen extends StatefulWidget {
  const ReversementsScreen({super.key});

  @override
  State<ReversementsScreen> createState() => _ReversementsScreenState();
}

class _ReversementsScreenState extends State<ReversementsScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = _repo.reversements.isEmpty ? _repo.refreshAll() : Future.value();
  }

  Color _couleur(StatutReversement statut) {
    switch (statut) {
      case StatutReversement.aPreparer:
        return Colors.grey;
      case StatutReversement.prepare:
        return Colors.orange;
      case StatutReversement.valide:
        return Colors.blue;
      case StatutReversement.paye:
        return Colors.green;
    }
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
              : 'Erreur de chargement des reversements.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        setState(() => _future = _repo.refreshAll()),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final reversements = _repo.reversements;
        if (reversements.isEmpty) {
          return const EmptyPlaceholder(message: 'Aucun reversement.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reversements.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final r = reversements[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.compare_arrows_outlined),
                title: Text(r.mandant),
                subtitle: Text('${r.mois} · ${formatFcfa(r.montant)}'),
                trailing: StatusBadge(
                  label: r.statut.libelle,
                  color: _couleur(r.statut),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
