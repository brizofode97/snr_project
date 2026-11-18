import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/acte_contentieux.dart';
import '../../models/document_item.dart';
import '../../models/echeancier.dart';
import '../../models/message_portail.dart';
import '../../widgets/empty_placeholder.dart';

class ValidationsScreen extends StatefulWidget {
  const ValidationsScreen({super.key});

  @override
  State<ValidationsScreen> createState() => _ValidationsScreenState();
}

class _ValidationsScreenState extends State<ValidationsScreen> {
  final _repo = SnrRepository.instance;
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.refreshAll();
  }

  IconData _icone(String typeName) {
    switch (typeName) {
      case 'creance':
        return Icons.account_balance_wallet_outlined;
      case 'echeancier':
        return Icons.event_note_outlined;
      case 'ajustement':
        return Icons.tune_outlined;
      case 'fusion':
        return Icons.merge_outlined;
      case 'cloture':
        return Icons.task_alt_outlined;
      case 'attestation':
        return Icons.verified_outlined;
      default:
        return Icons.fact_check_outlined;
    }
  }

  String _reference(String creanceId) =>
      _repo.creanceParId(creanceId)?.reference ?? creanceId;

  List<ElementAValider> _elements() {
    final maintenant = DateTime.now();
    final elements = <ElementAValider>[];
    for (final e in _repo.echeanciers
        .where((e) => e.statut == StatutEcheancier.soumis)) {
      elements.add(ElementAValider(
        id: e.id,
        type: TypeValidation.echeancier,
        libelle: 'Échéancier ${_reference(e.creanceId)} — ${e.debiteurNom}',
        demandePar: e.debiteurNom,
        date: maintenant,
      ));
    }
    for (final a in _repo.attestations
        .where((a) => a.statut == StatutAttestation.demandee)) {
      elements.add(ElementAValider(
        id: a.id,
        type: TypeValidation.attestation,
        libelle: '${a.reference} — ${a.type} (${a.debiteurNom})',
        demandePar: a.debiteurNom,
        date: maintenant,
      ));
    }
    for (final a in _repo.actesContentieux
        .where((a) => a.statut == StatutActe.enCircuitVisa)) {
      elements.add(ElementAValider(
        id: a.id,
        type: TypeValidation.ajustement,
        libelle:
            'Visa ${a.type} — ${_reference(a.creanceId)} (${a.debiteurNom})',
        demandePar: a.debiteurNom,
        date: maintenant,
      ));
    }
    return elements;
  }

  Future<void> _decider(ElementAValider element, bool ok) async {
    try {
      switch (element.type) {
        case TypeValidation.echeancier:
          await _repo.decideEcheancier(element.id, ok);
          break;
        case TypeValidation.attestation:
          await _repo.decideAttestation(element.id, ok);
          break;
        case TypeValidation.ajustement:
          await _repo.decideActe(element.id, ok);
          break;
        default:
          return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Validation enregistrée.' : 'Rejet enregistré.')),
      );
      setState(() => _future = _repo.refreshAll());
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
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
              : 'Erreur de chargement des validations.';
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

        final validations = _elements();
        if (validations.isEmpty) {
          return const EmptyPlaceholder(
            message: 'Aucune opération en attente de validation.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: validations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final v = validations[index];
            return Card(
              child: ListTile(
                leading: Icon(_icone(v.type.name)),
                title: Text(v.libelle),
                subtitle: Text('Demandé par ${v.demandePar} · ${formatDate(v.date)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      onPressed: () => _decider(v, true),
                      tooltip: 'Valider',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                      onPressed: () => _decider(v, false),
                      tooltip: 'Rejeter',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
