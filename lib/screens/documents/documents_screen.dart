import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/document_item.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = (_repo.documents.isEmpty && _repo.attestations.isEmpty)
        ? _repo.refreshAll()
        : Future.value();
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
              : 'Erreur de chargement des documents.';
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

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.primary,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Documents'),
                    Tab(text: 'Attestations'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [_DocumentsTab(), _AttestationsTab()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final documents = SnrRepository.instance.documents;
    if (documents.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun document.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = documents[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/documents/${d.id}'),
            leading: const Icon(Icons.description_outlined),
            title: Text(d.titre),
            subtitle: Text(
              '${d.type} · ${d.versionCourante} · ${formatDate(d.dateDepot)}',
            ),
            trailing: StatusBadge(label: d.niveauAcces, color: Colors.blueGrey),
          ),
        );
      },
    );
  }
}

class _AttestationsTab extends StatelessWidget {
  Color _couleur(StatutAttestation statut) {
    switch (statut) {
      case StatutAttestation.demandee:
        return Colors.grey;
      case StatutAttestation.preparee:
        return Colors.orange;
      case StatutAttestation.delivree:
        return Colors.green;
      case StatutAttestation.refusee:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attestations = SnrRepository.instance.attestations;
    if (attestations.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune attestation.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: attestations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final a = attestations[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/attestations/${a.id}'),
            leading: const Icon(Icons.verified_outlined),
            title: Text(a.type),
            subtitle: Text('${a.debiteurNom} · ${a.reference}'),
            trailing: StatusBadge(
              label: a.statut.libelle,
              color: _couleur(a.statut),
            ),
          ),
        );
      },
    );
  }
}
