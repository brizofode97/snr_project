import 'package:material_ui/material_ui.dart';

import '../../widgets/form_widgets.dart';

enum TypeChamp { texte, zoneTexte, nombre, date, liste }

class ChampFormulaire {
  final String cle;
  final String label;
  final TypeChamp type;
  final bool obligatoire;
  final List<String> options;
  final String? valeurInitiale;

  const ChampFormulaire(
    this.cle,
    this.label,
    this.type, {
    this.obligatoire = false,
    this.options = const <String>[],
    this.valeurInitiale,
  });
}

class TraitementFormDialog extends StatefulWidget {
  final String title;
  final String? description;
  final List<ChampFormulaire> champs;
  final Future<void> Function(Map<String, String> values) onSoumettre;
  final String labelBouton;

  const TraitementFormDialog({
    super.key,
    required this.title,
    this.description,
    required this.champs,
    required this.onSoumettre,
    this.labelBouton = 'Confirmer',
  });

  @override
  State<TraitementFormDialog> createState() => _TraitementFormDialogState();
}

class _TraitementFormDialogState extends State<TraitementFormDialog> {
  final _form = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  final _values = <String, String>{};
  bool _saving = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    for (final champ in widget.champs) {
      if (champ.type == TypeChamp.liste) {
        _values[champ.cle] = champ.valeurInitiale ?? champ.options.firstOrNull ?? '';
      } else {
        _controllers[champ.cle] = TextEditingController(
          text: champ.valeurInitiale ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!_form.currentState!.validate()) return;
    final values = <String, String>{
      for (final entry in _controllers.entries) entry.key: entry.value.text.trim(),
      ..._values,
    };
    setState(() {
      _saving = true;
      _erreur = null;
    });
    try {
      await widget.onSoumettre(values);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _erreur = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.description != null) ...[
                  Text(widget.description!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 12),
                ],
                for (final champ in widget.champs) _buildChamp(champ),
                if (_erreur != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_erreur!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _soumettre,
          child: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.labelBouton),
        ),
      ],
    );
  }

  Widget _buildChamp(ChampFormulaire champ) {
    final obligatoire = champ.obligatoire;
    switch (champ.type) {
      case TypeChamp.date:
        return FormDateField(
          label: champ.label,
          requiredField: obligatoire,
          date: DateFormatLike.tryParse(_controllers[champ.cle]?.text),
          onChanged: (date) => _controllers[champ.cle]!.text =
              date.toIso8601String().substring(0, 10),
        );
      case TypeChamp.liste:
        return FormDropdown<String>(
          label: champ.label,
          initialValue: _values[champ.cle],
          items: [
            for (final option in champ.options)
              DropdownMenuItem<String>(value: option, child: Text(option)),
          ],
          onChanged: (value) => setState(() => _values[champ.cle] = value ?? ''),
          validator: obligatoire
              ? (value) => (value == null || value.isEmpty)
                  ? '${champ.label} est obligatoire'
                  : null
              : null,
        );
      case TypeChamp.zoneTexte:
        return FormTextField(
          label: champ.label,
          controller: _controllers[champ.cle]!,
          requiredField: obligatoire,
          maxLines: 4,
        );
      case TypeChamp.nombre:
        return FormTextField(
          label: champ.label,
          controller: _controllers[champ.cle]!,
          requiredField: obligatoire,
          keyboardType: TextInputType.number,
        );
      case TypeChamp.texte:
        return FormTextField(
          label: champ.label,
          controller: _controllers[champ.cle]!,
          requiredField: obligatoire,
        );
    }
  }
}

class DateFormatLike {
  static DateTime? tryParse(String? value) => DateTime.tryParse(value ?? '');
}

Future<bool?> showTraitementDialog({
  required BuildContext context,
  required String title,
  String? description,
  required List<ChampFormulaire> champs,
  required Future<void> Function(Map<String, String> values) onSoumettre,
  String labelBouton = 'Confirmer',
}) =>
    showDialog<bool>(
      context: context,
      builder: (context) => TraitementFormDialog(
        title: title,
        description: description,
        champs: champs,
        onSoumettre: onSoumettre,
        labelBouton: labelBouton,
      ),
    );
