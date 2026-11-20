import 'package:material_ui/material_ui.dart';

import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../data/snr_repository.dart';
import '../../models/utilisateur.dart';
import '../../widgets/form_widgets.dart';

class NouvelUtilisateurScreen extends StatefulWidget {
  const NouvelUtilisateurScreen({super.key});

  @override
  State<NouvelUtilisateurScreen> createState() => _NouvelUtilisateurScreenState();
}

class _NouvelUtilisateurScreenState extends State<NouvelUtilisateurScreen> {
  final _repo = SnrRepository.instance;
  final _api = CreancesApiService.instance;
  final _form = GlobalKey<FormState>();
  final _prenom = TextEditingController();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _telephone = TextEditingController();
  final _adresse = TextEditingController();

  late Future<void> _future;
  List<dynamic> _portefeuilles = const <dynamic>[];
  final Set<String> _portefeuillesSelectionnes = <String>{};
  String? _mandantId;
  String? _debiteurId;
  ProfilUtilisateur _profil = ProfilUtilisateur.agent;
  bool _actif = true;
  bool _saving = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    _email.dispose();
    _telephone.dispose();
    _adresse.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _repo.refreshAll();
    _portefeuilles = await _api.getPortefeuilles().catchError((_) => <dynamic>[]);
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

  List<DropdownMenuItem<String>> _itemsMandants() {
    final items = <DropdownMenuItem<String>>[];
    for (final mandant in _repo.mandants) {
      if (mandant is! Map) continue;
      final id = (mandant['id'] ?? '').toString();
      if (id.isEmpty) continue;
      final label = (mandant['sigle'] ?? mandant['nom'] ?? id).toString();
      items.add(DropdownMenuItem<String>(value: id, child: Text(label)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> _itemsDebiteurs() {
    return [
      for (final debiteur in _repo.debiteurs)
        if (debiteur.id.isNotEmpty)
          DropdownMenuItem<String>(
            value: debiteur.id,
            child: Text('${debiteur.nom} (${debiteur.id})'),
          ),
    ];
  }

  Future<void> _choisirPortefeuilles() async {
    final temp = Set<String>.from(_portefeuillesSelectionnes);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Portefeuilles de l’agent'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final portefeuille in _portefeuilles)
                  if (portefeuille is Map)
                    CheckboxListTile(
                      title: Text((portefeuille['nom'] ?? portefeuille['id'] ?? '').toString()),
                      value: temp.contains((portefeuille['id'] ?? '').toString()),
                      onChanged: (checked) {
                        final id = (portefeuille['id'] ?? '').toString();
                        setDialogState(() {
                          if (checked == true) {
                            temp.add(id);
                          } else {
                            temp.remove(id);
                          }
                        });
                      },
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                _portefeuillesSelectionnes
                  ..clear()
                  ..addAll(temp);
                Navigator.of(context).pop(true);
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
    if (result == true) setState(() {});
  }

  Future<void> _enregistrer() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _erreur = null;
    });
    final body = <String, dynamic>{
      'prenom': _prenom.text.trim(),
      'nom': _nom.text.trim(),
      'email': _email.text.trim(),
      'telephone': _telephone.text.trim(),
      'adresse': _adresse.text.trim(),
      'profil': <String, dynamic>{'proCode': _profilCode(_profil)},
      'status': _actif,
      if (_profil == ProfilUtilisateur.agent)
        'portefeuilles': _portefeuillesSelectionnes.toList(),
      if (_profil == ProfilUtilisateur.mandant && _mandantId != null)
        'mandantId': _mandantId,
      if (_profil == ProfilUtilisateur.debiteur && _debiteurId != null)
        'debiteurId': _debiteurId,
    };
    try {
      await _repo.saveUtilisateur(body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte utilisateur créé.')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Nouvel utilisateur')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          final message = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Erreur de chargement des référentiels.';
          return Scaffold(
            appBar: AppBar(title: const Text('Nouvel utilisateur')),
            body: Center(child: Text(message, textAlign: TextAlign.center)),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Nouvel utilisateur')),
          body: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FormSection(
                  title: 'Identité',
                  icon: Icons.person_outline,
                  children: [
                    FormTextField(
                      label: 'Prénom',
                      controller: _prenom,
                      requiredField: true,
                    ),
                    FormTextField(
                      label: 'Nom',
                      controller: _nom,
                      requiredField: true,
                    ),
                    FormTextField(
                      label: 'Adresse e-mail professionnelle',
                      controller: _email,
                      requiredField: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    FormTextField(label: 'Téléphone', controller: _telephone),
                    FormTextField(label: 'Adresse', controller: _adresse),
                  ],
                ),
                FormSection(
                  title: 'Profil et périmètre',
                  icon: Icons.admin_panel_settings_outlined,
                  children: [
                    FormDropdown<ProfilUtilisateur>(
                      label: 'Profil SNR',
                      initialValue: _profil,
                      items: [
                        for (final profil in ProfilUtilisateur.values)
                          DropdownMenuItem<ProfilUtilisateur>(
                            value: profil,
                            child: Text(profil.libelle),
                          ),
                      ],
                      onChanged: (value) => setState(() => _profil = value ?? _profil),
                    ),
                    if (_profil == ProfilUtilisateur.agent) ...[
                      OutlinedButton.icon(
                        onPressed: _choisirPortefeuilles,
                        icon: const Icon(Icons.account_tree_outlined),
                        label: Text(
                          _portefeuillesSelectionnes.isEmpty
                              ? 'Choisir des portefeuilles'
                              : '${_portefeuillesSelectionnes.length} portefeuille(s) sélectionné(s)',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_profil == ProfilUtilisateur.mandant)
                      FormDropdown<String>(
                        label: 'Mandant',
                        initialValue: _mandantId,
                        items: _itemsMandants(),
                        onChanged: (value) => setState(() => _mandantId = value),
                      ),
                    if (_profil == ProfilUtilisateur.debiteur)
                      FormDropdown<String>(
                        label: 'Débiteur',
                        initialValue: _debiteurId,
                        items: _itemsDebiteurs(),
                        onChanged: (value) => setState(() => _debiteurId = value),
                      ),
                    SwitchListTile(
                      title: const Text('Compte actif'),
                      value: _actif,
                      onChanged: (value) => setState(() => _actif = value),
                    ),
                  ],
                ),
                if (_erreur != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _erreur!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                FormActionBar(
                  label: 'Créer l’utilisateur',
                  onSave: _enregistrer,
                  onCancel: () => Navigator.of(context).pop(false),
                  saving: _saving,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
