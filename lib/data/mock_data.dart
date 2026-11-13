import '../models/acte_contentieux.dart';
import '../models/bien_patrimoine.dart';
import '../models/creance.dart';
import '../models/debiteur.dart';
import '../models/document_item.dart';
import '../models/echeancier.dart';
import '../models/message_portail.dart';
import '../models/tache.dart';
import '../models/transaction.dart';
import '../models/utilisateur.dart';

/// Jeux de données factices pour la maquette UI (aucun appel réseau).
class MockData {
  MockData._();

  static final List<Debiteur> debiteurs = [
    const Debiteur(
      id: 'd1',
      code: 'D001',
      nom: 'Moussa Diop',
      type: TypeDebiteur.personnePhysique,
      identifiant: 'CNI 1234567890123',
      ville: 'Dakar',
      telephone: '+221 77 123 45 67',
      email: 'moussa.diop@mail.sn',
    ),
    const Debiteur(
      id: 'd2',
      code: 'D002',
      nom: 'Aïssatou Ndiaye',
      type: TypeDebiteur.personnePhysique,
      identifiant: 'CNI 9876543210987',
      ville: 'Thiès',
      telephone: '+221 76 234 56 78',
      email: 'aissatou.ndiaye@mail.sn',
    ),
    const Debiteur(
      id: 'd3',
      code: 'D003',
      nom: 'SARL Teranga Distribution',
      type: TypeDebiteur.personneMorale,
      identifiant: 'NINEA 004587712',
      ville: 'Dakar',
      telephone: '+221 33 820 11 22',
      email: 'contact@terangadistribution.sn',
    ),
    const Debiteur(
      id: 'd4',
      code: 'D004',
      nom: 'Cheikh Fall',
      type: TypeDebiteur.personnePhysique,
      identifiant: 'CNI 1122334455667',
      ville: 'Saint-Louis',
      telephone: '+221 70 345 67 89',
      email: 'cheikh.fall@mail.sn',
      accesPortailActif: false,
    ),
    const Debiteur(
      id: 'd5',
      code: 'D005',
      nom: 'Établissements Khadim & Fils',
      type: TypeDebiteur.personneMorale,
      identifiant: 'RCCM SN.DKR.2019.B.4521',
      ville: 'Touba',
      telephone: '+221 33 971 44 55',
      email: 'khadimetfils@entreprise.sn',
    ),
    const Debiteur(
      id: 'd6',
      code: 'D006',
      nom: 'Fatou Sow',
      type: TypeDebiteur.personnePhysique,
      identifiant: 'CNI 5566778899001',
      ville: 'Kaolack',
      telephone: '+221 78 456 78 90',
      email: 'fatou.sow@mail.sn',
    ),
  ];

  static final List<Creance> creances = [
    Creance(
      id: 'c1',
      reference: 'CR-2026-00145',
      debiteurId: 'd1',
      mandant: 'Banque Atlantique Sénégal',
      portefeuille: 'Portefeuille BAS Particuliers',
      nature: 'Prêt personnel',
      dateCreance: DateTime(2024, 3, 12),
      dateEcheance: DateTime(2025, 9, 12),
      principal: 2500000,
      interets: 180000,
      frais: 45000,
      phase: PhaseCreance.negociation,
      situation: SituationCreance.partielle,
      agentAffecte: 'Ibrahima Sarr',
      prochaineAction: 'Relance téléphonique le 18/11',
      garanties: ['Caution solidaire'],
      documentIds: ['doc1', 'doc2'],
      chronologie: [
        EvenementCreance(
          date: DateTime(2024, 3, 12),
          titre: 'Création du dossier',
          description: 'Dossier importé depuis le portefeuille BAS.',
          auteur: 'Système',
        ),
        EvenementCreance(
          date: DateTime(2024, 4, 2),
          titre: 'Validation',
          description: 'Dossier validé et affecté à Ibrahima Sarr.',
          auteur: 'Fatima Ba (Responsable)',
        ),
        EvenementCreance(
          date: DateTime(2026, 10, 20),
          titre: 'Promesse de paiement',
          description: 'Le débiteur promet 500 000 FCFA avant le 30/11.',
          auteur: 'Ibrahima Sarr',
        ),
      ],
    ),
    Creance(
      id: 'c2',
      reference: 'CR-2026-00146',
      debiteurId: 'd3',
      mandant: 'SNR (créances propres)',
      portefeuille: 'Portefeuille propre SNR',
      nature: 'Facture fournisseur impayée',
      dateCreance: DateTime(2025, 1, 5),
      dateEcheance: DateTime(2025, 7, 5),
      principal: 8900000,
      interets: 0,
      frais: 120000,
      phase: PhaseCreance.contentieux,
      situation: SituationCreance.aucunPaiement,
      agentAffecte: 'Service Juridique',
      contestee: true,
      prochaineAction: 'Dépôt d\'une mise en demeure',
      garanties: ['Nantissement de matériel'],
      documentIds: ['doc3'],
      chronologie: [
        EvenementCreance(
          date: DateTime(2025, 1, 5),
          titre: 'Création du dossier',
          description: 'Créance propre enregistrée.',
          auteur: 'Système',
        ),
        EvenementCreance(
          date: DateTime(2026, 2, 14),
          titre: 'Contestation reçue',
          description: 'Le débiteur conteste le montant des frais.',
          auteur: 'SARL Teranga Distribution',
        ),
        EvenementCreance(
          date: DateTime(2026, 9, 1),
          titre: 'Passage en contentieux',
          description: 'Ouverture d\'un dossier juridique suite à inactivité.',
          auteur: 'Service Juridique',
        ),
      ],
    ),
    Creance(
      id: 'c3',
      reference: 'CR-2026-00147',
      debiteurId: 'd2',
      mandant: 'Crédit Mutuel du Sénégal',
      portefeuille: 'Portefeuille CMS Thiès',
      nature: 'Découvert bancaire',
      dateCreance: DateTime(2025, 6, 20),
      dateEcheance: DateTime(2026, 1, 20),
      principal: 950000,
      interets: 62000,
      frais: 15000,
      phase: PhaseCreance.accord,
      situation: SituationCreance.partielle,
      agentAffecte: 'Aminata Diallo',
      prochaineAction: 'Suivi du 3ᵉ versement de l\'échéancier',
      documentIds: ['doc4'],
      chronologie: [
        EvenementCreance(
          date: DateTime(2025, 6, 20),
          titre: 'Création du dossier',
          description: 'Transmis par CMS Thiès.',
          auteur: 'Système',
        ),
        EvenementCreance(
          date: DateTime(2026, 8, 3),
          titre: 'Échéancier accepté',
          description: 'Échéancier en 6 fois accepté par le débiteur.',
          auteur: 'Aminata Diallo',
        ),
      ],
    ),
    Creance(
      id: 'c4',
      reference: 'CR-2026-00148',
      debiteurId: 'd5',
      mandant: 'SNR (créances propres)',
      portefeuille: 'Portefeuille propre SNR',
      nature: 'Loyer commercial impayé',
      dateCreance: DateTime(2024, 11, 1),
      dateEcheance: DateTime(2025, 5, 1),
      principal: 4200000,
      interets: 210000,
      frais: 60000,
      phase: PhaseCreance.cloturee,
      situation: SituationCreance.soldee,
      agentAffecte: 'Ibrahima Sarr',
      prochaineAction: 'Dossier clôturé — archivage',
      documentIds: ['doc5'],
      chronologie: [
        EvenementCreance(
          date: DateTime(2024, 11, 1),
          titre: 'Création du dossier',
          description: 'Dossier enregistré.',
          auteur: 'Système',
        ),
        EvenementCreance(
          date: DateTime(2026, 5, 30),
          titre: 'Solde complet',
          description: 'Dernier versement reçu, solde à zéro.',
          auteur: 'Service comptable',
        ),
        EvenementCreance(
          date: DateTime(2026, 6, 2),
          titre: 'Clôture',
          description: 'Dossier clôturé par le responsable recouvrement.',
          auteur: 'Fatima Ba (Responsable)',
        ),
      ],
    ),
    Creance(
      id: 'c5',
      reference: 'CR-2026-00149',
      debiteurId: 'd6',
      mandant: 'Banque Atlantique Sénégal',
      portefeuille: 'Portefeuille BAS Particuliers',
      nature: 'Crédit équipement',
      dateCreance: DateTime(2026, 2, 10),
      dateEcheance: DateTime(2026, 12, 10),
      principal: 1750000,
      interets: 95000,
      frais: 25000,
      phase: PhaseCreance.controle,
      situation: SituationCreance.aucunPaiement,
      prochaineAction: 'Contrôle des pièces en cours',
      documentIds: [],
      chronologie: [
        EvenementCreance(
          date: DateTime(2026, 2, 10),
          titre: 'Création du dossier',
          description: 'Import automatique depuis BAS.',
          auteur: 'Système',
        ),
      ],
    ),
    Creance(
      id: 'c6',
      reference: 'CR-2026-00150',
      debiteurId: 'd4',
      mandant: 'Crédit Mutuel du Sénégal',
      portefeuille: 'Portefeuille CMS Saint-Louis',
      nature: 'Prêt scolarité',
      dateCreance: DateTime(2025, 9, 15),
      dateEcheance: DateTime(2026, 3, 15),
      principal: 600000,
      interets: 30000,
      frais: 10000,
      phase: PhaseCreance.affectation,
      situation: SituationCreance.aucunPaiement,
      prochaineAction: 'Affectation à un agent en attente',
      documentIds: [],
    ),
  ];

  static final List<Echeancier> echeanciers = [
    Echeancier(
      id: 'e1',
      creanceId: 'c3',
      debiteurNom: 'Aïssatou Ndiaye',
      version: 1,
      montantTotal: 1027000,
      acompte: 150000,
      nombreEcheances: 6,
      frequence: 'Mensuelle',
      statut: StatutEcheancier.valide,
      echeances: List.generate(6, (i) {
        final n = i + 1;
        return EcheanceLigne(
          numero: n,
          dateLimite: DateTime(2026, 6 + n, 5),
          montant: 146167,
          payee: n <= 3,
        );
      }),
    ),
    Echeancier(
      id: 'e2',
      creanceId: 'c1',
      debiteurNom: 'Moussa Diop',
      version: 1,
      montantTotal: 2725000,
      acompte: 200000,
      nombreEcheances: 8,
      frequence: 'Mensuelle',
      statut: StatutEcheancier.soumis,
      echeances: List.generate(8, (i) {
        final n = i + 1;
        return EcheanceLigne(
          numero: n,
          dateLimite: DateTime(2026, 11 + n, 15),
          montant: 315625,
        );
      }),
    ),
    const Echeancier(
      id: 'e3',
      creanceId: 'c6',
      debiteurNom: 'Cheikh Fall',
      version: 2,
      montantTotal: 640000,
      acompte: 0,
      nombreEcheances: 4,
      frequence: 'Mensuelle',
      statut: StatutEcheancier.rejete,
    ),
  ];

  static final List<Transaction> transactions = [
    Transaction(
      id: 't1',
      reference: 'TRX-88213',
      date: DateTime(2026, 11, 2),
      canal: 'Mobile money (Wave)',
      montant: 146167,
      payeur: 'Aïssatou Ndiaye',
      creanceId: 'c3',
      statut: StatutTransaction.confirme,
      comptabilise: true,
    ),
    Transaction(
      id: 't2',
      reference: 'TRX-88214',
      date: DateTime(2026, 11, 8),
      canal: 'Virement bancaire',
      montant: 500000,
      payeur: 'Moussa Diop',
      creanceId: 'c1',
      statut: StatutTransaction.enAttente,
    ),
    Transaction(
      id: 't3',
      reference: 'TRX-88215',
      date: DateTime(2026, 11, 10),
      canal: 'Orange Money',
      montant: 75000,
      payeur: 'Inconnu',
      statut: StatutTransaction.nonIdentifie,
    ),
    Transaction(
      id: 't4',
      reference: 'TRX-88216',
      date: DateTime(2026, 10, 28),
      canal: 'Carte bancaire',
      montant: 146167,
      payeur: 'Aïssatou Ndiaye',
      creanceId: 'c3',
      statut: StatutTransaction.confirme,
      comptabilise: true,
    ),
    Transaction(
      id: 't5',
      reference: 'TRX-88217',
      date: DateTime(2026, 11, 11),
      canal: 'Espèces (agence)',
      montant: 200000,
      payeur: 'Établissements Khadim & Fils',
      statut: StatutTransaction.justificatifDepose,
    ),
  ];

  static final List<Reversement> reversements = [
    const Reversement(
      id: 'r1',
      mandant: 'Banque Atlantique Sénégal',
      mois: 'Octobre 2026',
      montant: 3250000,
      statut: StatutReversement.paye,
    ),
    const Reversement(
      id: 'r2',
      mandant: 'Crédit Mutuel du Sénégal',
      mois: 'Novembre 2026',
      montant: 1180000,
      statut: StatutReversement.valide,
    ),
    const Reversement(
      id: 'r3',
      mandant: 'Banque Atlantique Sénégal',
      mois: 'Novembre 2026',
      montant: 2040000,
      statut: StatutReversement.aPreparer,
    ),
  ];

  static final List<ActeContentieux> actesContentieux = [
    ActeContentieux(
      id: 'a1',
      type: 'Mise en demeure',
      creanceId: 'c2',
      debiteurNom: 'SARL Teranga Distribution',
      statut: StatutActe.enCircuitVisa,
      echeanceDelai: DateTime(2026, 12, 1),
      circuitVisa: const [
        EtapeVisa(fonction: 'Juriste', acteur: 'Omar Kane', valide: true),
        EtapeVisa(fonction: 'Chef du contentieux', acteur: 'Aïda Diouf', valide: false),
        EtapeVisa(fonction: 'Direction Générale', acteur: 'Mamadou Lamine Gueye', valide: false),
      ],
    ),
    ActeContentieux(
      id: 'a2',
      type: 'Avis à tiers détenteur (ATD)',
      creanceId: 'c2',
      debiteurNom: 'SARL Teranga Distribution',
      statut: StatutActe.enPreparation,
      echeanceDelai: DateTime(2026, 12, 20),
      circuitVisa: const [
        EtapeVisa(fonction: 'Juriste', acteur: 'Omar Kane', valide: false),
      ],
    ),
    ActeContentieux(
      id: 'a3',
      type: 'Contrainte',
      creanceId: 'c6',
      debiteurNom: 'Cheikh Fall',
      statut: StatutActe.notifie,
      dateSignature: DateTime(2026, 9, 15),
      dateNotification: DateTime(2026, 9, 22),
      echeanceDelai: DateTime(2026, 11, 22),
      circuitVisa: const [
        EtapeVisa(fonction: 'Juriste', acteur: 'Omar Kane', valide: true),
        EtapeVisa(fonction: 'Chef du contentieux', acteur: 'Aïda Diouf', valide: true),
      ],
    ),
  ];

  static final List<BienPatrimoine> biens = [
    const BienPatrimoine(
      id: 'b1',
      libelle: 'Entrepôt industriel - Zone de Rufisque',
      type: TypeBien.snr,
      ville: 'Rufisque',
      valeurEstimee: 125000000,
      statut: 'Disponible',
    ),
    const BienPatrimoine(
      id: 'b2',
      libelle: 'Matériel de production nantis',
      type: TypeBien.garantie,
      ville: 'Dakar',
      valeurEstimee: 9500000,
      creanceId: 'c2',
      statut: 'Sous garantie',
    ),
    const BienPatrimoine(
      id: 'b3',
      libelle: 'Villa R+1 - Sacré-Cœur',
      type: TypeBien.snr,
      ville: 'Dakar',
      valeurEstimee: 85000000,
      statut: 'En location',
    ),
  ];

  static final List<DocumentItem> documents = [
    DocumentItem(
      id: 'doc1',
      titre: 'Contrat de prêt personnel',
      type: 'Contrat',
      niveauAcces: 'Interne',
      versionCourante: 'v1',
      dateDepot: DateTime(2024, 3, 12),
      creanceId: 'c1',
    ),
    DocumentItem(
      id: 'doc2',
      titre: 'Caution solidaire signée',
      type: 'Garantie',
      niveauAcces: 'Interne',
      versionCourante: 'v2',
      dateDepot: DateTime(2024, 3, 15),
      creanceId: 'c1',
    ),
    DocumentItem(
      id: 'doc3',
      titre: 'Facture impayée n°F-2025-0091',
      type: 'Facture',
      niveauAcces: 'Public débiteur',
      versionCourante: 'v1',
      dateDepot: DateTime(2025, 1, 5),
      creanceId: 'c2',
    ),
    DocumentItem(
      id: 'doc4',
      titre: 'Accord échéancier signé',
      type: 'Accord',
      niveauAcces: 'Public débiteur',
      versionCourante: 'v1',
      dateDepot: DateTime(2026, 8, 3),
      creanceId: 'c3',
    ),
    DocumentItem(
      id: 'doc5',
      titre: 'Quittance de solde',
      type: 'Quittance',
      niveauAcces: 'Public débiteur',
      versionCourante: 'v1',
      dateDepot: DateTime(2026, 5, 30),
      creanceId: 'c4',
    ),
  ];

  static final List<Attestation> attestations = [
    const Attestation(
      id: 'at1',
      reference: 'ATT-2026-0032',
      type: 'Attestation de solde',
      debiteurNom: 'Établissements Khadim & Fils',
      statut: StatutAttestation.delivree,
      codeVerification: 'SNR-9F2K-7Q1',
    ),
    const Attestation(
      id: 'at2',
      reference: 'ATT-2026-0033',
      type: 'Attestation de non-créance',
      debiteurNom: 'Fatou Sow',
      statut: StatutAttestation.preparee,
      codeVerification: 'SNR-3B8L-4M0',
    ),
    const Attestation(
      id: 'at3',
      reference: 'ATT-2026-0034',
      type: 'Attestation de solde',
      debiteurNom: 'Moussa Diop',
      statut: StatutAttestation.demandee,
      codeVerification: 'SNR-5X1P-9R7',
    ),
  ];

  static final List<Tache> taches = [
    Tache(
      id: 'tc1',
      libelle: 'Relancer Moussa Diop par téléphone',
      type: 'Relance',
      date: DateTime(2026, 11, 14),
      assigneA: 'Ibrahima Sarr',
      enRetard: false,
    ),
    Tache(
      id: 'tc2',
      libelle: 'Visite terrain - SARL Teranga Distribution',
      type: 'Visite',
      date: DateTime(2026, 11, 10),
      assigneA: 'Ibrahima Sarr',
      enRetard: true,
    ),
    Tache(
      id: 'tc3',
      libelle: 'Envoyer courrier de rappel - Cheikh Fall',
      type: 'Courrier',
      date: DateTime(2026, 11, 20),
      assigneA: 'Aminata Diallo',
    ),
    Tache(
      id: 'tc4',
      libelle: 'Vérifier le 3ᵉ versement échéancier Aïssatou Ndiaye',
      type: 'Suivi paiement',
      date: DateTime(2026, 11, 5),
      assigneA: 'Aminata Diallo',
      statut: StatutTache.faite,
    ),
  ];

  static final List<Promesse> promesses = [
    Promesse(
      id: 'p1',
      debiteurNom: 'Moussa Diop',
      montant: 500000,
      date: DateTime(2026, 11, 30),
      statut: StatutPromesse.enAttente,
    ),
    Promesse(
      id: 'p2',
      debiteurNom: 'Fatou Sow',
      montant: 150000,
      date: DateTime(2026, 10, 15),
      statut: StatutPromesse.tenue,
    ),
    Promesse(
      id: 'p3',
      debiteurNom: 'Cheikh Fall',
      montant: 200000,
      date: DateTime(2026, 10, 1),
      statut: StatutPromesse.nonTenue,
    ),
  ];

  static final List<Utilisateur> utilisateurs = [
    const Utilisateur(
      id: 'u1',
      nom: 'Gueye',
      prenom: 'Mamadou Lamine',
      email: 'ml.gueye@snr360.sn',
      profil: ProfilUtilisateur.dg,
    ),
    const Utilisateur(
      id: 'u2',
      nom: 'Ba',
      prenom: 'Fatima',
      email: 'fatima.ba@snr360.sn',
      profil: ProfilUtilisateur.respRec,
    ),
    const Utilisateur(
      id: 'u3',
      nom: 'Sarr',
      prenom: 'Ibrahima',
      email: 'ibrahima.sarr@snr360.sn',
      profil: ProfilUtilisateur.agent,
    ),
    const Utilisateur(
      id: 'u4',
      nom: 'Diallo',
      prenom: 'Aminata',
      email: 'aminata.diallo@snr360.sn',
      profil: ProfilUtilisateur.agent,
    ),
    const Utilisateur(
      id: 'u5',
      nom: 'Kane',
      prenom: 'Omar',
      email: 'omar.kane@snr360.sn',
      profil: ProfilUtilisateur.juridique,
    ),
    const Utilisateur(
      id: 'u6',
      nom: 'Diouf',
      prenom: 'Aïda',
      email: 'aida.diouf@snr360.sn',
      profil: ProfilUtilisateur.comptable,
      actif: false,
    ),
  ];

  static final List<RapportPredefini> rapports = [
    const RapportPredefini(
      id: 'rap1',
      titre: 'Synthèse des encaissements',
      description: 'Évolution mensuelle des encaissements par mandant.',
      icone: 'bar_chart',
    ),
    const RapportPredefini(
      id: 'rap2',
      titre: 'Vieillissement des créances',
      description: 'Répartition des créances par ancienneté et phase.',
      icone: 'hourglass_bottom',
    ),
    const RapportPredefini(
      id: 'rap3',
      titre: 'Performance des agents',
      description: 'Montants recouvrés et dossiers traités par agent.',
      icone: 'leaderboard',
    ),
    const RapportPredefini(
      id: 'rap4',
      titre: 'Suivi du contentieux',
      description: 'Actes en cours et délais à surveiller.',
      icone: 'gavel',
    ),
  ];

  static final List<ElementAValider> validations = [
    ElementAValider(
      id: 'v1',
      type: TypeValidation.creance,
      libelle: 'Nouvelle créance CR-2026-00149 à valider',
      demandePar: 'Système (import BAS)',
      date: DateTime(2026, 11, 10),
    ),
    ElementAValider(
      id: 'v2',
      type: TypeValidation.echeancier,
      libelle: 'Échéancier proposé pour CR-2026-00145',
      demandePar: 'Ibrahima Sarr',
      date: DateTime(2026, 11, 12),
    ),
    ElementAValider(
      id: 'v3',
      type: TypeValidation.attestation,
      libelle: 'Attestation de non-créance - Fatou Sow',
      demandePar: 'Aminata Diallo',
      date: DateTime(2026, 11, 13),
    ),
  ];

  static final List<JournalAuditEntry> journalAudit = [
    JournalAuditEntry(
      id: 'j1',
      horodatage: DateTime(2026, 11, 13, 9, 12),
      acteur: 'Fatima Ba',
      action: 'Validation créance',
      objet: 'CR-2026-00147',
    ),
    JournalAuditEntry(
      id: 'j2',
      horodatage: DateTime(2026, 11, 13, 10, 4),
      acteur: 'Omar Kane',
      action: 'Visa mise en demeure',
      objet: 'Acte A-2026-00012',
    ),
    JournalAuditEntry(
      id: 'j3',
      horodatage: DateTime(2026, 11, 12, 16, 40),
      acteur: 'Aminata Diallo',
      action: 'Encaissement comptabilisé',
      objet: 'TRX-88213',
    ),
  ];

  static final List<MessagePortail> messagesDebiteur = [
    MessagePortail(
      id: 'm1',
      auteur: 'SNR 360',
      contenu: 'Votre échéancier a été validé. Le 1er versement est attendu le 05/12.',
      date: DateTime(2026, 11, 8),
    ),
    MessagePortail(
      id: 'm2',
      auteur: 'Moi',
      contenu: 'Bonjour, puis-je décaler mon prochain versement de quelques jours ?',
      date: DateTime(2026, 11, 9),
      deMoi: true,
    ),
    MessagePortail(
      id: 'm3',
      auteur: 'SNR 360',
      contenu: 'Votre demande a été transmise à votre agent en charge du dossier.',
      date: DateTime(2026, 11, 9),
    ),
  ];

  static final List<MessagePortail> messagesMandant = [
    MessagePortail(
      id: 'mm1',
      auteur: 'SNR 360',
      contenu: 'Le reversement d\'octobre 2026 a été payé sur votre compte.',
      date: DateTime(2026, 11, 2),
    ),
    MessagePortail(
      id: 'mm2',
      auteur: 'Moi',
      contenu: 'Merci, pouvez-vous confirmer la date du prochain lot à transmettre ?',
      date: DateTime(2026, 11, 3),
      deMoi: true,
    ),
  ];

  static Creance? creanceParId(String id) {
    for (final c in creances) {
      if (c.id == id) return c;
    }
    return null;
  }

  static Debiteur? debiteurParId(String id) {
    for (final d in debiteurs) {
      if (d.id == id) return d;
    }
    return null;
  }

  static List<Creance> creancesDuDebiteur(String debiteurId) =>
      creances.where((c) => c.debiteurId == debiteurId).toList();

  static Echeancier? echeancierParId(String id) {
    for (final e in echeanciers) {
      if (e.id == id) return e;
    }
    return null;
  }

  static Transaction? transactionParId(String id) {
    for (final t in transactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  static ActeContentieux? acteParId(String id) {
    for (final a in actesContentieux) {
      if (a.id == id) return a;
    }
    return null;
  }

  static BienPatrimoine? bienParId(String id) {
    for (final b in biens) {
      if (b.id == id) return b;
    }
    return null;
  }

  static DocumentItem? documentParId(String id) {
    for (final d in documents) {
      if (d.id == id) return d;
    }
    return null;
  }

  static Attestation? attestationParId(String id) {
    for (final a in attestations) {
      if (a.id == id) return a;
    }
    return null;
  }

  static Utilisateur? utilisateurParId(String id) {
    for (final u in utilisateurs) {
      if (u.id == id) return u;
    }
    return null;
  }
}
