import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../data/mock_data.dart';
import '../../widgets/empty_placeholder.dart';

class DocumentDetailScreen extends StatelessWidget {
  final String documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final d = MockData.documentParId(documentId);
    if (d == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Document')),
        body: const EmptyPlaceholder(message: 'Document introuvable.'),
      );
    }
    final creance = d.creanceId != null ? MockData.creanceParId(d.creanceId!) : null;

    return Scaffold(
      appBar: AppBar(title: Text(d.titre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description_outlined, size: 36, color: Colors.indigo),
                  const SizedBox(height: 10),
                  Text('Type : ${d.type}'),
                  Text('Niveau d\'accès : ${d.niveauAcces}'),
                  Text('Version courante : ${d.versionCourante}'),
                  Text('Déposé le : ${formatDate(d.dateDepot)}'),
                  if (creance != null) Text('Créance liée : ${creance.reference}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Déposer une nouvelle version'),
          ),
        ],
      ),
    );
  }
}
