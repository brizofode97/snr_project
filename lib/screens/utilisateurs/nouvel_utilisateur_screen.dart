import 'package:material_ui/material_ui.dart';

import '../../models/utilisateur.dart';

class NouvelUtilisateurScreen extends StatefulWidget {
  const NouvelUtilisateurScreen({super.key});

  @override
  State<NouvelUtilisateurScreen> createState() => _NouvelUtilisateurScreenState();
}

class _NouvelUtilisateurScreenState extends State<NouvelUtilisateurScreen> {
  ProfilUtilisateur _profil = ProfilUtilisateur.agent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel utilisateur')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Prénom', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'Nom', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<ProfilUtilisateur>(
            initialValue: _profil,
            decoration: const InputDecoration(labelText: 'Profil', border: OutlineInputBorder()),
            items: [
              for (final p in ProfilUtilisateur.values)
                DropdownMenuItem(value: p, child: Text(p.libelle)),
            ],
            onChanged: (v) => setState(() => _profil = v ?? _profil),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Périmètre (portefeuilles / mandant / débiteur)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Création — maquette visuelle uniquement')),
              );
            },
            icon: const Icon(Icons.check),
            label: const Text('Créer l\'utilisateur'),
          ),
        ],
      ),
    );
  }
}
