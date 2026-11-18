import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/acte_contentieux.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class ContentieuxListScreen extends StatefulWidget {
  const ContentieuxListScreen({super.key});

  @override
  State<ContentieuxListScreen> createState() => _ContentieuxListScreenState();
}

class _ContentieuxListScreenState extends State<ContentieuxListScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = _repo.actesContentieux.isEmpty
        ? _repo.refreshAll()
        : Future.value();
  }

  Color _couleur(StatutActe statut) {
    switch (statut) {
      case StatutActe.enPreparation:
        return Colors.grey;
      case StatutActe.enCircuitVisa:
        return Colors.orange;
      case StatutActe.signe:
        return Colors.blue;
      case StatutActe.notifie:
        return Colors.indigo;
      case StatutActe.clos:
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
              : 'Erreur de chargement des actes contentieux.';
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

        final actes = _repo.actesContentieux;
        if (actes.isEmpty) {
          return const EmptyPlaceholder(message: 'Aucun acte contentieux.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: actes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final a = actes[index];
            return Card(
              child: ListTile(
                onTap: () => context.push('/contentieux/${a.id}'),
                leading: const Icon(Icons.gavel_outlined),
                title: Text(a.type),
                subtitle: Text(
                  '${a.debiteurNom} · Délai : ${formatDate(a.echeanceDelai)}',
                ),
                trailing: StatusBadge(
                  label: a.statut.libelle,
                  color: _couleur(a.statut),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
