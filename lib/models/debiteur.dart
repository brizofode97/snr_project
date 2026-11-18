enum TypeDebiteur { personnePhysique, personneMorale }

class Debiteur {
  final String id;
  final String code;
  final String nom;
  final TypeDebiteur type;
  final String identifiant; // CNI ou NINEA/RCCM
  final String ville;
  final String telephone;
  final String email;
  final bool accesPortailActif;
  final String? note;

  const Debiteur({
    required this.id,
    required this.code,
    required this.nom,
    required this.type,
    required this.identifiant,
    required this.ville,
    required this.telephone,
    required this.email,
    this.accesPortailActif = true,
    this.note,
  });

  factory Debiteur.fromApi(Map<String, dynamic> m) {
    final typeStr = (m['type'] ?? '').toString().toUpperCase();
    final type = typeStr == 'PM' ? TypeDebiteur.personneMorale : TypeDebiteur.personnePhysique;
    final ids = m['ids'];
    String ident = '';
    if (ids is Map) {
      final normalised = <String, dynamic>{
        for (final entry in ids.entries)
          entry.key.toString().toLowerCase(): entry.value,
      };
      ident = (normalised['cni'] ??
              normalised['ninea'] ??
              normalised['rccm'] ??
              ids.values.firstOrNull ??
              '')
          .toString();
    }
    final acces = m['acces']?.toString();
    return Debiteur(
      id: (m['id'] ?? '').toString(),
      code: (m['code'] ?? m['id'] ?? '').toString(),
      nom: (m['nom'] ?? '').toString(),
      type: type,
      identifiant: ident,
      ville: (m['ville'] ?? '').toString(),
      telephone: (m['tel'] ?? m['telephone'] ?? '').toString(),
      email: (m['email'] ?? '').toString(),
      accesPortailActif: acces == null ? true : acces == 'Actif',
      note: m['note']?.toString(),
    );
  }
}
