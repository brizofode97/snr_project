import 'package:material_ui/material_ui.dart';

import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/utilisateur.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class UtilisateurDetailScreen extends StatefulWidget {
  final String utilisateurId;

  const UtilisateurDetailScreen({super.key, required this.utilisateurId});

  @override
  State<UtilisateurDetailScreen> createState() => _UtilisateurDetailScreenState();
}

class _UtilisateurDetailScreenState extends State<UtilisateurDetailScreen> {
  final _repo = SnrRepository.instance;
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  late Future<Utilisateur?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<Utilisateur?> _load() async {
    await _repo.refreshAll();
    for (final u in _repo.utilisateurs) {
      if (u.id == widget.utilisateurId) {
        _prenomController.text = u.prenom;
        _nomController.text = u.nom;
        _emailController.text = u.email;
        return u;
      }
    }
    return null;
  }

  String _profilCode(ProfilUtilisateur profil) {
    switch (profil) {
      case ProfilUtilisateur.admin:
        return 'ADMIN';
      case ProfilUtilisateur.dg:
        return 'DG';
      case ProfilUtilisateur.respRec:
        return 'RESP_REC';
      case ProfilUtilisateur.agent:
        return 'AGENT';
      case ProfilUtilisateur.juridique:
        return 'JURIDIQUE';
      case ProfilUtilisateur.comptable:
        return 'COMPTABLE';
      case ProfilUtilisateur.mandant:
        return 'MANDANT';
      case ProfilUtilisateur.debiteur:
        return 'DEBITEUR';
    }
  }

  Future<void> _enregistrer(Utilisateur u) async {
    final code = _profilCode(u.profil);
    try {
      await _repo.saveUtilisateur(<String, dynamic>{
        'id': u.id,
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'email': _emailController.text.trim(),
        'profil': <String, dynamic>{'code': code, 'proCode': code},
        'status': u.actif,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur enregistré.')),
      );
      setState(() => _future = _load());
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Utilisateur?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(title: const Text('Utilisateur')), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Erreur de chargement.';
          return Scaffold(
            appBar: AppBar(title: const Text('Utilisateur')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(msg, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: () => setState(() => _future = _load()), child: const Text('Réessayer')),
                  ],
                ),
              ),
            ),
          );
        }
        final u = snapshot.data;
        if (u == null) {
          return Scaffold(appBar: AppBar(title: const Text('Utilisateur')), body: const EmptyPlaceholder(message: 'Utilisateur introuvable.'));
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
                      controller: _prenomController,
                      decoration: const InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: () => _enregistrer(u), child: const Text('Enregistrer')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
