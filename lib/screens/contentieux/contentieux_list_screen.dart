import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/acte_contentieux.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';

class ContentieuxListScreen extends StatefulWidget {
  const ContentieuxListScreen({super.key});

  @override
  State<ContentieuxListScreen> createState() => _ContentieuxListScreenState();
}

class _ContentieuxListScreenState extends State<ContentieuxListScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;
  final _recherche = TextEditingController();
  StatutActe? _statut;
  String? _type;
  bool _filtresVisibles = false;

  @override
  void initState() {
    super.initState();
    _future = _repo.actesContentieux.isEmpty
        ? _repo.refreshAll()
        : Future.value();
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    _recherche.clear();
    setState(() {
      _statut = null;
      _type = null;
    });
  }

  Color _couleur(StatutActe statut) {
    switch (statut) {
      case StatutActe.enPreparation:
        return Colors.grey;
      case StatutActe.enCircuitVisa:
        return Colors.orange;
      case StatutActe.signe:
        return Colors.blue;
      case StatutActe.notifie:
        return Colors.indigo;
      case StatutActe.clos:
        return Colors.green;
    }
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
              : 'Erreur de chargement des actes contentieux.';
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

        final actesSource = _repo.actesContentieux;
        final types =
            actesSource
                .map((acte) => acte.type.trim())
                .where((type) => type.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final type = _type != null && types.contains(_type) ? _type : null;
        final query = normalizeText(_recherche.text);
        final actes = actesSource.where((acte) {
          if (_statut != null && acte.statut != _statut) return false;
          if (type != null && acte.type != type) return false;
          if (query.isEmpty) return true;
          return normalizeText(
            <String>[
              acte.type,
              acte.debiteurNom,
              acte.statut.libelle,
              acte.creanceId,
            ].join(' '),
          ).contains(query);
        }).toList();

        final header = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilterSearchField(
              controller: _recherche,
              hint: 'Type, débiteur, créance…',
              onChanged: (_) => setState(() {}),
            ),
            FilterChips<StatutActe>(
              values: StatutActe.values,
              selected: _statut,
              label: (statut) => statut.libelle,
              onChanged: (value) => setState(() => _statut = value),
            ),
            FilterPanel(
              show: _filtresVisibles,
              onToggle: () =>
                  setState(() => _filtresVisibles = !_filtresVisibles),
              onReset: _reinitialiser,
              children: [
                FilterDropdown<String?>(
                  label: 'Type d’acte',
                  value: type,
                  width: 180,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tous'),
                    ),
                    for (final item in types)
                      DropdownMenuItem<String?>(value: item, child: Text(item)),
                  ],
                  onChanged: (value) => setState(() => _type = value),
                ),
              ],
            ),
          ],
        );

        return PaginatedListView<ActeContentieux>(
          items: actes,
          itemLabel: 'acte(s)',
          emptyMessage: actesSource.isEmpty
              ? 'Aucun acte contentieux.'
              : 'Aucun acte ne correspond aux filtres.',
          header: header,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, a) {
            return Card(
              child: ListTile(
                onTap: () => context.push('/contentieux/${a.id}'),
                leading: const Icon(Icons.gavel_outlined),
                title: Text(a.type),
                subtitle: Text(
                  '${a.debiteurNom} · Délai : ${formatDate(a.echeanceDelai)}',
                ),
                trailing: StatusBadge(
                  label: a.statut.libelle,
                  color: _couleur(a.statut),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
