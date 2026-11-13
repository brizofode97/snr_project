enum PhaseCreance {
  enregistrement,
  controle,
  validation,
  affectation,
  negociation,
  accord,
  contentieux,
  clotureDemandee,
  cloturee,
}

extension PhaseCreanceLabel on PhaseCreance {
  String get libelle {
    switch (this) {
      case PhaseCreance.enregistrement:
        return 'Enregistrement';
      case PhaseCreance.controle:
        return 'Contrôle';
      case PhaseCreance.validation:
        return 'Validation';
      case PhaseCreance.affectation:
        return 'Affectation';
      case PhaseCreance.negociation:
        return 'Négociation';
      case PhaseCreance.accord:
        return 'Accord';
      case PhaseCreance.contentieux:
        return 'Contentieux';
      case PhaseCreance.clotureDemandee:
        return 'Clôture demandée';
      case PhaseCreance.cloturee:
        return 'Clôturée';
    }
  }
}

enum SituationCreance { aucunPaiement, partielle, soldee }

extension SituationCreanceLabel on SituationCreance {
  String get libelle {
    switch (this) {
      case SituationCreance.aucunPaiement:
        return 'Aucun paiement';
      case SituationCreance.partielle:
        return 'Paiement partiel';
      case SituationCreance.soldee:
        return 'Soldée';
    }
  }
}

class EvenementCreance {
  final DateTime date;
  final String titre;
  final String description;
  final String auteur;

  const EvenementCreance({
    required this.date,
    required this.titre,
    required this.description,
    required this.auteur,
  });
}

class Creance {
  final String id;
  final String reference;
  final String debiteurId;
  final String mandant;
  final String portefeuille;
  final String nature;
  final DateTime dateCreance;
  final DateTime dateEcheance;
  final int principal;
  final int interets;
  final int frais;
  final PhaseCreance phase;
  final SituationCreance situation;
  final String? agentAffecte;
  final bool contestee;
  final String prochaineAction;
  final List<EvenementCreance> chronologie;
  final List<String> garanties;
  final List<String> documentIds;

  const Creance({
    required this.id,
    required this.reference,
    required this.debiteurId,
    required this.mandant,
    required this.portefeuille,
    required this.nature,
    required this.dateCreance,
    required this.dateEcheance,
    required this.principal,
    required this.interets,
    required this.frais,
    required this.phase,
    required this.situation,
    this.agentAffecte,
    this.contestee = false,
    required this.prochaineAction,
    this.chronologie = const [],
    this.garanties = const [],
    this.documentIds = const [],
  });

  int get montantTotal => principal + interets + frais;

  int get soldeRestant {
    switch (situation) {
      case SituationCreance.aucunPaiement:
        return montantTotal;
      case SituationCreance.partielle:
        return (montantTotal * 0.55).round();
      case SituationCreance.soldee:
        return 0;
    }
  }
}
