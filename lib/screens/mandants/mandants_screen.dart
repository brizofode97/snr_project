import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../app/theme.dart';
import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/status_badge.dart';

class MandantsScreen extends StatefulWidget {
  const MandantsScreen({super.key});

  @override
  State<MandantsScreen> createState() => _MandantsScreenState();
}

class _MandantsScreenState extends State<MandantsScreen> {
  late Future<List<dynamic>> _future;
  final TextEditingController _recherche = TextEditingController();
  int _page = 0;
  int _pageSize = 10;

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
    _page = 0;
    _future = CreancesApiService.instance.getMandants();
  });

  String _normaliser(String value) {
    var texte = value.toLowerCase();
    const remplacements = <String, String>{
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'á': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'í': 'i',
      'ô': 'o',
      'ö': 'o',
      'ó': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ú': 'u',
      'ç': 'c',
      'œ': 'oe',
      'æ': 'ae',
    };
    remplacements.forEach((cle, valeur) {
      texte = texte.replaceAll(cle, valeur);
    });
    return texte
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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

        final recherche = _normaliser(_recherche.text);
        final mandants =
            (snapshot.data ?? const <dynamic>[])
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .where((mandant) {
                  if (recherche.isEmpty) return true;
                  final mandat = mandant['mandat'] is Map
                      ? Map<String, dynamic>.from(mandant['mandat'] as Map)
                      : <String, dynamic>{};
                  return _normaliser(
                    <String>[
                      (mandant['sigle'] ?? '').toString(),
                      (mandant['nom'] ?? '').toString(),
                      (mandat['ref'] ?? '').toString(),
                      (mandant['contact'] ?? '').toString(),
                    ].join(' '),
                  ).contains(recherche);
                })
                .toList()
              ..sort((a, b) {
                final actifA = a['actif'] != false ? 1 : 0;
                final actifB = b['actif'] != false ? 1 : 0;
                if (actifA != actifB) return actifB - actifA;
                return (a['sigle'] ?? '').toString().compareTo(
                  (b['sigle'] ?? '').toString(),
                );
              });

        final pages = mandants.isEmpty
            ? 1
            : (mandants.length / _pageSize).ceil();
        final page = _page.clamp(0, pages - 1);
        final visibles = pageItems(mandants, page, _pageSize);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _recherche,
                decoration: const InputDecoration(
                  hintText: 'Sigle, nom, référence du mandat, contact…',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() => _page = 0),
              ),
            ),
            Expanded(
              child: visibles.isEmpty
                  ? const EmptyPlaceholder(
                      message: 'Aucun mandant ne correspond à la recherche.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      itemCount: visibles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final mandant = visibles[index];
                        final mandat = mandant['mandat'] is Map
                            ? Map<String, dynamic>.from(
                                mandant['mandat'] as Map,
                              )
                            : <String, dynamic>{};
                        final actif = mandant['actif'] != false;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: snrPrimary.withValues(
                                    alpha: 0.12,
                                  ),
                                  child: Icon(
                                    Icons.apartment_outlined,
                                    color: snrPrimary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${mandant['sigle'] ?? '—'} — ${mandant['nom'] ?? '—'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        <String>[
                                          if ((mandat['ref'] ?? '')
                                              .toString()
                                              .isNotEmpty)
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
                                        color: actif
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Voir les détails',
                                  icon: const Icon(Icons.visibility_outlined),
                                  onPressed: () =>
                                      _ouvrirDetails(context, mandant),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            PaginationBar(
              page: page,
              pageSize: _pageSize,
              total: mandants.length,
              itemLabel: 'mandant(s)',
              onPageChanged: (value) => setState(() => _page = value),
              onPageSizeChanged: (value) => setState(() {
                _pageSize = value;
                _page = 0;
              }),
            ),
          ],
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
