import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/transaction.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';

class ReversementsScreen extends StatefulWidget {
  const ReversementsScreen({super.key});

  @override
  State<ReversementsScreen> createState() => _ReversementsScreenState();
}

class _ReversementsScreenState extends State<ReversementsScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;
  final _searchController = TextEditingController();
  String _query = '';
  StatutReversement? _statut;
  String? _mandant;
  String? _mois;

  @override
  void initState() {
    super.initState();
    _future = _repo.reversements.isEmpty ? _repo.refreshAll() : Future.value();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    setState(() {
      _searchController.clear();
      _query = '';
      _statut = null;
      _mandant = null;
      _mois = null;
    });
  }

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
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Erreur de chargement des reversements.';
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

        final reversements = _repo.reversements;
        if (reversements.isEmpty) {
          return const EmptyPlaceholder(message: 'Aucun reversement.');
        }
        final mandants =
            reversements
                .map((r) => r.mandant)
                .where((m) => m.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final moisDisponibles =
            reversements
                .map((r) => r.mois)
                .where((m) => m.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final filtered = reversements.where((r) {
          final matchRecherche =
              _query.isEmpty ||
              normalizeText(r.mandant).contains(_query) ||
              normalizeText(r.mois).contains(_query);
          final matchStatut = _statut == null || r.statut == _statut;
          final matchMandant = _mandant == null || r.mandant == _mandant;
          final matchMois = _mois == null || r.mois == _mois;
          return matchRecherche && matchStatut && matchMandant && matchMois;
        }).toList();

        return PaginatedListView<Reversement>(
          items: filtered,
          itemLabel: 'reversements',
          emptyMessage: 'Aucun reversement ne correspond aux filtres.',
          separatorBuilder: (_) => const SizedBox(height: 8),
          header: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilterSearchField(
                controller: _searchController,
                hint: 'Rechercher un mandant ou un mois',
                onChanged: (value) =>
                    setState(() => _query = normalizeText(value)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilterDropdown<StatutReversement?>(
                      label: 'Statut',
                      value: _statut,
                      items: [
                        const DropdownMenuItem<StatutReversement?>(
                          value: null,
                          child: Text('Tous'),
                        ),
                        for (final statut in StatutReversement.values)
                          DropdownMenuItem<StatutReversement?>(
                            value: statut,
                            child: Text(statut.libelle),
                          ),
                      ],
                      onChanged: (value) => setState(() => _statut = value),
                    ),
                    FilterDropdown<String>(
                      label: 'Mandant',
                      value: _mandant ?? '',
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Tous'),
                        ),
                        for (final mandant in mandants)
                          DropdownMenuItem<String>(
                            value: mandant,
                            child: Text(mandant),
                          ),
                      ],
                      onChanged: (value) => setState(() {
                        _mandant = (value == null || value.isEmpty)
                            ? null
                            : value;
                      }),
                    ),
                    FilterDropdown<String>(
                      label: 'Mois',
                      value: _mois ?? '',
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Tous'),
                        ),
                        for (final mois in moisDisponibles)
                          DropdownMenuItem<String>(
                            value: mois,
                            child: Text(mois),
                          ),
                      ],
                      onChanged: (value) => setState(() {
                        _mois = (value == null || value.isEmpty) ? null : value;
                      }),
                    ),
                    TextButton(
                      onPressed: _reinitialiser,
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          itemBuilder: (context, r) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.compare_arrows_outlined),
                title: Text(r.mandant),
                subtitle: Text('${r.mois} · ${formatFcfa(r.montant)}'),
                trailing: StatusBadge(
                  label: r.statut.libelle,
                  color: _couleur(r.statut),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
