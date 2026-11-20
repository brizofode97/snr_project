import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../widgets/form_widgets.dart';

const List<String> naturesCreance = <String>[
  'Prêt à la consommation',
  'Prêt immobilier',
  'Loyer',
  'Fourniture',
  'Prestation de services',
  'Autre',
];

const List<String> originesCreance = <String>[
  'Mandant',
  'SNR',
  'Import portefeuille',
  'Déclaration débiteur',
];

class CreanceFormScreen extends StatefulWidget {
  final String? creanceId;

  const CreanceFormScreen({super.key, this.creanceId});

  bool get estModification => creanceId != null && creanceId!.isNotEmpty;

  @override
  State<CreanceFormScreen> createState() => _CreanceFormScreenState();
}

class _CreanceFormScreenState extends State<CreanceFormScreen> {
  final _form = GlobalKey<FormState>();
  final _repo = SnrRepository.instance;
  final _refMandant = TextEditingController();
  final _principal = TextEditingController();
  final _interets = TextEditingController();
  final _frais = TextEditingController();

  late Future<void> _future;
  String? _debiteurId;
  String? _mandantId;
  String? _nature;
  String? _origineChoisie = originesCreance.first;
  DateTime? _dateCreance;
  DateTime? _echeance;
  bool _saving = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _future = _charger();
  }

  @override
  void dispose() {
    _refMandant.dispose();
    _principal.dispose();
    _interets.dispose();
    _frais.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    if (_repo.debiteurs.isEmpty || _repo.mandants.isEmpty) {
      await _repo.refreshAll();
    }
    if (!widget.estModification) return;
    final creance = _repo.creanceParId(widget.creanceId!) ??
        await _repo.fetchCreance(widget.creanceId!);
    _debiteurId = creance.debiteurId;
    _mandantId = creance.mandant;
    _nature = naturesCreance.contains(creance.nature) ? creance.nature : creance.nature;
    if (_nature!.isEmpty) _nature = null;
    _dateCreance = creance.dateCreance;
    _echeance = creance.dateEcheance;
    _principal.text = creance.principal.toString();
    _interets.text = creance.interets.toString();
    _frais.text = creance.frais.toString();
  }

  String _dateApi(DateTime? date) =>
      date == null ? '' : date.toIso8601String().substring(0, 10);

  Future<void> _enregistrer() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _erreur = null;
    });
    final body = <String, dynamic>{
      'nature': _nature ?? '',
      'origine': _origineChoisie ?? '',
      'refMandant':
          _refMandant.text.trim().isEmpty ? null : _refMandant.text.trim(),
      'dateCreance': _dateApi(_dateCreance),
      'echeance': _dateApi(_echeance),
      'principal': int.tryParse(_principal.text) ?? 0,
      'interets': int.tryParse(_interets.text) ?? 0,
      'frais': int.tryParse(_frais.text) ?? 0,
    };
    if (!widget.estModification) {
      body['debiteurId'] = _debiteurId;
      body['mandantId'] = _mandantId;
    }
    try {
      final result = widget.estModification
          ? await _repo.corrigerCreance(widget.creanceId!, body)
          : await _repo.creerCreance(body);
      if (!mounted) return;
      setState(() => _saving = false);
      final id = (result['creance'] is Map
              ? (result['creance'] as Map)['id']
              : result['id'])
          ?.toString();
      context.go(id != null && id.isNotEmpty ? '/creances/$id' : '/creances');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.estModification
                ? 'Créance mise à jour avec succès.'
                : 'Créance créée avec succès.',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _erreur = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.estModification ? 'Modifier la créance' : 'Nouvelle créance'),
      ),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : 'Erreur de chargement des référentiels.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => setState(() => _future = _charger()),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              children: [
                FormSection(
                  title: 'Identification du dossier',
                  icon: Icons.assignment_outlined,
                  children: [
                    FormDropdown<String>(
                      label: 'Débiteur',
                      initialValue: _debiteurId,
                      items: [
                        for (final debiteur in _repo.debiteurs)
                          DropdownMenuItem<String>(
                            value: debiteur.id,
                            child: Text(debiteur.nom),
                          ),
                      ],
                      onChanged: widget.estModification
                          ? (_) {}
                          : (value) => setState(() => _debiteurId = value),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Sélectionnez un débiteur'
                          : null,
                    ),
                    FormDropdown<String>(
                      label: 'Mandant',
                      initialValue: _mandantId,
                      items: [
                        for (final mandant in _repo.mandants)
                          if (mandant is Map)
                            DropdownMenuItem<String>(
                              value: (mandant['id'] ?? '').toString(),
                              child: Text(
                                '${mandant['sigle'] ?? ''} — ${mandant['nom'] ?? ''}',
                              ),
                            ),
                      ],
                      onChanged: widget.estModification
                          ? (_) {}
                          : (value) => setState(() => _mandantId = value),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Sélectionnez un mandant'
                          : null,
                    ),
                    FormTextField(
                      label: 'Référence mandant',
                      controller: _refMandant,
                      hint: 'Référence du dossier chez le mandant',
                    ),
                    FormDropdown<String>(
                      label: 'Nature de la créance',
                      initialValue: _nature,
                      items: [
                        for (final nature in {...naturesCreance, ?_nature})
                          DropdownMenuItem<String>(value: nature, child: Text(nature)),
                      ],
                      onChanged: (value) => setState(() => _nature = value),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Choisissez une nature'
                          : null,
                    ),
                    FormDropdown<String>(
                      label: 'Origine',
                      initialValue: _origineChoisie,
                      items: [
                        for (final origine in originesCreance)
                          DropdownMenuItem<String>(value: origine, child: Text(origine)),
                      ],
                      onChanged: (value) => setState(() => _origineChoisie = value),
                    ),
                  ],
                ),
                FormSection(
                  title: 'Dates',
                  icon: Icons.calendar_month_outlined,
                  children: [
                    FormDateField(
                      label: 'Date de la créance',
                      date: _dateCreance,
                      requiredField: true,
                      onChanged: (date) => setState(() => _dateCreance = date),
                    ),
                    FormDateField(
                      label: 'Date d’échéance',
                      date: _echeance,
                      requiredField: true,
                      onChanged: (date) => setState(() => _echeance = date),
                    ),
                  ],
                ),
                FormSection(
                  title: 'Montants (FCFA)',
                  icon: Icons.money_outlined,
                  children: [
                    FormNumberField(
                      label: 'Principal',
                      controller: _principal,
                      requiredField: true,
                    ),
                    FormNumberField(label: 'Intérêts', controller: _interets),
                    FormNumberField(label: 'Frais', controller: _frais),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Les montants sont exprimés en francs CFA entiers.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                if (_erreur != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_erreur!, style: const TextStyle(color: Colors.red)),
                  ),
                FormActionBar(
                  label: widget.estModification
                      ? 'Enregistrer les modifications'
                      : 'Créer la créance',
                  saving: _saving,
                  onCancel: () => context.pop(),
                  onSave: _enregistrer,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
