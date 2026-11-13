class DocumentItem {
  final String id;
  final String titre;
  final String type;
  final String niveauAcces;
  final String versionCourante;
  final DateTime dateDepot;
  final String? creanceId;

  const DocumentItem({
    required this.id,
    required this.titre,
    required this.type,
    required this.niveauAcces,
    required this.versionCourante,
    required this.dateDepot,
    this.creanceId,
  });
}

enum StatutAttestation { demandee, preparee, delivree, refusee }

extension StatutAttestationLabel on StatutAttestation {
  String get libelle {
    switch (this) {
      case StatutAttestation.demandee:
        return 'Demandée';
      case StatutAttestation.preparee:
        return 'Préparée';
      case StatutAttestation.delivree:
        return 'Délivrée';
      case StatutAttestation.refusee:
        return 'Refusée';
    }
  }
}

class Attestation {
  final String id;
  final String reference;
  final String type;
  final String debiteurNom;
  final StatutAttestation statut;
  final String codeVerification;

  const Attestation({
    required this.id,
    required this.reference,
    required this.type,
    required this.debiteurNom,
    required this.statut,
    required this.codeVerification,
  });
}
