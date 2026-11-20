import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/echeancier.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';

class EcheanciersScreen extends StatefulWidget {
  const EcheanciersScreen({super.key});

  @override
  State<EcheanciersScreen> createState() => _EcheanciersScreenState();
}

class _EcheanciersScreenState extends State<EcheanciersScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = _repo.echeanciers.isEmpty ? _repo.refreshAll() : Future.value();
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
              : 'Erreur de chargement des échéanciers.';
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
                    Tab(text: 'À valider'),
                    Tab(text: 'En vigueur'),
                    Tab(text: 'Historique'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _EcheancierListe(statuts: const [StatutEcheancier.soumis]),
                    _EcheancierListe(statuts: const [StatutEcheancier.valide]),
                    _EcheancierListe(
                      statuts: const [
                        StatutEcheancier.rejete,
                        StatutEcheancier.remplace,
                      ],
                    ),
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

class _EcheancierListe extends StatefulWidget {
  final List<StatutEcheancier> statuts;

  const _EcheancierListe({required this.statuts});

  @override
  State<_EcheancierListe> createState() => _EcheancierListeState();
}

class _EcheancierListeState extends State<_EcheancierListe> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _frequence;
  StatutEcheancier? _statut;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    setState(() {
      _searchController.clear();
      _query = '';
      _frequence = null;
      _statut = null;
    });
  }

  Color _couleur(StatutEcheancier statut) {
    switch (statut) {
      case StatutEcheancier.soumis:
        return Colors.orange;
      case StatutEcheancier.valide:
        return Colors.green;
      case StatutEcheancier.rejete:
        return Colors.red;
      case StatutEcheancier.remplace:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = SnrRepository.instance.echeanciers
        .where((e) => widget.statuts.contains(e.statut))
        .toList();
    if (source.isEmpty) {
      return const EmptyPlaceholder(
        message: 'Aucun échéancier dans cette catégorie.',
      );
    }
    final frequences =
        source
            .map((e) => e.frequence)
            .where((f) => f.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final filtered = source.where((e) {
      final matchRecherche =
          _query.isEmpty ||
          normalizeText(e.debiteurNom).contains(_query) ||
          normalizeText(e.creanceId).contains(_query);
      final matchFrequence = _frequence == null || e.frequence == _frequence;
      final matchStatut = _statut == null || e.statut == _statut;
      return matchRecherche && matchFrequence && matchStatut;
    }).toList();

    return PaginatedListView<Echeancier>(
      items: filtered,
      itemLabel: 'échéanciers',
      emptyMessage: 'Aucun échéancier ne correspond aux filtres.',
      separatorBuilder: (_) => const SizedBox(height: 8),
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterSearchField(
            controller: _searchController,
            hint: 'Rechercher un débiteur ou une référence',
            onChanged: (value) => setState(() => _query = normalizeText(value)),
          ),
          if (widget.statuts.length > 1)
            FilterChips<StatutEcheancier>(
              values: widget.statuts,
              selected: _statut,
              label: (statut) => statut.libelle,
              onChanged: (value) => setState(() => _statut = value),
              allLabel: 'Tous les statuts',
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterDropdown<String>(
                  label: 'Fréquence',
                  value: _frequence ?? '',
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Toutes'),
                    ),
                    for (final frequence in frequences)
                      DropdownMenuItem<String>(
                        value: frequence,
                        child: Text(frequence),
                      ),
                  ],
                  onChanged: (value) => setState(() {
                    _frequence = (value == null || value.isEmpty)
                        ? null
                        : value;
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
      itemBuilder: (context, e) {
        return Card(
          child: ListTile(
            onTap: () => context.push('/echeanciers/${e.id}'),
            title: Text(e.debiteurNom),
            subtitle: Text(
              '${e.nombreEcheances} échéances · ${formatFcfa(e.montantTotal)}',
            ),
            trailing: StatusBadge(
              label: e.statut.libelle,
              color: _couleur(e.statut),
            ),
          ),
        );
      },
    );
  }
}
