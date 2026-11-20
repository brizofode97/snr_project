import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/bien_patrimoine.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';
import 'bien_detail_screen.dart';

class PatrimoineListScreen extends StatefulWidget {
  const PatrimoineListScreen({super.key});

  @override
  State<PatrimoineListScreen> createState() => _PatrimoineListScreenState();
}

class _PatrimoineListScreenState extends State<PatrimoineListScreen> {
  final _repo = SnrRepository.instance;
  late Future<void> _future;
  final _recherche = TextEditingController();
  TypeBien? _type;
  String? _statut;
  bool _filtresVisibles = false;

  @override
  void initState() {
    super.initState();
    _future = _repo.creances.isEmpty ? _repo.refreshAll() : Future.value();
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
      _statut = null;
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
              : 'Erreur de chargement du patrimoine.';
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

        final biensSource = BienDetailScreen.biensFromCreances(_repo.creances);
        final statuts =
            biensSource
                .map((bien) => bien.statut.trim())
                .where((statut) => statut.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final statut = _statut != null && statuts.contains(_statut)
            ? _statut
            : null;
        final query = normalizeText(_recherche.text);
        final biens = biensSource.where((bien) {
          if (_type != null && bien.type != _type) return false;
          if (statut != null && bien.statut != statut) return false;
          if (query.isEmpty) return true;
          return normalizeText('${bien.libelle} ${bien.ville} ${bien.statut}')
              .contains(query);
        }).toList();

        final header = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilterSearchField(
              controller: _recherche,
              hint: 'Libellé, ville, statut…',
              onChanged: (_) => setState(() {}),
            ),
            FilterChips<TypeBien>(
              values: TypeBien.values,
              selected: _type,
              label: (type) => type == TypeBien.snr ? 'Bien SNR' : 'Garantie',
              onChanged: (value) => setState(() => _type = value),
            ),
            FilterPanel(
              show: _filtresVisibles,
              onToggle: () =>
                  setState(() => _filtresVisibles = !_filtresVisibles),
              onReset: _reinitialiser,
              children: [
                FilterDropdown<String?>(
                  label: 'Statut',
                  value: statut,
                  width: 180,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tous'),
                    ),
                    for (final item in statuts)
                      DropdownMenuItem<String?>(value: item, child: Text(item)),
                  ],
                  onChanged: (value) => setState(() => _statut = value),
                ),
              ],
            ),
          ],
        );

        return PaginatedListView<BienPatrimoine>(
          items: biens,
          itemLabel: 'bien(s)',
          emptyMessage: biensSource.isEmpty
              ? 'Aucun bien enregistré.'
              : 'Aucun bien ne correspond aux filtres.',
          header: header,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, b) {
            return Card(
              child: ListTile(
                onTap: () => context.push('/patrimoine/${b.id}'),
                leading: Icon(
                  b.type == TypeBien.snr
                      ? Icons.apartment_outlined
                      : Icons.shield_outlined,
                ),
                title: Text(b.libelle),
                subtitle: Text('${b.ville} · ${formatFcfa(b.valeurEstimee)}'),
                trailing: StatusBadge(
                  label: b.type == TypeBien.snr ? 'Bien SNR' : 'Garantie',
                  color: b.type == TypeBien.snr ? Colors.indigo : Colors.teal,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
