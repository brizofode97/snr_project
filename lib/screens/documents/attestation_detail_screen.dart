import 'package:material_ui/material_ui.dart';

import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/document_item.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class AttestationDetailScreen extends StatefulWidget {
  final String attestationId;

  const AttestationDetailScreen({super.key, required this.attestationId});

  @override
  State<AttestationDetailScreen> createState() => _AttestationDetailScreenState();
}

class _AttestationDetailScreenState extends State<AttestationDetailScreen> {
  final _repo = SnrRepository.instance;
  late Future<Attestation?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Attestation?> _load() async {
    await _repo.refreshAll();
    for (final a in _repo.attestations) {
      if (a.id == widget.attestationId) return a;
    }
    return null;
  }

  Future<void> _decider(bool ok) async {
    try {
      await _repo.decideAttestation(widget.attestationId, ok);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Attestation délivrée.' : 'Attestation refusée.')),
      );
      setState(() => _future = _load());
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Attestation?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(title: const Text('Attestation')), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Erreur de chargement.';
          return Scaffold(
            appBar: AppBar(title: const Text('Attestation')),
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
        final a = snapshot.data;
        if (a == null) {
          return Scaffold(appBar: AppBar(title: const Text('Attestation')), body: const EmptyPlaceholder(message: 'Attestation introuvable.'));
        }
        return Scaffold(
          appBar: AppBar(title: Text(a.reference)),
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
                          Text(a.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                          StatusBadge(label: a.statut.libelle, color: Colors.blueGrey),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Débiteur : ${a.debiteurNom}'),
                      Text('Code de vérification : ${a.codeVerification}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _decider(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Délivrer'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _decider(false),
                      icon: const Icon(Icons.close),
                      label: const Text('Refuser'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
