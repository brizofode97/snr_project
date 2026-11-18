import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/utilisateur.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class UtilisateursListScreen extends StatefulWidget {
  const UtilisateursListScreen({super.key});

  @override
  State<UtilisateursListScreen> createState() => _UtilisateursListScreenState();
}

class _UtilisateursListScreenState extends State<UtilisateursListScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = _repo.utilisateurs.isEmpty ? _repo.refreshAll() : Future.value();
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

        final utilisateurs = _repo.utilisateurs;
        return Scaffold(
          body: utilisateurs.isEmpty
              ? const EmptyPlaceholder(message: 'Aucun utilisateur.')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: utilisateurs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final u = utilisateurs[index];
                    return Card(
                      child: ListTile(
                        onTap: () => context.push('/utilisateurs/${u.id}'),
                        leading: CircleAvatar(
                          child: Text(u.prenom.characters.first),
                        ),
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
