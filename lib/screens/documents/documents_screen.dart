import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/document_item.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = (_repo.documents.isEmpty && _repo.attestations.isEmpty)
        ? _repo.refreshAll()
        : Future.value();
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
              : 'Erreur de chargement des documents.';
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
          length: 2,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.primary,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Documents'),
                    Tab(text: 'Attestations'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [_DocumentsTab(), _AttestationsTab()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DocumentsTab extends StatefulWidget {
  const _DocumentsTab();

  @override
  State<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<_DocumentsTab> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _type;
  String? _niveau;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    setState(() {
      _searchController.clear();
      _query = '';
      _type = null;
      _niveau = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final source = SnrRepository.instance.documents;
    if (source.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun document.');
    }
    final types =
        source.map((d) => d.type).where((t) => t.isNotEmpty).toSet().toList()
          ..sort();
    final niveaux =
        source
            .map((d) => d.niveauAcces)
            .where((n) => n.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final filtered = source.where((d) {
      final matchRecherche =
          _query.isEmpty ||
          normalizeText(d.titre).contains(_query) ||
          normalizeText(d.type).contains(_query);
      final matchType = _type == null || d.type == _type;
      final matchNiveau = _niveau == null || d.niveauAcces == _niveau;
      return matchRecherche && matchType && matchNiveau;
    }).toList();

    return PaginatedListView<DocumentItem>(
      items: filtered,
      itemLabel: 'documents',
      emptyMessage: 'Aucun document ne correspond aux filtres.',
      separatorBuilder: (_) => const SizedBox(height: 8),
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterSearchField(
            controller: _searchController,
            hint: 'Rechercher un document',
            onChanged: (value) => setState(() => _query = normalizeText(value)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterDropdown<String>(
                  label: 'Type',
                  value: _type ?? '',
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Tous'),
                    ),
                    for (final type in types)
                      DropdownMenuItem<String>(value: type, child: Text(type)),
                  ],
                  onChanged: (value) => setState(() {
                    _type = (value == null || value.isEmpty) ? null : value;
                  }),
                ),
                FilterDropdown<String>(
                  label: 'Niveau d\'accès',
                  value: _niveau ?? '',
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Tous'),
                    ),
                    for (final niveau in niveaux)
                      DropdownMenuItem<String>(
                        value: niveau,
                        child: Text(niveau),
                      ),
                  ],
                  onChanged: (value) => setState(() {
                    _niveau = (value == null || value.isEmpty) ? null : value;
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
      itemBuilder: (context, d) {
        return Card(
          child: ListTile(
            onTap: () => context.push('/documents/${d.id}'),
            leading: const Icon(Icons.description_outlined),
            title: Text(d.titre),
            subtitle: Text(
              '${d.type} · ${d.versionCourante} · ${formatDate(d.dateDepot)}',
            ),
            trailing: StatusBadge(label: d.niveauAcces, color: Colors.blueGrey),
          ),
        );
      },
    );
  }
}

class _AttestationsTab extends StatefulWidget {
  const _AttestationsTab();

  @override
  State<_AttestationsTab> createState() => _AttestationsTabState();
}

class _AttestationsTabState extends State<_AttestationsTab> {
  final _searchController = TextEditingController();
  String _query = '';
  StatutAttestation? _statut;
  String? _type;

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
      _type = null;
    });
  }

  Color _couleur(StatutAttestation statut) {
    switch (statut) {
      case StatutAttestation.demandee:
        return Colors.grey;
      case StatutAttestation.preparee:
        return Colors.orange;
      case StatutAttestation.delivree:
        return Colors.green;
      case StatutAttestation.refusee:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = SnrRepository.instance.attestations;
    if (source.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune attestation.');
    }
    final types =
        source.map((a) => a.type).where((t) => t.isNotEmpty).toSet().toList()
          ..sort();
    final filtered = source.where((a) {
      final matchRecherche =
          _query.isEmpty ||
          normalizeText(a.type).contains(_query) ||
          normalizeText(a.debiteurNom).contains(_query) ||
          normalizeText(a.reference).contains(_query);
      final matchStatut = _statut == null || a.statut == _statut;
      final matchType = _type == null || a.type == _type;
      return matchRecherche && matchStatut && matchType;
    }).toList();

    return PaginatedListView<Attestation>(
      items: filtered,
      itemLabel: 'attestations',
      emptyMessage: 'Aucune attestation ne correspond aux filtres.',
      separatorBuilder: (_) => const SizedBox(height: 8),
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterSearchField(
            controller: _searchController,
            hint: 'Rechercher une attestation',
            onChanged: (value) => setState(() => _query = normalizeText(value)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterDropdown<StatutAttestation?>(
                  label: 'Statut',
                  value: _statut,
                  items: [
                    const DropdownMenuItem<StatutAttestation?>(
                      value: null,
                      child: Text('Tous'),
                    ),
                    for (final statut in StatutAttestation.values)
                      DropdownMenuItem<StatutAttestation?>(
                        value: statut,
                        child: Text(statut.libelle),
                      ),
                  ],
                  onChanged: (value) => setState(() => _statut = value),
                ),
                FilterDropdown<String>(
                  label: 'Type',
                  value: _type ?? '',
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Tous'),
                    ),
                    for (final type in types)
                      DropdownMenuItem<String>(value: type, child: Text(type)),
                  ],
                  onChanged: (value) => setState(() {
                    _type = (value == null || value.isEmpty) ? null : value;
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
      itemBuilder: (context, a) {
        return Card(
          child: ListTile(
            onTap: () => context.push('/attestations/${a.id}'),
            leading: const Icon(Icons.verified_outlined),
            title: Text(a.type),
            subtitle: Text('${a.debiteurNom} · ${a.reference}'),
            trailing: StatusBadge(
              label: a.statut.libelle,
              color: _couleur(a.statut),
            ),
          ),
        );
      },
    );
  }
}
