import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/message_portail.dart';
import '../../widgets/empty_placeholder.dart';

const Map<String, String> _parametresMetier = <String, String>{
  'Délai de grâce': '15 jours',
  'Seuil d\'inactivité': '30 jours',
  'Fréquence des relances': 'Hebdomadaire',
  'Règle d\'imputation': 'Frais puis intérêts puis principal',
  'Pièces obligatoires': 'CNI / NINEA + justificatif de créance',
};

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});

  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  final _repo = SnrRepository.instance;
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.refreshAll();
  }

  List<JournalAuditEntry> _journal() {
    return _repo.audit.whereType<Map>().map((e) {
      final m = Map<String, dynamic>.from(e);
      return JournalAuditEntry(
        id: (m['numero'] ?? '').toString(),
        horodatage: DateTime.tryParse((m['ts'] ?? '').toString()) ?? DateTime.now(),
        acteur: (m['userId'] ?? '').toString(),
        action: (m['action'] ?? '').toString(),
        objet: (m['objet'] ?? '').toString(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Erreur de chargement de l\'administration.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(() => _future = _repo.refreshAll()),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.primary,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Paramètres métier'),
                    Tab(text: 'Journal d\'audit'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ParametresTab(controles: _repo.controles),
                    _JournalAuditTab(entrees: _journal()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ParametresTab extends StatelessWidget {
  final List<dynamic> controles;

  const _ParametresTab({required this.controles});

  @override
  Widget build(BuildContext context) {
    final parametres = _parametresMetier.entries.toList();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: parametres.length + controles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index < parametres.length) {
          final parametre = parametres[index];
          return Card(
            child: ListTile(
              title: Text(parametre.key),
              subtitle: Text(parametre.value),
              trailing: const Icon(Icons.edit_outlined),
            ),
          );
        }
        final c = controles[index - parametres.length];
        final map = c is Map ? Map<String, dynamic>.from(c) : <String, dynamic>{};
        final conforme = map['conforme'] == true;
        return Card(
          child: ListTile(
            leading: Icon(
              conforme ? Icons.check_circle_outline : Icons.error_outline,
              color: conforme ? Colors.green : Colors.orange,
            ),
            title: Text((map['libelle'] ?? '').toString()),
            subtitle: Text((map['detail'] ?? '').toString()),
          ),
        );
      },
    );
  }
}

class _JournalAuditTab extends StatelessWidget {
  final List<JournalAuditEntry> entrees;

  const _JournalAuditTab({required this.entrees});

  @override
  Widget build(BuildContext context) {
    if (entrees.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucune entrée dans le journal.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entrees.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final j = entrees[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text('${j.action} — ${j.objet}'),
            subtitle: Text('${j.acteur} · ${formatDateTime(j.horodatage)}'),
          ),
        );
      },
    );
  }
}
