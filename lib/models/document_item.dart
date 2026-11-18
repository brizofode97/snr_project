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

  factory DocumentItem.fromApi(Map<String, dynamic> m) {
    final liens = m['liens'];
    String? creanceId;
    if (liens is List) {
      for (final lien in liens) {
        if (lien is Map && lien['type']?.toString() == 'CREANCE') {
          creanceId = lien['cibleId']?.toString();
          break;
        }
      }
    }
    final version = m['version'] is num ? (m['version'] as num).toInt() : 0;
    return DocumentItem(
      id: (m['id'] ?? '').toString(),
      titre: (m['titre'] ?? '').toString(),
      type: (m['type'] ?? '').toString(),
      niveauAcces: (m['niveau'] ?? '').toString(),
      versionCourante: version > 0 ? 'v$version' : '—',
      dateDepot: DateTime.tryParse((m['date'] ?? '').toString()) ?? DateTime.now(),
      creanceId: creanceId,
    );
  }
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

  static StatutAttestation statutFromApi(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'délivrée':
      case 'delivree':
        return StatutAttestation.delivree;
      case 'préparée':
      case 'preparee':
        return StatutAttestation.preparee;
      case 'refusée':
      case 'refusee':
        return StatutAttestation.refusee;
      default:
        return StatutAttestation.demandee;
    }
  }

  factory Attestation.fromApi(Map<String, dynamic> m) => Attestation(
        id: (m['id'] ?? '').toString(),
        reference: (m['ref'] ?? m['reference'] ?? '').toString(),
        type: (m['type'] ?? '').toString(),
        debiteurNom: (m['debiteurNom'] ?? m['debiteurId'] ?? '').toString(),
        statut: statutFromApi(m['statut']?.toString()),
        codeVerification: (m['code'] ?? '').toString(),
      );
}
