enum StatutTransaction { justificatifDepose, enAttente, confirme, nonIdentifie, rejete }

extension StatutTransactionLabel on StatutTransaction {
  String get libelle {
    switch (this) {
      case StatutTransaction.justificatifDepose:
        return 'Justificatif déposé';
      case StatutTransaction.enAttente:
        return 'En attente';
      case StatutTransaction.confirme:
        return 'Confirmé';
      case StatutTransaction.nonIdentifie:
        return 'Non identifié';
      case StatutTransaction.rejete:
        return 'Rejeté';
    }
  }
}

StatutTransaction statutTransactionFromApi(String? v) {
  switch ((v ?? '').toLowerCase()) {
    case 'confirmé':
    case 'confirme':
      return StatutTransaction.confirme;
    case 'en attente de confirmation':
    case 'en attente':
      return StatutTransaction.enAttente;
    case 'non identifié':
    case 'non identifie':
      return StatutTransaction.nonIdentifie;
    case 'rejeté':
    case 'rejete':
      return StatutTransaction.rejete;
    default:
      return StatutTransaction.justificatifDepose;
  }
}

class Transaction {
  final String id;
  final String reference;
  final DateTime date;
  final String canal;
  final int montant;
  final String payeur;
  final String? creanceId;
  final StatutTransaction statut;
  final bool comptabilise;

  const Transaction({
    required this.id,
    required this.reference,
    required this.date,
    required this.canal,
    required this.montant,
    required this.payeur,
    this.creanceId,
    required this.statut,
    this.comptabilise = false,
  });

  factory Transaction.fromApi(Map<String, dynamic> m) => Transaction(
        id: (m['id'] ?? '').toString(),
        reference: (m['ref'] ?? m['reference'] ?? '').toString(),
        date: DateTime.tryParse((m['date'] ?? '').toString()) ?? DateTime.now(),
        canal: (m['canal'] ?? '').toString(),
        montant: (m['montant'] is num) ? (m['montant'] as num).toInt() : int.tryParse('${m['montant']}') ?? 0,
        payeur: (m['payeur'] ?? '').toString(),
        creanceId: m['creanceId']?.toString(),
        statut: statutTransactionFromApi(m['statut']?.toString()),
        comptabilise: m['comptabilise'] == true,
      );
}

enum StatutReversement { aPreparer, prepare, valide, paye }

extension StatutReversementLabel on StatutReversement {
  String get libelle {
    switch (this) {
      case StatutReversement.aPreparer:
        return 'À préparer';
      case StatutReversement.prepare:
        return 'Préparé';
      case StatutReversement.valide:
        return 'Validé';
      case StatutReversement.paye:
        return 'Payé';
    }
  }
}

class Reversement {
  final String id;
  final String mandant;
  final String mois;
  final int montant;
  final StatutReversement statut;

  const Reversement({
    required this.id,
    required this.mandant,
    required this.mois,
    required this.montant,
    required this.statut,
  });
}
