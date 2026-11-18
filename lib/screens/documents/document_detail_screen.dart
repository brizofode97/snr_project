import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/document_item.dart';
import '../../widgets/empty_placeholder.dart';

class DocumentDetailScreen extends StatefulWidget {
  final String documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  final _repo = SnrRepository.instance;
  late Future<DocumentItem?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DocumentItem?> _load() async {
    await _repo.refreshAll();
    for (final d in _repo.documents) {
      if (d.id == widget.documentId) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentItem?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(title: const Text('Document')), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Erreur de chargement.';
          return Scaffold(
            appBar: AppBar(title: const Text('Document')),
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
        final d = snapshot.data;
        if (d == null) {
          return Scaffold(appBar: AppBar(title: const Text('Document')), body: const EmptyPlaceholder(message: 'Document introuvable.'));
        }
        final creance = d.creanceId != null ? _repo.creanceParId(d.creanceId!) : null;

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
      },
    );
  }
}
