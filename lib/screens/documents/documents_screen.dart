import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/document_item.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              children: [
                _DocumentsTab(),
                _AttestationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (MockData.documents.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun document.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.documents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = MockData.documents[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/documents/${d.id}'),
            leading: const Icon(Icons.description_outlined),
            title: Text(d.titre),
            subtitle: Text('${d.type} · ${d.versionCourante} · ${formatDate(d.dateDepot)}'),
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
    if (MockData.attestations.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune attestation.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.attestations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final a = MockData.attestations[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/attestations/${a.id}'),
            leading: const Icon(Icons.verified_outlined),
            title: Text(a.type),
            subtitle: Text('${a.debiteurNom} · ${a.reference}'),
            trailing: StatusBadge(label: a.statut.libelle, color: _couleur(a.statut)),
          ),
        );
      },
    );
  }
}
