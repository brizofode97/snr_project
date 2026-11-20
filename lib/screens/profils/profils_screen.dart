import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';

class ProfilsScreen extends StatefulWidget {
  const ProfilsScreen({super.key});

  @override
  State<ProfilsScreen> createState() => _ProfilsScreenState();
}

class _ProfilsScreenState extends State<ProfilsScreen> {
  late Future<({List<dynamic> profils, Map<String, String> catalogue})> _future;
  final TextEditingController _recherche = TextEditingController();
  String? _origine;
  String? _mfa;
  bool _filtresVisibles = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _future = _charger();
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
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
    _generation++;
    _future = _charger();
  });

  void _reinitialiser() {
    _recherche.clear();
    setState(() {
      _origine = null;
      _mfa = null;
    });
  }

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

        final catalogue = snapshot.data?.catalogue ?? const <String, String>{};
        final profilsSource = (snapshot.data?.profils ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        final query = normalizeText(_recherche.text);
        final profils = profilsSource.where((profil) {
          final code = (profil['code'] ?? '').toString();
          final droits = profil['droits'] is List
              ? (profil['droits'] as List).map((e) => e.toString()).toList()
              : <String>[];
          final origine = profil['systeme'] == true ? 'Système' : 'Créé';
          final mfa = profil['authentificationForte'] == true ? 'Oui' : 'Non';
          if (_origine != null && origine != _origine) return false;
          if (_mfa != null && mfa != _mfa) return false;
          if (query.isEmpty) return true;
          final droitsTexte = droits.map((d) => catalogue[d] ?? d).join(' ');
          return normalizeText(
            '${profil['libelle'] ?? ''} $code $origine $droitsTexte',
          ).contains(query);
        }).toList();

        final header = Column(
          mainAxisSize: MainAxisSize.min,
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
            FilterSearchField(
              controller: _recherche,
              hint: 'Libellé, code, droit…',
              onChanged: (_) => setState(() {}),
            ),
            FilterChips<String>(
              values: const <String>['Système', 'Créé'],
              selected: _origine,
              label: (value) => value,
              onChanged: (value) => setState(() => _origine = value),
            ),
            FilterPanel(
              show: _filtresVisibles,
              onToggle: () =>
                  setState(() => _filtresVisibles = !_filtresVisibles),
              onReset: _reinitialiser,
              children: [
                FilterDropdown<String?>(
                  label: 'Authentification forte',
                  value: _mfa,
                  width: 200,
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Toutes'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Oui',
                      child: Text('Oui (OTP)'),
                    ),
                    DropdownMenuItem<String?>(value: 'Non', child: Text('Non')),
                  ],
                  onChanged: (value) => setState(() => _mfa = value),
                ),
              ],
            ),
          ],
        );

        return PaginatedListView<Map<String, dynamic>>(
          key: ValueKey(_generation),
          items: profils,
          itemLabel: 'profil(s)',
          emptyMessage: profilsSource.isEmpty
              ? 'Aucun profil configuré.'
              : 'Aucun profil ne correspond aux filtres.',
          header: header,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, profil) {
            final code = (profil['code'] ?? '').toString();
            final droits = profil['droits'] is List
                ? (profil['droits'] as List).map((e) => e.toString()).toList()
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
                      backgroundColor: snrPrimary.withValues(alpha: 0.12),
                      child: Text(
                        code.isEmpty ? '?' : code.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: snrPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (profil['libelle'] ?? code).toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            <String>[
                              code,
                              origine,
                              if (profil['authentificationForte'] == true)
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
                      onPressed: () =>
                          _ouvrirDetails(context, profil, droits, catalogue),
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
