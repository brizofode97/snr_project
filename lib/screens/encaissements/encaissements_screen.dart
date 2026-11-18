import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../data/snr_repository.dart';
import '../../models/transaction.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class EncaissementsScreen extends StatefulWidget {
  const EncaissementsScreen({super.key});

  @override
  State<EncaissementsScreen> createState() => _EncaissementsScreenState();
}

class _EncaissementsScreenState extends State<EncaissementsScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = _repo.transactions.isEmpty ? _repo.refreshAll() : Future.value();
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
              : 'Erreur de chargement des encaissements.';
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
          length: 3,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.primary,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Journal'),
                    Tab(text: 'À confirmer'),
                    Tab(text: 'Rapprochement'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const _TransactionsListe(statuts: null),
                    const _TransactionsListe(
                      statuts: [
                        StatutTransaction.enAttente,
                        StatutTransaction.justificatifDepose,
                        StatutTransaction.nonIdentifie,
                      ],
                    ),
                    _RapprochementTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Color _couleurStatut(StatutTransaction statut) {
  switch (statut) {
    case StatutTransaction.confirme:
      return Colors.green;
    case StatutTransaction.enAttente:
    case StatutTransaction.justificatifDepose:
      return Colors.orange;
    case StatutTransaction.nonIdentifie:
      return Colors.deepOrange;
    case StatutTransaction.rejete:
      return Colors.red;
  }
}

class _TransactionsListe extends StatelessWidget {
  final List<StatutTransaction>? statuts;

  const _TransactionsListe({required this.statuts});

  @override
  Widget build(BuildContext context) {
    final liste = SnrRepository.instance.transactions
        .where((t) => statuts == null || statuts!.contains(t.statut))
        .toList();
    if (liste.isEmpty) {
      return const EmptyPlaceholder(
        message: 'Aucune transaction dans cette catégorie.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: liste.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = liste[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/encaissements/${t.id}'),
            leading: const Icon(Icons.payments_outlined),
            title: Text('${t.reference} — ${formatFcfa(t.montant)}'),
            subtitle: Text('${t.payeur} · ${t.canal} · ${formatDate(t.date)}'),
            trailing: StatusBadge(
              label: t.statut.libelle,
              color: _couleurStatut(t.statut),
            ),
          ),
        );
      },
    );
  }
}

class _RapprochementTab extends StatelessWidget {
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final transactions = SnrRepository.instance.transactions;
    final comptabilises = transactions.where((t) => t.comptabilise).length;
    final total = transactions.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rapprochement bancaire',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('$comptabilises / $total transactions comptabilisées'),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : comptabilises / total,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _exporterCsv(context),
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Exporter le lot comptable (CSV)'),
        ),
      ],
    );
  }
}
