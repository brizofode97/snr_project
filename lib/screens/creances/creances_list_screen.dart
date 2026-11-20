import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/creance.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';

class CreancesListScreen extends StatefulWidget {
  const CreancesListScreen({super.key});

  @override
  State<CreancesListScreen> createState() => _CreancesListScreenState();
}

class _CreancesListScreenState extends State<CreancesListScreen> {
  final _rechercheController = TextEditingController();
  String _recherche = '';
  PhaseCreance? _filtrePhase;
  SituationCreance? _filtreSituation;
  String? _filtreMandant;
  String? _filtreContestation;
  bool _afficherFiltres = false;
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  Future<void> _load() => _repo.refreshAll();

  void _reinitialiserFiltres() {
    _rechercheController.clear();
    setState(() {
      _recherche = '';
      _filtrePhase = null;
      _filtreSituation = null;
      _filtreMandant = null;
      _filtreContestation = null;
    });
  }

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

  Widget _buildHeader(List<dynamic> mandants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilterSearchField(
          controller: _rechercheController,
          hint: 'Référence, débiteur ou nature',
          onChanged: (value) => setState(() => _recherche = normalizeText(value)),
        ),
        FilterChips<PhaseCreance>(
          values: PhaseCreance.values,
          selected: _filtrePhase,
          label: (phase) => phase.libelle,
          onChanged: (value) => setState(() => _filtrePhase = value),
          allLabel: 'Toutes les phases',
        ),
        FilterPanel(
          show: _afficherFiltres,
          onToggle: () => setState(() => _afficherFiltres = !_afficherFiltres),
          onReset: _reinitialiserFiltres,
          children: [
            FilterDropdown<SituationCreance>(
              label: 'Situation',
              value: _filtreSituation,
              items: [
                const DropdownMenuItem<SituationCreance>(
                  value: null,
                  child: Text('Toutes les situations'),
                ),
                for (final situation in SituationCreance.values)
                  DropdownMenuItem<SituationCreance>(
                    value: situation,
                    child: Text(situation.libelle),
                  ),
              ],
              onChanged: (value) => setState(() => _filtreSituation = value),
              width: 190,
            ),
            FilterDropdown<String>(
              label: 'Mandant',
              value: _filtreMandant,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('Tous les mandants')),
                for (final mandant in mandants)
                  DropdownMenuItem<String>(
                    value: (mandant['id'] ?? '').toString(),
                    child: Text(
                      (mandant['sigle'] ?? mandant['nom'] ?? mandant['id'] ?? '').toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _filtreMandant = value),
              width: 190,
            ),
            FilterDropdown<String>(
              label: 'Contestation',
              value: _filtreContestation,
              items: const [
                DropdownMenuItem<String>(value: null, child: Text('Toutes')),
                DropdownMenuItem<String>(value: 'contestees', child: Text('Contestées')),
                DropdownMenuItem<String>(value: 'nonContestees', child: Text('Non contestées')),
              ],
              onChanged: (value) => setState(() => _filtreContestation = value),
              width: 170,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => context.go('/creances/nouvelle'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nouvelle créance'),
            ),
          ),
        ),
      ],
    );
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
                  FilledButton(
                    onPressed: () => setState(() => _future = _load()),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final debiteursParId = {for (final d in _repo.debiteurs) d.id: d};
        final mandants = _repo.mandants
            .whereType<Map>()
            .map((mandant) => Map<String, dynamic>.from(mandant))
            .where((mandant) => (mandant['id'] ?? '').toString().isNotEmpty)
            .toList()
          ..sort((a, b) => (a['sigle'] ?? a['nom'] ?? '')
              .toString()
              .compareTo((b['sigle'] ?? b['nom'] ?? '').toString()));

        final creances = _repo.creances.where((creance) {
          final debiteur = debiteursParId[creance.debiteurId];
          final matchRecherche = _recherche.isEmpty ||
              normalizeText(creance.reference).contains(_recherche) ||
              normalizeText(debiteur?.nom ?? '').contains(_recherche) ||
              normalizeText(creance.nature).contains(_recherche);
          final matchPhase = _filtrePhase == null || creance.phase == _filtrePhase;
          final matchSituation =
              _filtreSituation == null || creance.situation == _filtreSituation;
          final matchMandant =
              _filtreMandant == null || creance.mandant == _filtreMandant;
          final matchContestation = _filtreContestation == null ||
              (_filtreContestation == 'contestees') == creance.contestee;
          return matchRecherche &&
              matchPhase &&
              matchSituation &&
              matchMandant &&
              matchContestation;
        }).toList();

        return PaginatedListView<Creance>(
          items: creances,
          itemLabel: 'créances',
          emptyMessage: 'Aucune créance ne correspond à votre recherche.',
          header: _buildHeader(mandants),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          resetToken: '$_recherche|$_filtrePhase|$_filtreSituation|$_filtreMandant|$_filtreContestation',
          onRefresh: () async {
            await _load();
            if (mounted) setState(() {});
          },
          itemBuilder: (context, creance) {
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
                          StatusBadge(
                            label: creance.phase.libelle,
                            color: _couleurPhase(creance.phase),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(debiteur?.nom ?? 'Débiteur ${creance.debiteurId}'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.description_outlined,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              creance.nature,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Solde : ${formatFcfa(creance.soldeRestant)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
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
        );
      },
    );
  }
}
