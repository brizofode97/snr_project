enum StatutEcheancier { soumis, valide, rejete, remplace }

extension StatutEcheancierLabel on StatutEcheancier {
  String get libelle {
    switch (this) {
      case StatutEcheancier.soumis:
        return 'Soumis';
      case StatutEcheancier.valide:
        return 'Validé';
      case StatutEcheancier.rejete:
        return 'Rejeté';
      case StatutEcheancier.remplace:
        return 'Remplacé';
    }
  }
}

class EcheanceLigne {
  final int numero;
  final DateTime dateLimite;
  final int montant;
  final bool payee;

  const EcheanceLigne({
    required this.numero,
    required this.dateLimite,
    required this.montant,
    this.payee = false,
  });
}

class Echeancier {
  final String id;
  final String creanceId;
  final String debiteurNom;
  final int version;
  final int montantTotal;
  final int acompte;
  final int nombreEcheances;
  final String frequence;
  final StatutEcheancier statut;
  final List<EcheanceLigne> echeances;

  const Echeancier({
    required this.id,
    required this.creanceId,
    required this.debiteurNom,
    required this.version,
    required this.montantTotal,
    required this.acompte,
    required this.nombreEcheances,
    required this.frequence,
    required this.statut,
    this.echeances = const [],
  });
}
