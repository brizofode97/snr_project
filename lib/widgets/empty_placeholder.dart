import 'package:material_ui/material_ui.dart';

class EmptyPlaceholder extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyPlaceholder({
    super.key,
    this.message = 'Aucun élément trouvé.',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
