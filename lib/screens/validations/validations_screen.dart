import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../widgets/empty_placeholder.dart';

class ValidationsScreen extends StatelessWidget {
  const ValidationsScreen({super.key});

  IconData _icone(String typeName) {
    switch (typeName) {
      case 'creance':
        return Icons.account_balance_wallet_outlined;
      case 'echeancier':
        return Icons.event_note_outlined;
      case 'ajustement':
        return Icons.tune_outlined;
      case 'fusion':
        return Icons.merge_outlined;
      case 'cloture':
        return Icons.task_alt_outlined;
      case 'attestation':
        return Icons.verified_outlined;
      default:
        return Icons.fact_check_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MockData.validations.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune opération en attente de validation.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.validations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final v = MockData.validations[index];
        return Card(
          child: ListTile(
            leading: Icon(_icone(v.type.name)),
            title: Text(v.libelle),
            subtitle: Text('Demandé par ${v.demandePar} · ${formatDate(v.date)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  onPressed: () {},
                  tooltip: 'Valider',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () {},
                  tooltip: 'Rejeter',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
