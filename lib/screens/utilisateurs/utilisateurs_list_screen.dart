import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../models/utilisateur.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class UtilisateursListScreen extends StatelessWidget {
  const UtilisateursListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MockData.utilisateurs.isEmpty
          ? const EmptyPlaceholder(message: 'Aucun utilisateur.')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: MockData.utilisateurs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final u = MockData.utilisateurs[index];
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
  }
}
