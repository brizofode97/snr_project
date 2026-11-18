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

  static StatutActe statutFromApi(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'signé':
      case 'signe':
        return StatutActe.signe;
      case 'notifié':
      case 'notifie':
        return StatutActe.notifie;
      case 'terminé':
      case 'termine':
      case 'clos':
        return StatutActe.clos;
      default:
        return StatutActe.enPreparation;
    }
  }

  factory ActeContentieux.fromApi(Map<String, dynamic> m) {
    final circuit = m['circuitEtat']?.toString();
    final statut = statutFromApi(m['statut']?.toString());
    return ActeContentieux(
      id: (m['id'] ?? '').toString(),
      type: (m['typeLibelle'] ?? m['type'] ?? '').toString(),
      creanceId: (m['creanceId'] ?? '').toString(),
      debiteurNom: (m['debiteurNom'] ?? '').toString(),
      statut: circuit == 'EN_COURS' && statut == StatutActe.enPreparation
          ? StatutActe.enCircuitVisa
          : statut,
      dateSignature: DateTime.tryParse((m['dateSignature'] ?? '').toString()),
      dateNotification: DateTime.tryParse((m['dateNotification'] ?? '').toString()),
      echeanceDelai: DateTime.tryParse((m['dateEcheanceDelai'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  ActeContentieux copyWith({List<EtapeVisa>? circuitVisa}) => ActeContentieux(
        id: id,
        type: type,
        creanceId: creanceId,
        debiteurNom: debiteurNom,
        statut: statut,
        dateSignature: dateSignature,
        dateNotification: dateNotification,
        echeanceDelai: echeanceDelai,
        circuitVisa: circuitVisa ?? this.circuitVisa,
      );
}
