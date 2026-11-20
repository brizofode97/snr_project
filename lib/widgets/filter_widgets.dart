import 'package:material_ui/material_ui.dart';

class FilterSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final EdgeInsetsGeometry padding;

  const FilterSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
      ),
    );
  }
}

class FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double width;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isDense: true,
            isExpanded: true,
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class FilterChips<T> extends StatelessWidget {
  final List<T> values;
  final T? selected;
  final String Function(T value) label;
  final ValueChanged<T?> onChanged;
  final String allLabel;

  const FilterChips({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.allLabel = 'Tous',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(allLabel),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          for (final value in values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label(value)),
                selected: selected == value,
                onSelected: (_) => onChanged(value),
              ),
            ),
        ],
      ),
    );
  }
}

class FilterPanel extends StatelessWidget {
  final bool show;
  final VoidCallback onToggle;
  final VoidCallback? onReset;
  final List<Widget> children;

  const FilterPanel({
    super.key,
    required this.show,
    required this.onToggle,
    this.onReset,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: onToggle,
              icon: Icon(show ? Icons.filter_list_off : Icons.filter_list),
              label: Text(show ? 'Masquer les filtres' : 'Afficher les filtres'),
            ),
            const Spacer(),
            if (onReset != null)
              TextButton(onPressed: onReset, child: const Text('Réinitialiser')),
            const SizedBox(width: 8),
          ],
        ),
        if (show)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: children,
            ),
          ),
      ],
    );
  }
}

String normalizeText(String value) {
  var text = value.toLowerCase();
  const replacements = <String, String>{
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i',
    'ô': 'o', 'ö': 'o', 'ó': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
    'ç': 'c', 'œ': 'oe', 'æ': 'ae',
  };
  replacements.forEach((key, replacement) {
    text = text.replaceAll(key, replacement);
  });
  return text.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
