import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/transaction.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final _repo = SnrRepository.instance;
  late Future<Transaction?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Transaction?> _load() async {
    await _repo.refreshAll();
    for (final t in _repo.transactions) {
      if (t.id == widget.transactionId) return t;
    }
    return null;
  }

  Future<void> _confirmer(String reference) async {
    try {
      await _repo.confirmTransaction(widget.transactionId, reference);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction confirmée.')),
      );
      setState(() => _future = _load());
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Transaction?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(title: const Text('Transaction')), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Erreur de chargement.';
          return Scaffold(
            appBar: AppBar(title: const Text('Transaction')),
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
        final t = snapshot.data;
        if (t == null) {
          return Scaffold(appBar: AppBar(title: const Text('Transaction')), body: const EmptyPlaceholder(message: 'Transaction introuvable.'));
        }
        final creance = t.creanceId != null ? _repo.creanceParId(t.creanceId!) : null;

        return Scaffold(
          appBar: AppBar(title: Text(t.reference)),
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
                          Text(formatFcfa(t.montant), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          StatusBadge(label: t.statut.libelle, color: Colors.blueGrey),
                        ],
                      ),
                      const Divider(height: 24),
                      _Ligne('Payeur', t.payeur),
                      _Ligne('Canal', t.canal),
                      _Ligne('Date', formatDate(t.date)),
                      _Ligne('Créance liée', creance?.reference ?? 'Non affectée'),
                      _Ligne('Comptabilisé', t.comptabilise ? 'Oui' : 'Non'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmer(t.reference),
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmer'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call_split),
                      label: const Text('Affecter'),
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

class _Ligne extends StatelessWidget {
  final String label;
  final String value;

  const _Ligne(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
