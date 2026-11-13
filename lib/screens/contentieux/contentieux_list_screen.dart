import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/acte_contentieux.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class ContentieuxListScreen extends StatelessWidget {
  const ContentieuxListScreen({super.key});

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
    if (MockData.actesContentieux.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun acte contentieux.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.actesContentieux.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final a = MockData.actesContentieux[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/contentieux/${a.id}'),
            leading: const Icon(Icons.gavel_outlined),
            title: Text(a.type),
            subtitle: Text('${a.debiteurNom} · Délai : ${formatDate(a.echeanceDelai)}'),
            trailing: StatusBadge(label: a.statut.libelle, color: _couleur(a.statut)),
          ),
        );
      },
    );
  }
}
