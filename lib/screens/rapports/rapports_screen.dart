import 'package:material_ui/material_ui.dart';

import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../models/message_portail.dart';
import '../../widgets/empty_placeholder.dart';

const Map<String, IconData> _icones = {
  'bar_chart': Icons.bar_chart,
  'hourglass_bottom': Icons.hourglass_bottom,
  'leaderboard': Icons.leaderboard,
  'gavel': Icons.gavel,
};

const List<RapportPredefini> _rapports = <RapportPredefini>[
  RapportPredefini(
    id: 'rap1',
    titre: 'Synthèse des encaissements',
    description: 'Évolution mensuelle des encaissements par mandant.',
    icone: 'bar_chart',
  ),
  RapportPredefini(
    id: 'rap2',
    titre: 'Vieillissement des créances',
    description: 'Répartition des créances par ancienneté et phase.',
    icone: 'hourglass_bottom',
  ),
  RapportPredefini(
    id: 'rap3',
    titre: 'Performance des agents',
    description: 'Montants recouvrés et dossiers traités par agent.',
    icone: 'leaderboard',
  ),
  RapportPredefini(
    id: 'rap4',
    titre: 'Suivi du contentieux',
    description: 'Actes en cours et délais à surveiller.',
    icone: 'gavel',
  ),
];

class RapportsScreen extends StatelessWidget {
  const RapportsScreen({super.key});

  Future<void> _exporterCsv(BuildContext context) async {
    String message;
    try {
      final csv = await CreancesApiService.instance.exportCsv();
      message = 'Export CSV prêt (${csv.length} caractères).';
    } on ApiException catch (e) {
      message = e.message;
    } catch (_) {
      message = 'Erreur lors de l\'export CSV.';
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_rapports.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun rapport disponible.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _rapports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = _rapports[index];
        return Card(
          child: ListTile(
            leading: Icon(_icones[r.icone] ?? Icons.description_outlined),
            title: Text(r.titre),
            subtitle: Text(r.description),
            trailing: IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Exporter en CSV',
              onPressed: () => _exporterCsv(context),
            ),
          ),
        );
      },
    );
  }
}
