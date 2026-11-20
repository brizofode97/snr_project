import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/debiteur.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';

class DebiteursListScreen extends StatefulWidget {
  const DebiteursListScreen({super.key});

  @override
  State<DebiteursListScreen> createState() => _DebiteursListScreenState();
}

class _DebiteursListScreenState extends State<DebiteursListScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;
  final _recherche = TextEditingController();
  TypeDebiteur? _type;
  String? _ville;
  String? _portail;
  bool _filtresVisibles = false;

  @override
  void initState() {
    super.initState();
    _future = _repo.debiteurs.isEmpty ? _repo.refreshAll() : Future.value();
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    _recherche.clear();
    setState(() {
      _type = null;
      _ville = null;
      _portail = null;
    });
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
              : 'Erreur de chargement des débiteurs.';
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

        final villes =
            _repo.debiteurs
                .map((d) => d.ville.trim())
                .where((ville) => ville.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final ville = _ville != null && villes.contains(_ville) ? _ville : null;
        final query = normalizeText(_recherche.text);
        final debiteurs = _repo.debiteurs.where((d) {
          if (_type != null && d.type != _type) return false;
          if (ville != null && d.ville != ville) return false;
          if (_portail == 'actif' && !d.accesPortailActif) return false;
          if (_portail == 'inactif' && d.accesPortailActif) return false;
          if (query.isEmpty) return true;
          return normalizeText(
            <String>[
              d.nom,
              d.code,
              d.ville,
              d.telephone,
              d.email,
              d.identifiant,
            ].join(' '),
          ).contains(query);
        }).toList();

        final header = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilterSearchField(
              controller: _recherche,
              hint: 'Nom, code, téléphone, e-mail…',
              onChanged: (_) => setState(() {}),
            ),
            FilterChips<TypeDebiteur>(
              values: TypeDebiteur.values,
              selected: _type,
              label: (type) =>
                  type == TypeDebiteur.personnePhysique ? 'Physique' : 'Morale',
              onChanged: (value) => setState(() => _type = value),
            ),
            FilterPanel(
              show: _filtresVisibles,
              onToggle: () =>
                  setState(() => _filtresVisibles = !_filtresVisibles),
              onReset: _reinitialiser,
              children: [
                FilterDropdown<String?>(
                  label: 'Ville',
                  value: ville,
                  width: 150,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Toutes'),
                    ),
                    for (final item in villes)
                      DropdownMenuItem<String?>(value: item, child: Text(item)),
                  ],
                  onChanged: (value) => setState(() => _ville = value),
                ),
                FilterDropdown<String?>(
                  label: 'Portail',
                  value: _portail,
                  width: 160,
                  items: const [
                    DropdownMenuItem<String?>(value: null, child: Text('Tous')),
                    DropdownMenuItem<String?>(
                      value: 'actif',
                      child: Text('Portail actif'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'inactif',
                      child: Text('Portail suspendu'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _portail = value),
                ),
              ],
            ),
          ],
        );

        return PaginatedListView<Debiteur>(
          items: debiteurs,
          itemLabel: 'débiteur(s)',
          emptyMessage: 'Aucun débiteur trouvé.',
          header: header,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemBuilder: (context, d) {
            final nbCreances = _repo.creancesDuDebiteur(d.id).length;
            return Card(
              child: ListTile(
                onTap: () => context.push('/debiteurs/${d.id}'),
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey.shade50,
                  child: Icon(
                    d.type == TypeDebiteur.personnePhysique
                        ? Icons.person_outline
                        : Icons.apartment_outlined,
                    color: Colors.blueGrey,
                  ),
                ),
                title: Text(d.nom),
                subtitle: Text(
                  '${d.code} · ${d.ville} · $nbCreances dossier(s)',
                ),
                trailing: d.accesPortailActif
                    ? const StatusBadge(
                        label: 'Portail actif',
                        color: Colors.green,
                      )
                    : const StatusBadge(
                        label: 'Portail suspendu',
                        color: Colors.red,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
