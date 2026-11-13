import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../models/creance.dart';
import '../../widgets/kpi_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final creances = MockData.creances;
    final confie = creances.fold<int>(0, (sum, c) => sum + c.montantTotal);
    final recouvre = creances.fold<int>(0, (sum, c) => sum + (c.montantTotal - c.soldeRestant));
    final encours = creances.fold<int>(0, (sum, c) => sum + c.soldeRestant);
    final enContentieux = creances.where((c) => c.phase == PhaseCreance.contentieux).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.3,
          children: [
            KpiCard(
              label: 'Montant confié',
              value: formatFcfa(confie),
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.indigo,
            ),
            KpiCard(
              label: 'Montant recouvré',
              value: formatFcfa(recouvre),
              icon: Icons.trending_up,
              color: Colors.green,
              trend: '+12 % / mois',
            ),
            KpiCard(
              label: 'Encours',
              value: formatFcfa(encours),
              icon: Icons.hourglass_bottom,
              color: Colors.orange,
            ),
            KpiCard(
              label: 'Dossiers en contentieux',
              value: '$enContentieux',
              icon: Icons.gavel_outlined,
              color: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Répartition par phase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final phase in PhaseCreance.values)
                  _PhaseBar(
                    label: phase.libelle,
                    count: creances.where((c) => c.phase == phase).length,
                    total: creances.length,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Encaissements mensuels (FCFA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  _MonthBar('Juil.', 0.5),
                  _MonthBar('Août', 0.65),
                  _MonthBar('Sept.', 0.45),
                  _MonthBar('Oct.', 0.8),
                  _MonthBar('Nov.', 0.95),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhaseBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;

  const _PhaseBar({required this.label, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  final String label;
  final double height;

  const _MonthBar(this.label, this.height);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: FractionallySizedBox(
                heightFactor: height,
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
