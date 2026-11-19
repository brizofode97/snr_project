import 'package:material_ui/material_ui.dart';

List<T> pageItems<T>(List<T> items, int page, int pageSize) {
  final start = page * pageSize;
  if (start >= items.length) return <T>[];
  final end = (start + pageSize).clamp(0, items.length);
  return items.sublist(start, end);
}

class PaginationBar extends StatelessWidget {
  final int page;
  final int pageSize;
  final int total;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;
  final String itemLabel;
  final List<int> pageSizeOptions;

  const PaginationBar({
    super.key,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    required this.itemLabel,
    this.pageSizeOptions = const <int>[10, 20, 30],
  });

  @override
  Widget build(BuildContext context) {
    final pages = total == 0 ? 1 : (total / pageSize).ceil();
    final first = total == 0 ? 0 : page * pageSize + 1;
    final last = ((page + 1) * pageSize).clamp(0, total);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$first–$last sur $total $itemLabel',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: pageSize,
              isDense: true,
              items: [
                for (final option in pageSizeOptions)
                  DropdownMenuItem<int>(value: option, child: Text('$option')),
              ],
              onChanged: (value) {
                if (value != null) onPageSizeChanged(value);
              },
            ),
          ),
          IconButton(
            tooltip: 'Page précédente',
            icon: const Icon(Icons.chevron_left),
            onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
          ),
          IconButton(
            tooltip: 'Page suivante',
            icon: const Icon(Icons.chevron_right),
            onPressed: page + 1 < pages ? () => onPageChanged(page + 1) : null,
          ),
        ],
      ),
    );
  }
}
