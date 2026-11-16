import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/creance.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class CreancesListScreen extends StatefulWidget {
  const CreancesListScreen({super.key});

  @override
  State<CreancesListScreen> createState() => _CreancesListScreenState();
}

class _CreancesListScreenState extends State<CreancesListScreen> {
  String _recherche = '';
  PhaseCreance? _filtrePhase;
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _load() => _repo.refreshAll();

  Color _couleurPhase(PhaseCreance phase) {
    switch (phase) {
      case PhaseCreance.enregistrement:
      case PhaseCreance.controle:
        return Colors.grey;
      case PhaseCreance.validation:
      case PhaseCreance.affectation:
      case PhaseCreance.priseDeContact:
        return Colors.blue;
      case PhaseCreance.negociation:
      case PhaseCreance.accord:
        return Colors.orange;
      case PhaseCreance.contentieux:
        return Colors.red;
      case PhaseCreance.clotureDemandee:
      case PhaseCreance.cloturee:
        return Colors.green;
    }
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
              : 'Erreur de chargement des créances.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: () => setState(() => _future = _load()), child: const Text('Réessayer')),
                ],
              ),
            ),
          );
        }

        final debiteursParId = {for (final d in _repo.debiteurs) d.id: d};
        final creances = _repo.creances.where((c) {
          final debiteur = debiteursParId[c.debiteurId];
          final matchRecherche = _recherche.isEmpty ||
              c.reference.toLowerCase().contains(_recherche.toLowerCase()) ||
              (debiteur?.nom.toLowerCase().contains(_recherche.toLowerCase()) ?? false);
          final matchPhase = _filtrePhase == null || c.phase == _filtrePhase;
          return matchRecherche && matchPhase;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Rechercher une référence ou un débiteur',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _recherche = v),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Toutes'),
                      selected: _filtrePhase == null,
                      onSelected: (_) => setState(() => _filtrePhase = null),
                    ),
                  ),
                  for (final phase in PhaseCreance.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(phase.libelle),
                        selected: _filtrePhase == phase,
                        onSelected: (_) => setState(() => _filtrePhase = phase),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _load();
                  if (mounted) setState(() {});
                },
                child: creances.isEmpty
                    ? ListView(children: const [SizedBox(height: 120), EmptyPlaceholder(message: 'Aucune créance ne correspond à votre recherche.')])
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: creances.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final creance = creances[index];
                          final debiteur = debiteursParId[creance.debiteurId];
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => context.push('/creances/${creance.id}'),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            creance.reference,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        StatusBadge(label: creance.phase.libelle, color: _couleurPhase(creance.phase)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(debiteur?.nom ?? 'Débiteur ${creance.debiteurId}'),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.description_outlined, size: 14, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Expanded(child: Text(creance.nature, style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
                                      ],
                                    ),
                                    const Divider(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Solde : ${formatFcfa(creance.soldeRestant)}',
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        if (creance.contestee)
                                          const StatusBadge(label: 'Contestée', color: Colors.deepOrange),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
