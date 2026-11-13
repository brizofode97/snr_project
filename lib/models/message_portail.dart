class MessagePortail {
  final String id;
  final String auteur;
  final String contenu;
  final DateTime date;
  final bool deMoi;

  const MessagePortail({
    required this.id,
    required this.auteur,
    required this.contenu,
    required this.date,
    this.deMoi = false,
  });
}

class RapportPredefini {
  final String id;
  final String titre;
  final String description;
  final String icone;

  const RapportPredefini({
    required this.id,
    required this.titre,
    required this.description,
    this.icone = 'description',
  });
}

enum TypeValidation { creance, echeancier, ajustement, fusion, cloture, attestation }

class ElementAValider {
  final String id;
  final TypeValidation type;
  final String libelle;
  final String demandePar;
  final DateTime date;

  const ElementAValider({
    required this.id,
    required this.type,
    required this.libelle,
    required this.demandePar,
    required this.date,
  });
}

class JournalAuditEntry {
  final String id;
  final DateTime horodatage;
  final String acteur;
  final String action;
  final String objet;

  const JournalAuditEntry({
    required this.id,
    required this.horodatage,
    required this.acteur,
    required this.action,
    required this.objet,
  });
}
