enum PhaseCreance {
  enregistrement,
  controle,
  validation,
  affectation,
  priseDeContact,
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
      case PhaseCreance.priseDeContact:
        return 'Prise de contact';
      case PhaseCreance.negociation:
        return 'Négociation';
      case PhaseCreance.accord:
        return 'Accord en vigueur';
      case PhaseCreance.contentieux:
        return 'Contentieux';
      case PhaseCreance.clotureDemandee:
        return 'Clôture demandée';
      case PhaseCreance.cloturee:
        return 'Clôturée';
    }
  }
}

PhaseCreance phaseFromApi(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'enregistrement':
      return PhaseCreance.enregistrement;
    case 'contrôle':
    case 'controle':
      return PhaseCreance.controle;
    case 'validation':
      return PhaseCreance.validation;
    case 'affectation':
      return PhaseCreance.affectation;
    case 'prise de contact':
      return PhaseCreance.priseDeContact;
    case 'négociation':
    case 'negociation':
      return PhaseCreance.negociation;
    case 'accord en vigueur':
    case 'accord':
      return PhaseCreance.accord;
    case 'contentieux':
      return PhaseCreance.contentieux;
    case 'clôture demandée':
    case 'cloture demandee':
    case 'clôture demand�e':
      return PhaseCreance.clotureDemandee;
    case 'clôturée':
    case 'cloturee':
    case 'cl�tur�e':
      return PhaseCreance.cloturee;
    default:
      return PhaseCreance.enregistrement;
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

SituationCreance situationFromApi(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'paiement partiel':
    case 'partielle':
      return SituationCreance.partielle;
    case 'soldée':
    case 'soldee':
      return SituationCreance.soldee;
    default:
      return SituationCreance.aucunPaiement;
  }
}

DateTime _parseDate(dynamic v) {
  if (v == null) return DateTime.now();
  final s = v.toString();
  return DateTime.tryParse(s) ?? DateTime.now();
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
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

  factory EvenementCreance.fromApi(Map<String, dynamic> m) => EvenementCreance(
        date: _parseDate(m['date'] ?? m['ts']),
        titre: (m['label'] ?? m['titre'] ?? m['type'] ?? '').toString(),
        description: (m['detail'] ?? m['description'] ?? '').toString(),
        auteur: (m['userId'] ?? m['auteur'] ?? '').toString(),
      );
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

  factory Creance.fromApi(Map<String, dynamic> m) {
    final contestation = m['contestation'];
    final contestee = contestation is Map
        ? (contestation['statut']?.toString() == 'En cours')
        : (m['contestee'] == true);
    final next = m['nextAction'];
    final prochaine = next is Map
        ? (next['label']?.toString() ?? '')
        : (m['prochaineAction']?.toString() ?? '');
    final chrono = (m['chronologie'] as List? ?? [])
        .whereType<Map>()
        .map((e) => EvenementCreance.fromApi(Map<String, dynamic>.from(e)))
        .toList();
    final garanties = (m['garanties'] as List? ?? []).map((e) => e.toString()).toList();
    return Creance(
      id: (m['id'] ?? '').toString(),
      reference: (m['ref'] ?? m['reference'] ?? m['id'] ?? '').toString(),
      debiteurId: (m['debiteurId'] ?? '').toString(),
      mandant: (m['mandantId'] ?? m['mandant'] ?? '').toString(),
      portefeuille: (m['portefeuille'] ?? '').toString(),
      nature: (m['nature'] ?? '').toString(),
      dateCreance: _parseDate(m['dateCreance'] ?? m['createdAt']),
      dateEcheance: _parseDate(m['echeance'] ?? m['dateEcheance']),
      principal: _asInt(m['principal']),
      interets: _asInt(m['interets']),
      frais: _asInt(m['frais']),
      phase: phaseFromApi(m['phase']?.toString()),
      situation: situationFromApi(m['etat']?.toString() ?? m['situation']?.toString()),
      agentAffecte: m['agentId']?.toString(),
      contestee: contestee,
      prochaineAction: prochaine,
      chronologie: chrono,
      garanties: garanties,
      documentIds: (m['documentIds'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }

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
