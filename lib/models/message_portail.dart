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

  factory MessagePortail.fromApi(Map<String, dynamic> m) => MessagePortail(
        id: (m['id'] ?? '').toString(),
        auteur: (m['auteurNom'] ?? 'SNR 360').toString(),
        contenu: (m['texte'] ?? m['contenu'] ?? '').toString(),
        date: _parseDate(m['date']),
        deMoi: m['deMoi'] == true || m['snr'] == false,
      );

  static DateTime _parseDate(dynamic value) {
    final iso = DateTime.tryParse(value?.toString() ?? '');
    if (iso != null) return iso;
    final parts = (value?.toString() ?? '').split(RegExp(r'[/ :\-]'));
    if (parts.length >= 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.now();
  }
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
