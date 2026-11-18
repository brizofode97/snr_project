import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/debiteur.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class DebiteursListScreen extends StatefulWidget {
  const DebiteursListScreen({super.key});

  @override
  State<DebiteursListScreen> createState() => _DebiteursListScreenState();
}

class _DebiteursListScreenState extends State<DebiteursListScreen> {
  String _recherche = '';
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = _repo.debiteurs.isEmpty ? _repo.refreshAll() : Future.value();
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

        final debiteurs = _repo.debiteurs
            .where(
              (d) =>
                  _recherche.isEmpty ||
                  d.nom.toLowerCase().contains(_recherche.toLowerCase()),
            )
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Rechercher un débiteur',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _recherche = v),
              ),
            ),
            Expanded(
              child: debiteurs.isEmpty
                  ? const EmptyPlaceholder(message: 'Aucun débiteur trouvé.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: debiteurs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final d = debiteurs[index];
                        final nbCreances = _repo
                            .creancesDuDebiteur(d.id)
                            .length;
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
                    ),
            ),
          ],
        );
      },
    );
  }
}
