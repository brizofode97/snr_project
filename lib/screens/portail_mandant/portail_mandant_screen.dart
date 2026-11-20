import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/auth/auth_service.dart';
import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../data/snr_repository.dart';
import '../../models/creance.dart';
import '../../models/message_portail.dart';
import '../../models/transaction.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';

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

const Map<String, IconData> _icones = <String, IconData>{
  'bar_chart': Icons.bar_chart,
  'hourglass_bottom': Icons.hourglass_bottom,
  'leaderboard': Icons.leaderboard,
  'gavel': Icons.gavel,
};

class PortailMandantScreen extends StatefulWidget {
  const PortailMandantScreen({super.key});

  @override
  State<PortailMandantScreen> createState() => _PortailMandantScreenState();
}

class _PortailMandantScreenState extends State<PortailMandantScreen> {
  final _repo = SnrRepository.instance;
  late Future<void> _future;
  String _mandantId = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _load() async {
    await _repo.refreshAll();
    var id = AuthService.instance.currentUser?.mandantId;
    if (id == null || id.isEmpty) {
      for (final mandant in _repo.mandants) {
        if (mandant is Map) {
          final candidat = (mandant['id'] ?? mandant['mandantId'] ?? '')
              .toString();
          if (candidat.isNotEmpty) {
            id = candidat;
            break;
          }
        }
      }
    }
    if (id == null || id.isEmpty) {
      if (_repo.creances.isNotEmpty) {
        id = _repo.creances.first.mandant;
      }
    }
    _mandantId = id ?? '';
    await _repo.refreshMessages(
      mandantId: _mandantId.isEmpty ? null : _mandantId,
    );
  }

  List<Creance> _dossiers() =>
      _repo.creances.where((c) => c.mandant == _mandantId).toList();

  List<Reversement> _reversements() =>
      _repo.reversements.where((r) => r.mandant == _mandantId).toList();

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
              : 'Erreur de chargement du portail mandant.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(() => _future = _load()),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }
        final dossiers = _dossiers();
        final mandantNom = _mandantId.isEmpty
            ? 'Mandant'
            : _repo.mandantNom(_mandantId);
        return DefaultTabController(
          length: 5,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.primary,
                child: const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Synthèse'),
                    Tab(text: 'Dossiers'),
                    Tab(text: 'Reversements'),
                    Tab(text: 'Rapports'),
                    Tab(text: 'Messages'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _SyntheseTab(mandantNom: mandantNom, dossiers: dossiers),
                    _DossiersTab(dossiers: dossiers),
                    _ReversementsTab(reversements: _reversements()),
                    const _RapportsTab(),
                    _MessagesTab(mandantId: _mandantId),
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

class _SyntheseTab extends StatelessWidget {
  final String mandantNom;
  final List<Creance> dossiers;

  const _SyntheseTab({required this.mandantNom, required this.dossiers});

  @override
  Widget build(BuildContext context) {
    final confie = dossiers.fold<int>(0, (s, c) => s + c.montantTotal);
    final encours = dossiers.fold<int>(0, (s, c) => s + c.soldeRestant);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Portefeuille $mandantNom',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
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
              label: 'Encours',
              value: formatFcfa(encours),
              icon: Icons.hourglass_bottom,
              color: Colors.orange,
            ),
            KpiCard(
              label: 'Dossiers',
              value: '${dossiers.length}',
              icon: Icons.folder_outlined,
              color: Colors.blueGrey,
            ),
            KpiCard(
              label: 'Taux de recouvrement',
              value: confie == 0
                  ? '0 %'
                  : '${(((confie - encours) / confie) * 100).toStringAsFixed(0)} %',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
          ],
        ),
        if (dossiers.isEmpty) const EmptyPlaceholder(message: 'Aucun dossier.'),
      ],
    );
  }
}

class _DossiersTab extends StatefulWidget {
  final List<Creance> dossiers;

  const _DossiersTab({required this.dossiers});

  @override
  State<_DossiersTab> createState() => _DossiersTabState();
}

class _DossiersTabState extends State<_DossiersTab> {
  final _searchController = TextEditingController();
  String _query = '';
  PhaseCreance? _phase;
  SituationCreance? _situation;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    setState(() {
      _searchController.clear();
      _query = '';
      _phase = null;
      _situation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dossiers.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun dossier.');
    }
    final filtered = widget.dossiers.where((c) {
      final matchRecherche =
          _query.isEmpty ||
          normalizeText(c.reference).contains(_query) ||
          normalizeText(c.nature).contains(_query);
      final matchPhase = _phase == null || c.phase == _phase;
      final matchSituation = _situation == null || c.situation == _situation;
      return matchRecherche && matchPhase && matchSituation;
    }).toList();

    return PaginatedListView<Creance>(
      items: filtered,
      itemLabel: 'dossiers',
      emptyMessage: 'Aucun dossier ne correspond aux filtres.',
      separatorBuilder: (_) => const SizedBox(height: 8),
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterSearchField(
            controller: _searchController,
            hint: 'Rechercher une référence ou une nature',
            onChanged: (value) => setState(() => _query = normalizeText(value)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterDropdown<PhaseCreance?>(
                  label: 'Phase',
                  value: _phase,
                  items: [
                    const DropdownMenuItem<PhaseCreance?>(
                      value: null,
                      child: Text('Toutes'),
                    ),
                    for (final phase in PhaseCreance.values)
                      DropdownMenuItem<PhaseCreance?>(
                        value: phase,
                        child: Text(phase.libelle),
                      ),
                  ],
                  onChanged: (value) => setState(() => _phase = value),
                ),
                FilterDropdown<SituationCreance?>(
                  label: 'Situation',
                  value: _situation,
                  items: [
                    const DropdownMenuItem<SituationCreance?>(
                      value: null,
                      child: Text('Toutes'),
                    ),
                    for (final situation in SituationCreance.values)
                      DropdownMenuItem<SituationCreance?>(
                        value: situation,
                        child: Text(situation.libelle),
                      ),
                  ],
                  onChanged: (value) => setState(() => _situation = value),
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
      itemBuilder: (context, c) {
        return Card(
          child: ListTile(
            onTap: () => context.push('/creances/${c.id}'),
            title: Text(c.reference),
            subtitle: Text(
              '${c.nature} · ${formatFcfa(c.soldeRestant)} restant',
            ),
            trailing: StatusBadge(
              label: c.phase.libelle,
              color: Colors.blueGrey,
            ),
          ),
        );
      },
    );
  }
}

class _ReversementsTab extends StatefulWidget {
  final List<Reversement> reversements;

  const _ReversementsTab({required this.reversements});

  @override
  State<_ReversementsTab> createState() => _ReversementsTabState();
}

class _ReversementsTabState extends State<_ReversementsTab> {
  final _searchController = TextEditingController();
  String _query = '';
  StatutReversement? _statut;
  String? _mois;

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
      _mois = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reversements.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun reversement.');
    }
    final moisDisponibles =
        widget.reversements
            .map((r) => r.mois)
            .where((m) => m.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final filtered = widget.reversements.where((r) {
      final matchRecherche =
          _query.isEmpty ||
          normalizeText(r.mandant).contains(_query) ||
          normalizeText(r.mois).contains(_query);
      final matchStatut = _statut == null || r.statut == _statut;
      final matchMois = _mois == null || r.mois == _mois;
      return matchRecherche && matchStatut && matchMois;
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
            hint: 'Rechercher un mois',
            onChanged: (value) => setState(() => _query = normalizeText(value)),
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
                  label: 'Mois',
                  value: _mois ?? '',
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Tous'),
                    ),
                    for (final mois in moisDisponibles)
                      DropdownMenuItem<String>(value: mois, child: Text(mois)),
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
            title: Text(r.mois),
            subtitle: Text(formatFcfa(r.montant)),
            trailing: StatusBadge(
              label: r.statut.libelle,
              color: Colors.blueGrey,
            ),
          ),
        );
      },
    );
  }
}

class _RapportsTab extends StatelessWidget {
  const _RapportsTab();

  Future<void> _exporter(BuildContext context) async {
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
              onPressed: () => _exporter(context),
            ),
          ),
        );
      },
    );
  }
}

class _MessagesTab extends StatefulWidget {
  final String mandantId;

  const _MessagesTab({required this.mandantId});

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  String _query = '';
  String? _filtre;

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    setState(() {
      _searchController.clear();
      _query = '';
      _filtre = null;
    });
  }

  Future<void> _envoyer() async {
    final texte = _controller.text.trim();
    if (texte.isEmpty) return;
    try {
      await SnrRepository.instance.sendMessage(<String, dynamic>{
        'texte': texte,
        'mandantId': widget.mandantId,
      });
      await SnrRepository.instance.refreshMessages(mandantId: widget.mandantId);
      _controller.clear();
      if (!mounted) return;
      setState(() {});
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du message.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = SnrRepository.instance.messages;
    final filtered = source.where((m) {
      final matchRecherche =
          _query.isEmpty ||
          normalizeText(m.contenu).contains(_query) ||
          normalizeText(m.auteur).contains(_query);
      final matchFiltre =
          _filtre == null || (_filtre == 'Envoyés' ? m.deMoi : !m.deMoi);
      return matchRecherche && matchFiltre;
    }).toList();

    final liste = source.isEmpty
        ? const Expanded(child: EmptyPlaceholder(message: 'Aucun message.'))
        : Expanded(
            child: PaginatedListView<MessagePortail>(
              items: filtered,
              itemLabel: 'messages',
              emptyMessage: 'Aucun message ne correspond aux filtres.',
              separatorBuilder: (_) => const SizedBox.shrink(),
              header: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilterSearchField(
                    controller: _searchController,
                    hint: 'Rechercher un message',
                    onChanged: (value) =>
                        setState(() => _query = normalizeText(value)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilterChips<String>(
                          values: const <String>['Envoyés', 'Reçus'],
                          selected: _filtre,
                          label: (value) => value,
                          onChanged: (value) => setState(() => _filtre = value),
                        ),
                      ),
                      TextButton(
                        onPressed: _reinitialiser,
                        child: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                ],
              ),
              itemBuilder: (context, m) {
                return Align(
                  alignment: m.deMoi
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: m.deMoi
                          ? Colors.blue.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.contenu),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(m.date),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );

    return Column(
      children: [
        liste,
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Écrire un message...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _envoyer(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _envoyer,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
