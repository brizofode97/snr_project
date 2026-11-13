import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/transaction.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class ReversementsScreen extends StatelessWidget {
  const ReversementsScreen({super.key});

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
    if (MockData.reversements.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun reversement.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.reversements.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = MockData.reversements[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.compare_arrows_outlined),
            title: Text(r.mandant),
            subtitle: Text('${r.mois} · ${formatFcfa(r.montant)}'),
            trailing: StatusBadge(label: r.statut.libelle, color: _couleur(r.statut)),
          ),
        );
      },
    );
  }
}
