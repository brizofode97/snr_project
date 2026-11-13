enum StatutActe { enPreparation, enCircuitVisa, signe, notifie, clos }

extension StatutActeLabel on StatutActe {
  String get libelle {
    switch (this) {
      case StatutActe.enPreparation:
        return 'En préparation';
      case StatutActe.enCircuitVisa:
        return 'En circuit de visa';
      case StatutActe.signe:
        return 'Signé';
      case StatutActe.notifie:
        return 'Notifié';
      case StatutActe.clos:
        return 'Clos';
    }
  }
}

class EtapeVisa {
  final String fonction;
  final String acteur;
  final bool valide;

  const EtapeVisa({required this.fonction, required this.acteur, this.valide = false});
}

class ActeContentieux {
  final String id;
  final String type; // mise en demeure, contrainte, ATD, saisie, vente, opposition
  final String creanceId;
  final String debiteurNom;
  final StatutActe statut;
  final DateTime? dateSignature;
  final DateTime? dateNotification;
  final DateTime echeanceDelai;
  final List<EtapeVisa> circuitVisa;

  const ActeContentieux({
    required this.id,
    required this.type,
    required this.creanceId,
    required this.debiteurNom,
    required this.statut,
    this.dateSignature,
    this.dateNotification,
    required this.echeanceDelai,
    this.circuitVisa = const [],
  });
}
