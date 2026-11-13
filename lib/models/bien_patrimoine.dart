enum TypeBien { snr, garantie }

class BienPatrimoine {
  final String id;
  final String libelle;
  final TypeBien type;
  final String ville;
  final int valeurEstimee;
  final String? creanceId;
  final String statut;

  const BienPatrimoine({
    required this.id,
    required this.libelle,
    required this.type,
    required this.ville,
    required this.valeurEstimee,
    this.creanceId,
    required this.statut,
  });
}
