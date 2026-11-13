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
}
