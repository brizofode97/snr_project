import 'package:material_ui/material_ui.dart';

import '../../data/mock_data.dart';
import '../../models/utilisateur.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class UtilisateurDetailScreen extends StatelessWidget {
  final String utilisateurId;

  const UtilisateurDetailScreen({super.key, required this.utilisateurId});

  @override
  Widget build(BuildContext context) {
    final u = MockData.utilisateurParId(utilisateurId);
    if (u == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Utilisateur')),
        body: const EmptyPlaceholder(message: 'Utilisateur introuvable.'),
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${u.prenom} ${u.nom}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Détails'),
              Tab(text: 'Modifier'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${u.prenom} ${u.nom}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            StatusBadge(label: u.actif ? 'Actif' : 'Inactif', color: u.actif ? Colors.green : Colors.red),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Profil : ${u.profil.libelle}'),
                        Text('Email : ${u.email}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  initialValue: u.prenom,
                  decoration: const InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: u.nom,
                  decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: u.email,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () {}, child: const Text('Enregistrer')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
