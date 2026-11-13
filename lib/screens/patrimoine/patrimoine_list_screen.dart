import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/bien_patrimoine.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class PatrimoineListScreen extends StatelessWidget {
  const PatrimoineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (MockData.biens.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun bien enregistré.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.biens.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final b = MockData.biens[index];
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
  }
}
