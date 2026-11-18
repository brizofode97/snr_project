enum StatutTache { aFaire, faite }

class Tache {
  final String id;
  final String libelle;
  final String type;
  final DateTime date;
  final String assigneA;
  final StatutTache statut;
  final bool enRetard;

  const Tache({
    required this.id,
    required this.libelle,
    required this.type,
    required this.date,
    required this.assigneA,
    this.statut = StatutTache.aFaire,
    this.enRetard = false,
  });

  factory Tache.fromApi(Map<String, dynamic> m) {
    final date = DateTime.tryParse((m['date'] ?? '').toString()) ?? DateTime.now();
    final statut = (m['statut'] ?? '').toString().toLowerCase() == 'faite'
        ? StatutTache.faite
        : StatutTache.aFaire;
    return Tache(
      id: (m['id'] ?? m['key'] ?? '').toString(),
      libelle: (m['label'] ?? m['libelle'] ?? '').toString(),
      type: (m['type'] ?? '').toString(),
      date: date,
      assigneA: (m['assigneeId'] ?? m['assigneA'] ?? '').toString(),
      statut: statut,
      enRetard: statut == StatutTache.aFaire && date.isBefore(DateTime.now()),
    );
  }
}

enum StatutPromesse { enAttente, tenue, nonTenue }

extension StatutPromesseLabel on StatutPromesse {
  String get libelle {
    switch (this) {
      case StatutPromesse.enAttente:
        return 'En attente';
      case StatutPromesse.tenue:
        return 'Tenue';
      case StatutPromesse.nonTenue:
        return 'Non tenue';
    }
  }
}

class Promesse {
  final String id;
  final String debiteurNom;
  final int montant;
  final DateTime date;
  final StatutPromesse statut;
  final String? creanceId;

  const Promesse({
    required this.id,
    required this.debiteurNom,
    required this.montant,
    required this.date,
    required this.statut,
    this.creanceId,
  });

  factory Promesse.fromApi(Map<String, dynamic> m) => Promesse(
        id: (m['id'] ?? '').toString(),
        debiteurNom: (m['debiteurNom'] ?? '').toString(),
        montant: (m['montant'] is num) ? (m['montant'] as num).toInt() : 0,
        date: DateTime.tryParse((m['date'] ?? '').toString()) ?? DateTime.now(),
        statut: _statutFromApi(m['statut']?.toString()),
        creanceId: m['creanceId']?.toString(),
      );

  static StatutPromesse _statutFromApi(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'tenue':
        return StatutPromesse.tenue;
      case 'non tenue':
      case 'non-tenue':
        return StatutPromesse.nonTenue;
      default:
        return StatutPromesse.enAttente;
    }
  }
}
