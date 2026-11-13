import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../widgets/empty_placeholder.dart';

const Map<String, IconData> _icones = {
  'bar_chart': Icons.bar_chart,
  'hourglass_bottom': Icons.hourglass_bottom,
  'leaderboard': Icons.leaderboard,
  'gavel': Icons.gavel,
};

class RapportsScreen extends StatelessWidget {
  const RapportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (MockData.rapports.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun rapport disponible.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.rapports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = MockData.rapports[index];
        return Card(
          child: ListTile(
            leading: Icon(_icones[r.icone] ?? Icons.description_outlined),
            title: Text(r.titre),
            subtitle: Text(r.description),
            trailing: IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Exporter en CSV',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export CSV — maquette visuelle uniquement')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
