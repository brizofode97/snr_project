import '../models/acte_contentieux.dart';
import '../models/creance.dart';
import '../models/debiteur.dart';
import '../models/document_item.dart';
import '../models/echeancier.dart';
import '../models/message_portail.dart';
import '../models/tache.dart';
import '../models/transaction.dart';
import '../models/utilisateur.dart';
import 'api/creances_api_service.dart';

class SnrRepository {
  SnrRepository._();
  static final SnrRepository instance = SnrRepository._();
  final _api = CreancesApiService.instance;

  List<Creance> _creances = [];
  List<Debiteur> _debiteurs = [];
  List<Echeancier> _echeanciers = [];
  List<Transaction> _transactions = [];
  List<Tache> _taches = [];
  List<Promesse> _promesses = [];
  List<DocumentItem> _documents = [];
  List<Attestation> _attestations = [];
  List<ActeContentieux> _actes = [];
  List<Utilisateur> _utilisateurs = [];
  List<Reversement> _reversements = [];
  List<MessagePortail> _messages = [];
  List<dynamic> _mandants = [];
  List<dynamic> _audit = [];
  List<dynamic> _controles = [];
  bool _loaded = false;

  List<Creance> get creances => _creances;
  List<Debiteur> get debiteurs => _debiteurs;
  List<Echeancier> get echeanciers => _echeanciers;
  List<Transaction> get transactions => _transactions;
  List<Tache> get taches => _taches;
  List<Promesse> get promesses => _promesses;
  List<DocumentItem> get documents => _documents;
  List<Attestation> get attestations => _attestations;
  List<ActeContentieux> get actesContentieux => _actes;
  List<Utilisateur> get utilisateurs => _utilisateurs;
  List<Reversement> get reversements => _reversements;
  List<MessagePortail> get messages => _messages;
  List<dynamic> get mandants => _mandants;
  List<dynamic> get audit => _audit;
  List<dynamic> get controles => _controles;
  bool get isLoaded => _loaded;

  List<dynamic> _vide(dynamic _) => <dynamic>[];

  Future<void> refreshAll() async {
    final results = await Future.wait([
      _api.getCreances(),
      _api.getDebiteurs(),
      _api.getEcheanciers().catchError(_vide),
      _api.getTransactions().catchError(_vide),
      _api.getTaches().catchError(_vide),
      _api.getPromesses().catchError(_vide),
      _api.getDocuments().catchError(_vide),
      _api.getAttestations().catchError(_vide),
      _api.getActesContentieux().catchError(_vide),
      _api.getUtilisateurs().catchError(_vide),
      _api.getReversements().catchError(_vide),
      _api.getMessages().catchError(_vide),
      _api.getMandants().catchError(_vide),
      _api.getAudit().catchError(_vide),
      _api.getAdminControles().catchError(_vide),
    ]);
    _creances = _parse(results[0], Creance.fromApi);
    _debiteurs = _parse(results[1], Debiteur.fromApi);
    _echeanciers = _parse(results[2], Echeancier.fromApi);
    _transactions = _parse(results[3], Transaction.fromApi);
    _taches = _parse(results[4], Tache.fromApi);
    _promesses = _parse(results[5], Promesse.fromApi);
    _documents = _parse(results[6], DocumentItem.fromApi);
    _attestations = _parse(results[7], Attestation.fromApi);
    _actes = _parse(results[8], ActeContentieux.fromApi);
    _utilisateurs = _parse(results[9], Utilisateur.fromApi);
    _reversements = _parse(results[10], Reversement.fromApi);
    _messages = _parse(results[11], MessagePortail.fromApi);
    _mandants = _liste(results[12]);
    _audit = _liste(results[13]);
    _controles = _liste(results[14]);

    final documentIdsParCreance = <String, List<String>>{};
    for (final document in _documents) {
      if (document.creanceId == null) continue;
      documentIdsParCreance.putIfAbsent(document.creanceId!, () => <String>[]).add(document.id);
    }
    _creances = _creances
        .map(
          (c) => c.copyWith(
            documentIds: documentIdsParCreance[c.id] ?? c.documentIds,
          ),
        )
        .toList();

    final nomsParCreance = <String, String>{};
    for (final c in _creances) {
      nomsParCreance[c.id] = debiteurNom(c.debiteurId);
    }
    _echeanciers = _echeanciers
        .map((e) => e.copyWith(debiteurNom: nomsParCreance[e.creanceId] ?? ''))
        .toList();
    _promesses = _promesses
        .map(
          (p) => Promesse(
            id: p.id,
            debiteurNom: nomsParCreance[p.creanceId ?? ''] ?? p.debiteurNom,
            montant: p.montant,
            date: p.date,
            statut: p.statut,
            creanceId: p.creanceId,
          ),
        )
        .toList();
    _loaded = true;
  }

  List<dynamic> _liste(dynamic data) =>
      data is List ? List<dynamic>.from(data) : <dynamic>[];

  List<T> _parse<T>(dynamic data, T Function(Map<String, dynamic>) factory) {
    if (data is! List) return <T>[];
    return data
        .whereType<Map>()
        .map((e) => factory(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Creance> fetchCreance(String id) async {
    final map = await _api.getCreance(id);
    var creance = Creance.fromApi(map);
    final results = await Future.wait([
      _api.getEvenements(id).catchError(_vide),
      _api.getSolde(id).catchError((_) => <String, dynamic>{}),
    ]);
    final evenements = _parse(results[0], EvenementCreance.fromApi);
    final solde = results[1] is Map
        ? Map<String, dynamic>.from(results[1] as Map)
        : <String, dynamic>{};
    final soldeRestant = solde['solde'] ?? solde['restant'];
    creance = creance.copyWith(
      chronologie: evenements,
      soldeConnu: soldeRestant is num ? soldeRestant.toInt() : null,
      situation: solde['situation'] != null
          ? situationFromApi(solde['situation'].toString())
          : null,
    );
    final index = _creances.indexWhere((x) => x.id == creance.id);
    if (index >= 0) {
      _creances[index] = creance;
    } else {
      _creances.add(creance);
    }
    return creance;
  }

  Future<Echeancier> fetchEcheancier(String id) async {
    final map = await _api.getEcheancierSituation(id);
    final base = echeancierParId(id) ??
        Echeancier.fromApi(<String, dynamic>{'id': id});
    final lignes = map['lignes'] ?? map['echeances'];
    final parsed = lignes is List
        ? lignes
            .whereType<Map>()
            .toList()
            .asMap()
            .entries
            .map(
              (entry) => EcheanceLigne.fromApi(
                Map<String, dynamic>.from(entry.value),
                entry.key,
              ),
            )
            .toList()
        : <EcheanceLigne>[];
    final echeancier = base.copyWith(echeances: parsed);
    final index = _echeanciers.indexWhere((x) => x.id == id);
    if (index >= 0) {
      _echeanciers[index] = echeancier;
    } else {
      _echeanciers.add(echeancier);
    }
    return echeancier;
  }

  Future<ActeContentieux> fetchActe(String id) async {
    final map = await _api.getActeContentieux(id);
    var acte = ActeContentieux.fromApi(map);
    final circuit = map['circuit'];
    if (circuit is Map) {
      final etapes = circuit['etapes'];
      if (etapes is List) {
        acte = acte.copyWith(
          circuitVisa: etapes
              .whereType<Map>()
              .map(
                (e) => EtapeVisa(
                  fonction: (e['fonction'] ?? '').toString(),
                  acteur: (e['utilisateur'] ?? e['acteur'] ?? '').toString(),
                  valide: e['decision']?.toString() == 'VISE' || e['valide'] == true,
                ),
              )
              .toList(),
        );
      }
    }
    final index = _actes.indexWhere((x) => x.id == id);
    if (index >= 0) {
      _actes[index] = acte;
    } else {
      _actes.add(acte);
    }
    return acte;
  }

  Creance? creanceParId(String id) {
    for (final c in _creances) {
      if (c.id == id) return c;
    }
    return null;
  }

  Debiteur? debiteurParId(String id) {
    for (final d in _debiteurs) {
      if (d.id == id) return d;
    }
    return null;
  }

  String debiteurNom(String id) => debiteurParId(id)?.nom ?? id;

  String mandantNom(String id) {
    for (final m in _mandants) {
      if (m is Map && (m['id'] ?? '').toString() == id) {
        return (m['nom'] ?? m['sigle'] ?? id).toString();
      }
    }
    return id;
  }

  List<Creance> creancesDuDebiteur(String debiteurId) =>
      _creances.where((c) => c.debiteurId == debiteurId).toList();

  Echeancier? echeancierParId(String id) {
    for (final e in _echeanciers) {
      if (e.id == id) return e;
    }
    return null;
  }

  Echeancier? echeancierParCreanceId(String creanceId) {
    for (final e in _echeanciers) {
      if (e.creanceId == creanceId) return e;
    }
    return null;
  }

  Future<void> setDebiteurAcces(String id, bool actif) async {
    await _api.setDebiteurAcces(id, actif);
    final index = _debiteurs.indexWhere((d) => d.id == id);
    if (index >= 0) {
      _debiteurs[index] = Debiteur(
        id: _debiteurs[index].id,
        code: _debiteurs[index].code,
        nom: _debiteurs[index].nom,
        type: _debiteurs[index].type,
        identifiant: _debiteurs[index].identifiant,
        ville: _debiteurs[index].ville,
        telephone: _debiteurs[index].telephone,
        email: _debiteurs[index].email,
        accesPortailActif: actif,
        note: _debiteurs[index].note,
      );
    }
  }

  Future<void> confirmTransaction(String id, String bankRef) =>
      _api.confirmTransaction(id, bankRef);

  Future<void> decideEcheancier(String id, bool ok, {String? motif}) =>
      _api.decideEcheancier(id, ok: ok, motif: motif);

  Future<void> decideAttestation(String id, bool ok, {String? motif}) =>
      _api.decideAttestation(id, ok: ok, motif: motif);

  Future<void> decideActe(String id, bool vise, {String? motif}) =>
      _api.decideActe(id, vise: vise, motif: motif);

  Future<void> saveUtilisateur(Map<String, dynamic> body) =>
      _api.saveUtilisateur(body);

  Future<void> sendMessage(Map<String, dynamic> body) => _api.sendMessage(body);

  Future<void> refreshMessages({String? mandantId, String? debiteurId}) async {
    final data = await _api.getMessages(
      mandantId: mandantId,
      debiteurId: debiteurId,
    );
    _messages = _parse(data, MessagePortail.fromApi);
  }

  Future<int> markMessagesRead({
    required String mandantId,
    required String debiteurId,
  }) =>
      _api.markMessagesRead(mandantId: mandantId, debiteurId: debiteurId);

  /* ------------------------------------------------------------------ *
   * Écritures métier : chaque opération resynchronise le dépôt local
   * ------------------------------------------------------------------ */

  Future<Map<String, dynamic>> _write(
    Future<Map<String, dynamic>> Function() operation,
  ) async {
    final result = await operation();
    await refreshAll();
    return result;
  }

  Future<Map<String, dynamic>> creerCreance(Map<String, dynamic> body) =>
      _write(() => _api.createCreance(body));

  Future<Map<String, dynamic>> corrigerCreance(String id, Map<String, dynamic> body) =>
      _write(() => _api.updateCreance(id, body));

  Future<Map<String, dynamic>> soumettreCreance(String id) =>
      _write(() => _api.submitCreance(id));

  Future<Map<String, dynamic>> joindrePiece(
    String id, {
    required String type,
    required String titre,
  }) =>
      _write(() => _api.addCreancePiece(id, type: type, titre: titre));

  Future<Map<String, dynamic>> validerCreance(String id) =>
      _write(() => _api.validateCreance(id));

  Future<Map<String, dynamic>> rejeterCreance(String id, String motif) =>
      _write(() => _api.rejectCreance(id, motif));

  Future<Map<String, dynamic>> affecterCreance(
    String id, {
    required String agentId,
    required String motif,
  }) =>
      _write(() => _api.assignCreance(id, agentId: agentId, motif: motif));

  Future<Map<String, dynamic>> enregistrerAction(
    String id,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.recordCreanceAction(id, body));

  Future<Map<String, dynamic>> planifierAction(
    String id, {
    required String type,
    String? date,
    required String label,
  }) =>
      _write(
        () => _api.planifierAction(id, type: type, date: date, label: label),
      );

  Future<Map<String, dynamic>> realiserTache(String id) =>
      _write(() => _api.realiserTache(id));

  Future<Map<String, dynamic>> enregistrerPromesse(
    String id,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.addPromesse(id, body));

  Future<Map<String, dynamic>> enregistrerCourrier(
    String id,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.addCourrier(id, body));

  Future<Map<String, dynamic>> modifierCourrier(
    String id,
    String pieceId,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.updateCourrier(id, pieceId, body));

  Future<Map<String, dynamic>> demanderCloture(String id, String motif) =>
      _write(() => _api.demanderCloture(id, motif));

  Future<Map<String, dynamic>> deciderCloture(
    String id, {
    required bool ok,
    required String motif,
  }) =>
      _write(() => _api.decideCloture(id, ok: ok, motif: motif));

  Future<Map<String, dynamic>> reouvrirCreance(String id, String motif) =>
      _write(() => _api.reopenCreance(id, motif));

  Future<Map<String, dynamic>> demanderAttestation(
    String creanceId,
    String type,
  ) =>
      _write(() => _api.demanderAttestation(creanceId, type));

  Future<Map<String, dynamic>> preparerAttestation(String id) =>
      _write(() => _api.prepareAttestation(id));

  Future<Map<String, dynamic>> creerEcheancier(Map<String, dynamic> body) =>
      _write(() => _api.createEcheancier(body));

  Future<Map<String, dynamic>> joindrePreuveEcheancier(
    String id,
    String description,
  ) =>
      _write(() => _api.addEcheancierPreuve(id, description));

  Future<Map<String, dynamic>> repondreEcheancier(String id, bool accepte) =>
      _write(() => _api.reponseDebiteurEcheancier(id, accepte));

  Future<Map<String, dynamic>> importerPortefeuille(Map<String, dynamic> body) =>
      _write(() => _api.importerPortefeuille(body));

  Future<Map<String, dynamic>> contesterCreance(String id, String motif) =>
      _write(() => _api.contesterCreance(id, motif));

  Future<Map<String, dynamic>> deciderContestation(
    String id,
    String issue,
    String motif,
  ) =>
      _write(() => _api.decideContestation(id, issue, motif));

  Future<Map<String, dynamic>> ajouterAjustement(
    String creanceId,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.addAjustement(creanceId, body));

  Future<Map<String, dynamic>> deciderAjustement(
    String id, {
    required bool ok,
    required String motif,
  }) =>
      _write(() => _api.decideAjustement(id, ok: ok, motif: motif));

  Future<Map<String, dynamic>> enregistrerTransaction(Map<String, dynamic> body) =>
      _write(() => _api.createTransaction(body));

  Future<Map<String, dynamic>> rejeterTransaction(String id, String motif) =>
      _write(() => _api.rejectTransaction(id, motif));

  Future<Map<String, dynamic>> identifierTransaction(String id, String debiteurId) =>
      _write(() => _api.identifyTransaction(id, debiteurId));

  Future<Map<String, dynamic>> ventilerTransaction(
    String id,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.allocateTransaction(id, body));

  Future<dynamic> rapprochementAuto() async {
    final result = await _api.autoRapprochement();
    await refreshAll();
    return result;
  }

  Future<Map<String, dynamic>> creerActe(String creanceId, String type) =>
      _write(() => _api.createActe(creanceId, type));

  Future<Map<String, dynamic>> creerFichePoursuites(String acteId) =>
      _write(() => _api.createFichePoursuites(acteId));

  Future<Map<String, dynamic>> viserFichePoursuites(
    String acteId, {
    required String decision,
    String? motif,
  }) =>
      _write(
        () => _api.visaFichePoursuites(acteId, decision: decision, motif: motif),
      );

  Future<Map<String, dynamic>> enregistrerAccuseReception(String acteId) =>
      _write(() => _api.enregistrerAccuseReception(acteId));

  Future<Map<String, dynamic>> enregistrerSuite(
    String acteId,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.enregistrerSuite(acteId, body));

  Future<Map<String, dynamic>> viserSuite(
    String acteId, {
    required String decision,
    String? motif,
  }) =>
      _write(() => _api.visaSuite(acteId, decision: decision, motif: motif));

  Future<Map<String, dynamic>> deposerDocument(Map<String, dynamic> body) =>
      _write(() => _api.createDocument(body));

  Future<Map<String, dynamic>> ajouterVersionDocument(
    String id,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.addDocumentVersion(id, body));

  Future<Map<String, dynamic>> enregistrerParametres(Map<String, dynamic> body) =>
      _write(() => _api.saveParametresMetier(body));

  Future<Map<String, dynamic>> creerMandant(Map<String, dynamic> body) =>
      _write(() => _api.createMandant(body));

  Future<Map<String, dynamic>> modifierMandant(
    String id,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.updateMandant(id, body));

  Future<dynamic> supprimerMandant(String id) async {
    final result = await _api.deleteMandant(id);
    await refreshAll();
    return result;
  }

  Future<Map<String, dynamic>> enregistrerProfil(Map<String, dynamic> body) async {
    final result = await _api.saveProfil(body);
    return result;
  }

  Future<Map<String, dynamic>> payerSurPortail(
    String creanceId,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.portalPayment(creanceId, body));

  Future<Map<String, dynamic>> envoyerJustificatifPortail(
    String creanceId,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.portalProof(creanceId, body));

  Future<Map<String, dynamic>> demanderEchelonnementPortail(
    String creanceId,
    int? nb,
    String commentaire,
  ) =>
      _write(
        () => _api.demanderEchelonnementPortail(creanceId, nb, commentaire),
      );

  Future<Map<String, dynamic>> exporterComptable() =>
      _write(() => _api.exportComptable());

  Future<Map<String, dynamic>> enregistrerReversement(
    String mandantId,
    String mois,
    String statut,
  ) =>
      _write(() => _api.saveReversement(mandantId, mois, statut));

  Future<Map<String, dynamic>> envoyerMessage(Map<String, dynamic> body) =>
      _write(() => _api.sendMessage(body));

  Future<Map<String, dynamic>> creerDebiteur(Map<String, dynamic> body) =>
      _write(() => _api.createDebiteur(body));

  Future<Map<String, dynamic>> modifierDebiteur(
    String id,
    Map<String, dynamic> body,
  ) =>
      _write(() => _api.updateDebiteur(id, body));

  Future<Map<String, dynamic>> inviterDebiteur(String id) =>
      _write(() => _api.inviterDebiteur(id));

  Future<String> demanderReinitialisationMotDePasse(String login) =>
      _api.forgotPassword(login);

  Future<Map<String, dynamic>> reinitialiserMotDePasse(
    Map<String, dynamic> body,
  ) =>
      _api.resetPassword(body);

  Future<Map<String, dynamic>> initialiserMotDePasse(
    Map<String, dynamic> body,
  ) =>
      _api.resetPasswordInit(body);
}
