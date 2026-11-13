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

  const Promesse({
    required this.id,
    required this.debiteurNom,
    required this.montant,
    required this.date,
    required this.statut,
  });
}
