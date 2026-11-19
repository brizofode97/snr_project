import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/pagination_bar.dart';

class ProfilsScreen extends StatefulWidget {
  const ProfilsScreen({super.key});

  @override
  State<ProfilsScreen> createState() => _ProfilsScreenState();
}

class _ProfilsScreenState extends State<ProfilsScreen> {
  late Future<({List<dynamic> profils, Map<String, String> catalogue})> _future;
  int _page = 0;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _future = _charger();
  }

  Future<({List<dynamic> profils, Map<String, String> catalogue})>
  _charger() async {
    final resultats = await Future.wait(<Future<List<dynamic>>>[
      CreancesApiService.instance.getProfilsAdmin(),
      CreancesApiService.instance.getProfilsCatalogue(),
    ]);
    final catalogue = <String, String>{
      for (final droit in resultats[1])
        if (droit is Map)
          (droit['code'] ?? '').toString():
              (droit['libelle'] ?? droit['code'] ?? '').toString(),
    };
    return (profils: resultats[0], catalogue: catalogue);
  }

  void _recharger() => setState(() {
    _page = 0;
    _future = _charger();
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({List<dynamic> profils, Map<String, String> catalogue})
    >(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final message = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Erreur de chargement des profils et rôles.';
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

        final profils = snapshot.data?.profils ?? const <dynamic>[];
        final catalogue = snapshot.data?.catalogue ?? const <String, String>{};
        final pages = profils.isEmpty ? 1 : (profils.length / _pageSize).ceil();
        final page = _page.clamp(0, pages - 1);
        final visibles = pageItems(profils, page, _pageSize);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Profils et rôles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualiser',
                    icon: const Icon(Icons.refresh),
                    onPressed: _recharger,
                  ),
                ],
              ),
            ),
            Expanded(
              child: visibles.isEmpty
                  ? const EmptyPlaceholder(message: 'Aucun profil configuré.')
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: visibles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final profil = visibles[index] is Map
                            ? Map<String, dynamic>.from(visibles[index] as Map)
                            : <String, dynamic>{};
                        final code = (profil['code'] ?? '').toString();
                        final droits = profil['droits'] is List
                            ? (profil['droits'] as List)
                                  .map((e) => e.toString())
                                  .toList()
                            : <String>[];
                        final origine = profil['systeme'] == true
                            ? (profil['verrouille'] == true
                                  ? 'Système · droits fixes'
                                  : 'Système')
                            : 'Créé';
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
                                  child: Text(
                                    code.isEmpty
                                        ? '?'
                                        : code.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: snrPrimary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (profil['libelle'] ?? code).toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        <String>[
                                          code,
                                          origine,
                                          if (profil['authentificationForte'] ==
                                              true)
                                            'MFA',
                                          '${droits.length} droit(s)',
                                          '${profil['utilisateurs'] ?? '—'} compte(s)',
                                        ].join(' · '),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Voir les détails',
                                  icon: const Icon(Icons.visibility_outlined),
                                  onPressed: () => _ouvrirDetails(
                                    context,
                                    profil,
                                    droits,
                                    catalogue,
                                  ),
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
              total: profils.length,
              itemLabel: 'profil(s)',
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

  void _ouvrirDetails(
    BuildContext context,
    Map<String, dynamic> profil,
    List<String> droits,
    Map<String, String> catalogue,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final code = (profil['code'] ?? '').toString();
        return AlertDialog(
          title: Text('Profil ${profil['libelle'] ?? code}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DetailLigne(label: 'Code', value: code),
                  _DetailLigne(
                    label: 'Libellé',
                    value: (profil['libelle'] ?? '—').toString(),
                  ),
                  _DetailLigne(
                    label: 'Origine',
                    value: profil['systeme'] == true
                        ? (profil['verrouille'] == true
                              ? 'Système · droits fixes'
                              : 'Système')
                        : 'Créé',
                  ),
                  _DetailLigne(
                    label: 'Authentification forte',
                    value: profil['authentificationForte'] == true
                        ? 'Exigée (OTP)'
                        : 'Non',
                  ),
                  _DetailLigne(
                    label: 'Comptes',
                    value: '${profil['utilisateurs'] ?? '—'}',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Droits',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (droits.isEmpty)
                    const Text('Accès limité à son portail.')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final droit in droits)
                          Chip(
                            label: Text(catalogue[droit] ?? droit),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
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
            width: 150,
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
