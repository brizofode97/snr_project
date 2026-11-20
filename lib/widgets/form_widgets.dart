import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class FormSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;

  const FormSection({
    super.key,
    required this.title,
    this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class FormTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool requiredField;
  final int maxLines;
  final TextInputType keyboardType;
  final String? hint;

  const FormTextField({
    super.key,
    required this.label,
    required this.controller,
    this.requiredField = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: requiredField
            ? (value) => (value == null || value.trim().isEmpty) ? '$label est obligatoire' : null
            : null,
        decoration: InputDecoration(
          labelText: requiredField ? '$label *' : label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class FormNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool requiredField;
  final String suffix;

  const FormNumberField({
    super.key,
    required this.label,
    required this.controller,
    this.requiredField = false,
    this.suffix = 'FCFA',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (requiredField && (value == null || value.trim().isEmpty)) {
            return '$label est obligatoire';
          }
          if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
            return 'Montant invalide';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: requiredField ? '$label *' : label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class FormDropdown<T> extends StatelessWidget {
  final String label;
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T? value)? validator;

  const FormDropdown({
    super.key,
    required this.label,
    required this.initialValue,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        initialValue: initialValue,
        items: items,
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class FormDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onChanged;
  final bool requiredField;

  const FormDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onChanged,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: requiredField ? '$label *' : label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? now,
              firstDate: DateTime(now.year - 15),
              lastDate: DateTime(now.year + 10),
            );
            if (picked != null) onChanged(picked);
          },
          child: Row(
            children: [
              Expanded(child: Text(date == null ? 'Choisir une date' : date!.toIso8601String().substring(0, 10))),
              const Icon(Icons.calendar_today, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class FormActionBar extends StatelessWidget {
  final String label;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final bool saving;

  const FormActionBar({
    super.key,
    this.label = 'Enregistrer',
    required this.onSave,
    this.onCancel,
    this.saving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Row(
        children: [
          if (onCancel != null)
            Expanded(
              child: OutlinedButton(
                onPressed: saving ? null : onCancel,
                child: const Text('Annuler'),
              ),
            ),
          if (onCancel != null) const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: saving ? null : onSave,
              child: saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(label),
            ),
          ),
        ],
      ),
    );
  }
}

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
