import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/echeancier.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class EcheancierDetailScreen extends StatefulWidget {
  final String echeancierId;

  const EcheancierDetailScreen({super.key, required this.echeancierId});

  @override
  State<EcheancierDetailScreen> createState() => _EcheancierDetailScreenState();
}

class _EcheancierDetailScreenState extends State<EcheancierDetailScreen> {
  final _repo = SnrRepository.instance;
  late Future<Echeancier?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Echeancier?> _load() async {
    if (_repo.echeanciers.isEmpty) await _repo.refreshAll();
    if (_repo.echeancierParId(widget.echeancierId) == null) return null;
    return _repo.fetchEcheancier(widget.echeancierId);
  }

  Future<void> _decider(bool ok) async {
    try {
      await _repo.decideEcheancier(widget.echeancierId, ok);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Échéancier validé.' : 'Échéancier rejeté.')),
      );
      setState(() => _future = _load());
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Echeancier?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(title: const Text('Échéancier')), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Erreur de chargement.';
          return Scaffold(
            appBar: AppBar(title: const Text('Échéancier')),
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
        final e = snapshot.data;
        if (e == null) {
          return Scaffold(appBar: AppBar(title: const Text('Échéancier')), body: const EmptyPlaceholder(message: 'Échéancier introuvable.'));
        }
        return Scaffold(
          appBar: AppBar(title: Text('Échéancier — ${e.debiteurNom}')),
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
                          Text('Version ${e.version}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          StatusBadge(label: e.statut.libelle, color: Colors.blueGrey),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Montant total : ${formatFcfa(e.montantTotal)}'),
                      Text('Acompte : ${formatFcfa(e.acompte)}'),
                      Text('${e.nombreEcheances} échéances — ${e.frequence}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Détail des échéances', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              for (final ligne in e.echeances)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ligne.payee ? Colors.green.shade100 : Colors.grey.shade200,
                      child: Icon(
                        ligne.payee ? Icons.check : Icons.schedule,
                        color: ligne.payee ? Colors.green : Colors.grey.shade600,
                        size: 18,
                      ),
                    ),
                    title: Text('Échéance ${ligne.numero} — ${formatFcfa(ligne.montant)}'),
                    subtitle: Text('Avant le ${formatDate(ligne.dateLimite)}'),
                  ),
                ),
              if (e.statut == StatutEcheancier.soumis) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _decider(true),
                        icon: const Icon(Icons.check),
                        label: const Text('Valider'),
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
