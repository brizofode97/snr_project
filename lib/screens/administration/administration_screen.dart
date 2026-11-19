import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../app/menu.dart';
import '../../core/auth/auth_service.dart';
import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/status_badge.dart';

class AdministrationScreen extends StatelessWidget {
  const AdministrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final onglets = <({String label, Widget child})>[
      if (aPermission(user, 'admin.users'))
        (label: 'Rôles et droits', child: const _RolesTab()),
      if (aPermission(user, 'admin.users'))
        (label: 'Paramètres', child: const _ParametresTab()),
      (label: "Journal d'audit", child: const _AuditTab()),
      (label: 'Contrôles de cohérence', child: const _ControlesTab()),
    ];

    return DefaultTabController(
      length: onglets.length,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.primary,
            child: TabBar(
              isScrollable: true,
              tabs: [for (final onglet in onglets) Tab(text: onglet.label)],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [for (final onglet in onglets) onglet.child],
            ),
          ),
        ],
      ),
    );
  }
}

String _messageErreur(Object? error, String defaut) =>
    error is ApiException ? error.message : defaut;

String _libelleComposante(String composante) => switch (composante) {
  'frais' => 'Frais',
  'interets' => 'Intérêts',
  'principal' => 'Principal',
  _ => composante,
};

class _ErreurChargement extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErreurChargement({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

class _RolesTab extends StatefulWidget {
  const _RolesTab();

  @override
  State<_RolesTab> createState() => _RolesTabState();
}

class _RolesTabState extends State<_RolesTab> {
  late Future<({List<dynamic> profils, List<dynamic> catalogue})> _future;

  @override
  void initState() {
    super.initState();
    _future = _charger();
  }

  Future<({List<dynamic> profils, List<dynamic> catalogue})> _charger() async {
    final resultats = await Future.wait(<Future<List<dynamic>>>[
      CreancesApiService.instance.getAdminDroits(),
      CreancesApiService.instance.getProfilsCatalogue(),
    ]);
    return (profils: resultats[0], catalogue: resultats[1]);
  }

  void _recharger() => setState(() => _future = _charger());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({List<dynamic> profils, List<dynamic> catalogue})>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErreurChargement(
            message: _messageErreur(
              snapshot.error,
              'Erreur de chargement des rôles et droits.',
            ),
            onRetry: _recharger,
          );
        }

        final profils = (snapshot.data?.profils ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .where(
              (p) => !<String>[
                'MANDANT',
                'DEBITEUR',
              ].contains((p['code'] ?? '').toString().toUpperCase()),
            )
            .toList();

        final libelles = <String, String>{
          for (final droit in snapshot.data?.catalogue ?? const <dynamic>[])
            if (droit is Map)
              (droit['code'] ?? '').toString():
                  (droit['libelle'] ?? droit['code'] ?? '').toString(),
        };
        for (final profil in profils) {
          final droits = profil['droits'];
          if (droits is List) {
            for (final droit in droits) {
              libelles.putIfAbsent(droit.toString(), () => droit.toString());
            }
          }
        }

        if (profils.isEmpty || libelles.isEmpty) {
          return const EmptyPlaceholder(
            message: 'Aucun rôle ou droit configuré.',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Matrice des droits',
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
              const SizedBox(height: 4),
              Text(
                'Droits appliqués par le serveur. Les profils Mandant et Débiteur utilisent des portails dédiés.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 44,
                  dataRowMinHeight: 36,
                  dataRowMaxHeight: 44,
                  columnSpacing: 20,
                  columns: [
                    const DataColumn(label: Text('Droit')),
                    for (final profil in profils)
                      DataColumn(
                        label: Tooltip(
                          message: (profil['libelle'] ?? '').toString(),
                          child: Text((profil['code'] ?? '').toString()),
                        ),
                      ),
                  ],
                  rows: [
                    for (final entry in libelles.entries)
                      DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 210,
                              child: Text(
                                entry.value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          for (final profil in profils)
                            DataCell(
                              _MarqueDroit(
                                autorise: _aDroit(profil, entry.key),
                              ),
                            ),
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

  bool _aDroit(Map<String, dynamic> profil, String droit) {
    final droits = profil['droits'];
    return droits is List && droits.map((e) => e.toString()).contains(droit);
  }
}

class _MarqueDroit extends StatelessWidget {
  final bool autorise;

  const _MarqueDroit({required this.autorise});

  @override
  Widget build(BuildContext context) {
    return Icon(
      autorise ? Icons.check : Icons.close,
      size: 18,
      color: autorise ? Colors.green.shade700 : Colors.red.shade400,
    );
  }
}

class _ParametresTab extends StatefulWidget {
  const _ParametresTab();

  @override
  State<_ParametresTab> createState() => _ParametresTabState();
}

class _ParametresTabState extends State<_ParametresTab> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = CreancesApiService.instance.getParametresMetier();
  }

  void _recharger() => setState(
    () => _future = CreancesApiService.instance.getParametresMetier(),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErreurChargement(
            message: _messageErreur(
              snapshot.error,
              'Erreur de chargement des paramètres.',
            ),
            onRetry: _recharger,
          );
        }

        final parametres = snapshot.data ?? <String, dynamic>{};
        final pieces = parametres['piecesObligatoires'] is List
            ? (parametres['piecesObligatoires'] as List)
                  .map((e) => e.toString())
                  .toList()
            : <String>[];
        final imputation = parametres['imputation'] is List
            ? (parametres['imputation'] as List)
                  .map((e) => _libelleComposante(e.toString()))
                  .join(' → ')
            : '—';
        final delais = parametres['delais'] is List
            ? (parametres['delais'] as List)
            : const <dynamic>[];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Paramètres métier',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Actualiser',
                  icon: const Icon(Icons.refresh),
                  onPressed: _recharger,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Consultation seule sur mobile. Les modifications se font depuis le web et sont tracées dans le journal d\'audit.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _LigneInfo(
                    label: 'Délai de grâce',
                    value: '${parametres['graceJours'] ?? '—'} jours',
                  ),
                  _LigneInfo(
                    label: 'Seuil d\'inactivité',
                    value: '${parametres['inactiviteJours'] ?? '—'} jours',
                  ),
                  _LigneInfo(
                    label: 'Relance suspendue en contestation',
                    value: parametres['relanceSuspendueContestation'] == true
                        ? 'Oui'
                        : 'Non',
                  ),
                  _LigneInfo(label: 'Règle d\'imputation', value: imputation),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pièces obligatoires',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (pieces.isEmpty)
              Text(
                'Aucune pièce obligatoire.',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final piece in pieces)
                    Chip(
                      label: Text(piece),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            const SizedBox(height: 18),
            const Text(
              'Délais juridiques',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (delais.isEmpty)
              Text(
                'Aucun délai lu.',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              for (final delai in delais)
                Card(
                  child: ListTile(
                    title: Text(
                      delai is Map ? (delai['libelle'] ?? '—').toString() : '—',
                    ),
                    subtitle: Text(
                      delai is Map
                          ? <String>[
                              if (delai['sectionManuel'] != null)
                                (delai['sectionManuel']).toString(),
                              if (delai['statut'] != null)
                                (delai['statut']).toString(),
                            ].join(' · ')
                          : '',
                    ),
                    trailing: Text(
                      delai is Map
                          ? '${delai['valeur'] ?? '—'} ${delai['unite'] ?? ''}'
                                .trim()
                          : '—',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _LigneInfo extends StatelessWidget {
  final String label;
  final String value;

  const _LigneInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditTab extends StatefulWidget {
  const _AuditTab();

  @override
  State<_AuditTab> createState() => _AuditTabState();
}

class _AuditTabState extends State<_AuditTab> {
  late Future<({List<dynamic> entrees, Map<String, dynamic> verification})>
  _future;
  int _page = 0;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _future = _charger();
  }

  Future<({List<dynamic> entrees, Map<String, dynamic> verification})>
  _charger() async {
    final resultats = await Future.wait(<Future<dynamic>>[
      CreancesApiService.instance.getAudit(),
      CreancesApiService.instance.getAuditVerification(),
    ]);
    return (
      entrees: resultats[0] as List<dynamic>,
      verification: Map<String, dynamic>.from(resultats[1] as Map),
    );
  }

  void _recharger() => setState(() {
    _page = 0;
    _future = _charger();
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({List<dynamic> entrees, Map<String, dynamic> verification})
    >(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErreurChargement(
            message: _messageErreur(
              snapshot.error,
              'Erreur de chargement du journal d\'audit.',
            ),
            onRetry: _recharger,
          );
        }

        final entrees = snapshot.data?.entrees ?? const <dynamic>[];
        final verification = snapshot.data?.verification ?? <String, dynamic>{};
        final chaineOk = verification['ok'] != false;
        final pages = entrees.isEmpty ? 1 : (entrees.length / _pageSize).ceil();
        final page = _page.clamp(0, pages - 1);
        final visibles = pageItems(entrees, page, _pageSize);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Journal d\'audit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StatusBadge(
                    label: chaineOk ? 'Chaîne intègre' : 'Chaîne rompue',
                    color: chaineOk ? Colors.green : Colors.red,
                  ),
                  IconButton(
                    tooltip: 'Actualiser',
                    icon: const Icon(Icons.refresh),
                    onPressed: _recharger,
                  ),
                ],
              ),
            ),
            if (verification['entrees'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    chaineOk
                        ? '${verification['entrees']} entrée(s) vérifiée(s) sur le serveur.'
                        : '${verification['entrees']} entrée(s) vérifiée(s) : première incohérence à l\'entrée n° ${verification['rupture'] ?? '—'}.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ),
            Expanded(
              child: visibles.isEmpty
                  ? const EmptyPlaceholder(
                      message: 'Aucune entrée dans le journal d\'audit.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: visibles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entree = visibles[index] is Map
                            ? Map<String, dynamic>.from(visibles[index] as Map)
                            : <String, dynamic>{};
                        final date = DateTime.tryParse(
                          (entree['ts'] ?? '').toString(),
                        );
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  child: Text(
                                    (entree['numero'] ?? '—').toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entree['action'] ?? '—'} — ${entree['objet'] ?? '—'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        <String>[
                                          if (date != null)
                                            formatDateTime(date),
                                          (entree['userId'] ?? '—').toString(),
                                          if ((entree['detail'] ?? '')
                                              .toString()
                                              .isNotEmpty)
                                            entree['detail'].toString(),
                                        ].join(' · '),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
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
              total: entrees.length,
              itemLabel: 'entrée(s)',
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
}

class _ControlesTab extends StatefulWidget {
  const _ControlesTab();

  @override
  State<_ControlesTab> createState() => _ControlesTabState();
}

class _ControlesTabState extends State<_ControlesTab> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = CreancesApiService.instance.getAdminControles();
  }

  void _recharger() =>
      setState(() => _future = CreancesApiService.instance.getAdminControles());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErreurChargement(
            message: _messageErreur(
              snapshot.error,
              'Erreur de chargement des contrôles.',
            ),
            onRetry: _recharger,
          );
        }

        final controles = snapshot.data ?? const <dynamic>[];
        final conformes = controles.where((controle) {
          return controle is Map && controle['conforme'] == true;
        }).length;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Contrôles de cohérence',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (controles.isNotEmpty)
                    StatusBadge(
                      label: '$conformes / ${controles.length} conformes',
                      color: conformes == controles.length
                          ? Colors.green
                          : Colors.red,
                    ),
                  IconButton(
                    tooltip: 'Relancer les contrôles',
                    icon: const Icon(Icons.refresh),
                    onPressed: _recharger,
                  ),
                ],
              ),
            ),
            Expanded(
              child: controles.isEmpty
                  ? const EmptyPlaceholder(message: 'Aucun contrôle lu.')
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: controles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final controle = controles[index] is Map
                            ? Map<String, dynamic>.from(controles[index] as Map)
                            : <String, dynamic>{};
                        final conforme = controle['conforme'] == true;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  conforme
                                      ? Icons.check_circle_outline
                                      : Icons.error_outline,
                                  color: conforme
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (controle['libelle'] ?? '—').toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        (controle['detail'] ?? '').toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
