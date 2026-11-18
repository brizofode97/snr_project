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

StatutEcheancier statutEcheancierFromApi(String? v) {
  switch ((v ?? '').toLowerCase()) {
    case 'validé':
    case 'valide':
      return StatutEcheancier.valide;
    case 'rejeté':
    case 'rejete':
      return StatutEcheancier.rejete;
    case 'remplacé':
    case 'remplace':
      return StatutEcheancier.remplace;
    default:
      return StatutEcheancier.soumis;
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

  factory EcheanceLigne.fromApi(Map<String, dynamic> m, int idx) {
    final statut = (m['statut'] ?? '').toString().toLowerCase();
    final paye = m['paye'];
    return EcheanceLigne(
      numero: int.tryParse((m['n'] ?? m['numero'] ?? idx + 1).toString()) ?? idx + 1,
      dateLimite: DateTime.tryParse((m['date'] ?? m['dateLimite'] ?? '').toString()) ?? DateTime.now(),
      montant: (m['montant'] is num)
          ? (m['montant'] as num).toInt()
          : int.tryParse('${m['montant']}') ?? 0,
      payee: m['payee'] == true ||
          statut == 'réglée' ||
          statut == 'reglee' ||
          statut == 'payée' ||
          statut == 'payee' ||
          (paye is num && paye > 0) ||
          paye == true,
    );
  }
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

  factory Echeancier.fromApi(Map<String, dynamic> m) {
    final lignes = (m['lignes'] as List? ?? m['echeances'] as List? ?? [])
        .whereType<Map>()
        .toList();
    return Echeancier(
      id: (m['id'] ?? '').toString(),
      creanceId: (m['creanceId'] ?? '').toString(),
      debiteurNom: (m['debiteurNom'] ?? '').toString(),
      version: (m['version'] is num) ? (m['version'] as num).toInt() : 1,
      montantTotal: (m['montant'] is num) ? (m['montant'] as num).toInt() : int.tryParse('${m['montantTotal'] ?? m['montant']}') ?? 0,
      acompte: (m['acompte'] is num) ? (m['acompte'] as num).toInt() : 0,
      nombreEcheances: (m['nb'] is num) ? (m['nb'] as num).toInt() : int.tryParse('${m['nombreEcheances']}') ?? lignes.length,
      frequence: (m['frequence'] ?? '').toString(),
      statut: statutEcheancierFromApi(m['statut']?.toString()),
      echeances: [
        for (int i = 0; i < lignes.length; i++)
          EcheanceLigne.fromApi(Map<String, dynamic>.from(lignes[i]), i),
      ],
    );
  }

  Echeancier copyWith({
    String? debiteurNom,
    List<EcheanceLigne>? echeances,
  }) =>
      Echeancier(
        id: id,
        creanceId: creanceId,
        debiteurNom: debiteurNom ?? this.debiteurNom,
        version: version,
        montantTotal: montantTotal,
        acompte: acompte,
        nombreEcheances: nombreEcheances,
        frequence: frequence,
        statut: statut,
        echeances: echeances ?? this.echeances,
      );
}
