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
