import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/utilisateur.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';

class UtilisateursListScreen extends StatefulWidget {
  const UtilisateursListScreen({super.key});

  @override
  State<UtilisateursListScreen> createState() => _UtilisateursListScreenState();
}

class _UtilisateursListScreenState extends State<UtilisateursListScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;
  final _recherche = TextEditingController();
  ProfilUtilisateur? _profil;
  bool? _actif;
  bool _filtresVisibles = false;

  @override
  void initState() {
    super.initState();
    _future = _repo.utilisateurs.isEmpty ? _repo.refreshAll() : Future.value();
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    _recherche.clear();
    setState(() {
      _profil = null;
      _actif = null;
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
              : 'Erreur de chargement des utilisateurs.';
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

        final query = normalizeText(_recherche.text);
        final utilisateurs = _repo.utilisateurs.where((u) {
          if (_profil != null && u.profil != _profil) return false;
          if (_actif != null && u.actif != _actif) return false;
          if (query.isEmpty) return true;
          return normalizeText(
            '${u.prenom} ${u.nom} ${u.email} ${u.profil.libelle}',
          ).contains(query);
        }).toList();

        final header = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilterSearchField(
              controller: _recherche,
              hint: 'Nom, prénom, e-mail, profil…',
              onChanged: (_) => setState(() {}),
            ),
            FilterChips<bool>(
              values: const <bool>[true, false],
              selected: _actif,
              label: (value) => value ? 'Actif' : 'Inactif',
              onChanged: (value) => setState(() => _actif = value),
            ),
            FilterPanel(
              show: _filtresVisibles,
              onToggle: () =>
                  setState(() => _filtresVisibles = !_filtresVisibles),
              onReset: _reinitialiser,
              children: [
                FilterDropdown<ProfilUtilisateur?>(
                  label: 'Profil',
                  value: _profil,
                  width: 180,
                  items: [
                    const DropdownMenuItem<ProfilUtilisateur?>(
                      value: null,
                      child: Text('Tous les profils'),
                    ),
                    for (final profil in ProfilUtilisateur.values)
                      DropdownMenuItem<ProfilUtilisateur?>(
                        value: profil,
                        child: Text(profil.libelle),
                      ),
                  ],
                  onChanged: (value) => setState(() => _profil = value),
                ),
              ],
            ),
          ],
        );

        return Scaffold(
          body: PaginatedListView<Utilisateur>(
            items: utilisateurs,
            itemLabel: 'utilisateur(s)',
            emptyMessage: 'Aucun utilisateur.',
            header: header,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, u) {
              return Card(
                child: ListTile(
                  onTap: () => context.push('/utilisateurs/${u.id}'),
                  leading: CircleAvatar(child: Text(u.prenom.characters.first)),
                  title: Text('${u.prenom} ${u.nom}'),
                  subtitle: Text('${u.profil.libelle} · ${u.email}'),
                  trailing: StatusBadge(
                    label: u.actif ? 'Actif' : 'Inactif',
                    color: u.actif ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/utilisateurs/nouveau'),
            tooltip: 'Nouvel utilisateur',
            child: const Icon(Icons.person_add_outlined),
          ),
        );
      },
    );
  }
}
