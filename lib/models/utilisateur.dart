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

  static ProfilUtilisateur profilFromApi(dynamic value) {
    final raw = value is Map ? (value['code'] ?? value['role'] ?? '') : value;
    switch (raw?.toString().toUpperCase()) {
      case 'ADMIN':
        return ProfilUtilisateur.admin;
      case 'DG':
        return ProfilUtilisateur.dg;
      case 'RESP_REC':
        return ProfilUtilisateur.respRec;
      case 'AGENT':
        return ProfilUtilisateur.agent;
      case 'JURIDIQUE':
      case 'JURISTE':
        return ProfilUtilisateur.juridique;
      case 'COMPTABLE':
        return ProfilUtilisateur.comptable;
      case 'MANDANT':
        return ProfilUtilisateur.mandant;
      default:
        return ProfilUtilisateur.debiteur;
    }
  }

  factory Utilisateur.fromApi(Map<String, dynamic> m) => Utilisateur(
        id: (m['id'] ?? '').toString(),
        nom: (m['nom'] ?? '').toString(),
        prenom: (m['prenom'] ?? '').toString(),
        email: (m['email'] ?? '').toString(),
        profil: profilFromApi(m['profil'] ?? m['role']),
        actif: m['status'] != false && m['actif'] != false,
      );
}
