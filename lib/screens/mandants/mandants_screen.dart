import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../app/theme.dart';
import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';

class MandantsScreen extends StatefulWidget {
  const MandantsScreen({super.key});

  @override
  State<MandantsScreen> createState() => _MandantsScreenState();
}

class _MandantsScreenState extends State<MandantsScreen> {
  late Future<List<dynamic>> _future;
  final TextEditingController _recherche = TextEditingController();
  String? _statut;
  String? _perimetre;
  bool _filtresVisibles = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _future = CreancesApiService.instance.getMandants();
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  void _recharger() => setState(() {
    _generation++;
    _future = CreancesApiService.instance.getMandants();
  });

  void _reinitialiser() {
    _recherche.clear();
    setState(() {
      _statut = null;
      _perimetre = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final message = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Erreur de chargement des mandants.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _recharger,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final sources = (snapshot.data ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        final perimetres =
            sources
                .map(
                  (mandant) => mandant['mandat'] is Map
                      ? (Map<String, dynamic>.from(
                                  mandant['mandat'] as Map,
                                )['perimetre'] ??
                                '')
                            .toString()
                      : '',
                )
                .where((perimetre) => perimetre.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final perimetre = _perimetre != null && perimetres.contains(_perimetre)
            ? _perimetre
            : null;
        final recherche = normalizeText(_recherche.text);
        final mandants =
            sources.where((mandant) {
              final mandat = mandant['mandat'] is Map
                  ? Map<String, dynamic>.from(mandant['mandat'] as Map)
                  : <String, dynamic>{};
              final actif = mandant['actif'] != false;
              if (_statut == 'Actif' && !actif) return false;
              if (_statut == 'Désactivé' && actif) return false;
              if (perimetre != null &&
                  (mandat['perimetre'] ?? '').toString() != perimetre) {
                return false;
              }
              if (recherche.isEmpty) return true;
              return normalizeText(
                <String>[
                  (mandant['sigle'] ?? '').toString(),
                  (mandant['nom'] ?? '').toString(),
                  (mandat['ref'] ?? '').toString(),
                  (mandant['contact'] ?? '').toString(),
                ].join(' '),
              ).contains(recherche);
            }).toList()..sort((a, b) {
              final actifA = a['actif'] != false ? 1 : 0;
              final actifB = b['actif'] != false ? 1 : 0;
              if (actifA != actifB) return actifB - actifA;
              return (a['sigle'] ?? '').toString().compareTo(
                (b['sigle'] ?? '').toString(),
              );
            });

        final header = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilterSearchField(
              controller: _recherche,
              hint: 'Sigle, nom, référence du mandat, contact…',
              onChanged: (_) => setState(() {}),
            ),
            FilterChips<String>(
              values: const <String>['Actif', 'Désactivé'],
              selected: _statut,
              label: (value) => value,
              onChanged: (value) => setState(() => _statut = value),
            ),
            FilterPanel(
              show: _filtresVisibles,
              onToggle: () =>
                  setState(() => _filtresVisibles = !_filtresVisibles),
              onReset: _reinitialiser,
              children: [
                FilterDropdown<String?>(
                  label: 'Périmètre',
                  value: perimetre,
                  width: 180,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tous'),
                    ),
                    for (final item in perimetres)
                      DropdownMenuItem<String?>(value: item, child: Text(item)),
                  ],
                  onChanged: (value) => setState(() => _perimetre = value),
                ),
              ],
            ),
          ],
        );

        return PaginatedListView<Map<String, dynamic>>(
          key: ValueKey(_generation),
          items: mandants,
          itemLabel: 'mandant(s)',
          emptyMessage: 'Aucun mandant ne correspond à la recherche.',
          header: header,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          itemBuilder: (context, mandant) {
            final mandat = mandant['mandat'] is Map
                ? Map<String, dynamic>.from(mandant['mandat'] as Map)
                : <String, dynamic>{};
            final actif = mandant['actif'] != false;
            return Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: snrPrimary.withValues(alpha: 0.12),
                      child: Icon(Icons.apartment_outlined, color: snrPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${mandant['sigle'] ?? '—'} — ${mandant['nom'] ?? '—'}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            <String>[
                              if ((mandat['ref'] ?? '').toString().isNotEmpty)
                                'Mandat ${mandat['ref']}',
                              if ((mandant['contact'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                mandant['contact'].toString(),
                              '${mandant['creances'] ?? 0} créance(s)',
                            ].join(' · '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          StatusBadge(
                            label: actif ? 'Actif' : 'Désactivé',
                            color: actif ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Voir les détails',
                      icon: const Icon(Icons.visibility_outlined),
                      onPressed: () => _ouvrirDetails(context, mandant),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _ouvrirDetails(BuildContext context, Map<String, dynamic> mandant) {
    final mandat = mandant['mandat'] is Map
        ? Map<String, dynamic>.from(mandant['mandat'] as Map)
        : <String, dynamic>{};
    final actif = mandant['actif'] != false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Mandant ${mandant['sigle'] ?? ''}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DetailLigne(
                    label: 'Sigle',
                    value: (mandant['sigle'] ?? '—').toString(),
                  ),
                  _DetailLigne(
                    label: 'Organisme',
                    value: (mandant['nom'] ?? '—').toString(),
                  ),
                  _DetailLigne(
                    label: 'Contact',
                    value: (mandant['contact'] ?? '—').toString(),
                  ),
                  _DetailLigne(
                    label: 'Mandat',
                    value: (mandat['ref'] ?? '—').toString(),
                  ),
                  _DetailLigne(label: 'Période', value: _periode(mandat)),
                  _DetailLigne(
                    label: 'Commission',
                    value: '${mandat['commission'] ?? 0} %',
                  ),
                  _DetailLigne(
                    label: 'Périmètre',
                    value: (mandat['perimetre'] ?? '—').toString(),
                  ),
                  _DetailLigne(
                    label: 'Reporting',
                    value: (mandat['reporting'] ?? '—').toString(),
                  ),
                  _DetailLigne(
                    label: 'Reversement',
                    value: (mandat['reversement'] ?? '—').toString(),
                  ),
                  _DetailLigne(
                    label: 'Frais',
                    value: (mandat['frais'] ?? '—').toString(),
                  ),
                  _DetailLigne(
                    label: 'Portefeuille',
                    value: (mandant['portefeuille'] ?? '—').toString(),
                  ),
                  _DetailLigne(
                    label: 'Créances',
                    value: '${mandant['creances'] ?? 0}',
                  ),
                  _DetailLigne(
                    label: 'Statut',
                    value: actif ? 'Actif' : 'Désactivé',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  String _periode(Map<String, dynamic> mandat) {
    final debut = DateTime.tryParse((mandat['debut'] ?? '').toString());
    final fin = DateTime.tryParse((mandat['fin'] ?? '').toString());
    final debutTexte = debut == null ? '—' : formatDate(debut);
    final finTexte = fin == null ? 'sans terme' : formatDate(fin);
    return '$debutTexte → $finTexte';
  }
}

class _DetailLigne extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLigne({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
