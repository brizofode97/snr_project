enum ProfilUtilisateur { admin, dg, respRec, agent, juridique, comptable, mandant, debiteur }

extension ProfilUtilisateurLabel on ProfilUtilisateur {
  String get libelle {
    switch (this) {
      case ProfilUtilisateur.admin:
        return 'Administrateur';
      case ProfilUtilisateur.dg:
        return 'Direction Générale';
      case ProfilUtilisateur.respRec:
        return 'Responsable recouvrement';
      case ProfilUtilisateur.agent:
        return 'Agent de recouvrement';
      case ProfilUtilisateur.juridique:
        return 'Juridique';
      case ProfilUtilisateur.comptable:
        return 'Comptable';
      case ProfilUtilisateur.mandant:
        return 'Mandant';
      case ProfilUtilisateur.debiteur:
        return 'Débiteur';
    }
  }
}

class Utilisateur {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final ProfilUtilisateur profil;
  final bool actif;

  const Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.profil,
    this.actif = true,
  });
}
