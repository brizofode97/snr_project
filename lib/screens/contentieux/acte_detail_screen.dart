import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/acte_contentieux.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class ActeDetailScreen extends StatefulWidget {
  final String acteId;

  const ActeDetailScreen({super.key, required this.acteId});

  @override
  State<ActeDetailScreen> createState() => _ActeDetailScreenState();
}

class _ActeDetailScreenState extends State<ActeDetailScreen> {
  final _repo = SnrRepository.instance;
  late Future<ActeContentieux?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ActeContentieux?> _load() async {
    if (_repo.actesContentieux.isEmpty) await _repo.refreshAll();
    final index = _repo.actesContentieux.indexWhere((a) => a.id == widget.acteId);
    if (index < 0) return null;
    return _repo.fetchActe(widget.acteId);
  }

  Future<void> _decider(bool vise) async {
    try {
      await _repo.decideActe(widget.acteId, vise);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vise ? 'Acte visé.' : 'Acte rejeté.')),
      );
      setState(() => _future = _load());
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActeContentieux?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(title: const Text('Acte contentieux')), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Erreur de chargement.';
          return Scaffold(
            appBar: AppBar(title: const Text('Acte contentieux')),
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
        final acte = snapshot.data;
        if (acte == null) {
          return Scaffold(appBar: AppBar(title: const Text('Acte contentieux')), body: const EmptyPlaceholder(message: 'Acte introuvable.'));
        }
        return Scaffold(
          appBar: AppBar(title: Text(acte.type)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(acte.debiteurNom, style: const TextStyle(fontWeight: FontWeight.bold)),
                          StatusBadge(label: acte.statut.libelle, color: Colors.blueGrey),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Échéance du délai : ${formatDate(acte.echeanceDelai)}'),
                      if (acte.dateSignature != null) Text('Signé le : ${formatDate(acte.dateSignature!)}'),
                      if (acte.dateNotification != null) Text('Notifié le : ${formatDate(acte.dateNotification!)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Circuit de visa', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (acte.circuitVisa.isEmpty)
                const EmptyPlaceholder(message: 'Aucun circuit de visa défini.')
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (final etape in acte.circuitVisa)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  etape.valide ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: etape.valide ? Colors.green : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(etape.fonction, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(etape.acteur, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (acte.statut == StatutActe.enCircuitVisa) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _decider(true),
                        icon: const Icon(Icons.check),
                        label: const Text('Viser'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _decider(false),
                        icon: const Icon(Icons.close),
                        label: const Text('Rejeter'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
