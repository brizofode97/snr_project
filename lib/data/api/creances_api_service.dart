import '../../core/network/api_client.dart';

class CreancesApiService {
  CreancesApiService._();
  static final CreancesApiService instance = CreancesApiService._();
  final ApiClient _api = ApiClient.instance;

  List<dynamic> _asList(dynamic data) =>
      data is List ? data.toList() : const <dynamic>[];

  Map<String, dynamic> _asMap(dynamic data) =>
      data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};

  Future<List<dynamic>> getCreances({Map<String, String>? query}) async {
    final data = await _api.get(
      '/creances',
      query: <String, String>{'size': '1000', ...?query},
    );
    return _asList(data);
  }

  Future<Map<String, dynamic>> getCreance(String id) =>
      _api.get('/creances/$id').then(_asMap);

  Future<List<dynamic>> getEvenements(String creanceId) =>
      _api.get('/creances/$creanceId/evenements').then(_asList);

  Future<Map<String, dynamic>> getSolde(String creanceId) =>
      _api.get('/creances/$creanceId/solde').then(_asMap);

  Future<String> exportCsv() => _api.getText('/creances/export');

  Future<List<dynamic>> getDebiteurs() => _api.get('/debiteurs').then(_asList);

  Future<Map<String, dynamic>> getDebiteur(String id) =>
      _api.get('/debiteurs/$id').then(_asMap);

  Future<Map<String, dynamic>> createDebiteur(Map<String, dynamic> body) =>
      _api.post('/debiteurs', body: body).then(_asMap);

  Future<Map<String, dynamic>> updateDebiteur(String id, Map<String, dynamic> body) =>
      _api.put('/debiteurs/$id', body: body).then(_asMap);

  Future<Map<String, dynamic>> inviterDebiteur(String id) =>
      _api.post('/debiteurs/$id/acces/invitation').then(_asMap);

  Future<Map<String, dynamic>> setDebiteurAcces(String id, bool actif) => _api
      .put('/debiteurs/$id/acces', body: <String, dynamic>{'actif': actif})
      .then(_asMap);

  Future<List<dynamic>> getMandants() => _api.get('/mandants').then(_asList);

  Future<List<dynamic>> getPortefeuilles() =>
      _api.get('/portefeuilles').then(_asList);

  Future<List<dynamic>> getActeurs() => _api.get('/acteurs').then(_asList);

  Future<List<dynamic>> getTaches({String? assignee}) => _api
      .get(
        '/taches',
        query: assignee == null ? null : <String, String>{'assignee': assignee},
      )
      .then(_asList);

  Future<List<dynamic>> getPromesses() => _api.get('/promesses').then(_asList);

  Future<List<dynamic>> getPieces() => _api.get('/pieces').then(_asList);

  Future<List<dynamic>> getEcheanciers() =>
      _api.get('/echeanciers').then(_asList);

  Future<Map<String, dynamic>> getEcheancierSituation(String id) =>
      _api.get('/echeanciers/$id/situation').then(_asMap);

  Future<Map<String, dynamic>> decideEcheancier(
    String id, {
    required bool ok,
    String? motif,
  }) => _api
      .post(
        '/echeanciers/$id/decision',
        body: <String, dynamic>{'ok': ok, 'motif': motif},
      )
      .then(_asMap);

  Future<List<dynamic>> getTransactions() =>
      _api.get('/transactions').then(_asList);

  Future<Map<String, dynamic>> getTransaction(String id) =>
      _api.get('/transactions/$id').then(_asMap);

  Future<Map<String, dynamic>> confirmTransaction(String id, String bankRef) =>
      _api
          .post(
            '/transactions/$id/confirmation',
            body: <String, dynamic>{'bankRef': bankRef},
          )
          .then(_asMap);

  Future<List<dynamic>> getReversements({String? mandant}) => _api
      .get(
        '/reversements',
        query: mandant == null ? null : <String, String>{'mandant': mandant},
      )
      .then(_asList);

  Future<List<dynamic>> getActesContentieux() => _api
      .get('/actes-contentieux', query: const <String, String>{'size': '1000'})
      .then(_asList);

  Future<Map<String, dynamic>> getActeContentieux(String id) =>
      _api.get('/actes-contentieux/$id').then(_asMap);

  Future<Map<String, dynamic>> decideActe(
    String id, {
    required bool vise,
    String? motif,
  }) => _api
      .post(
        '/actes-contentieux/$id/visa',
        body: <String, dynamic>{
          'decision': vise ? 'VISE' : 'REJETE',
          'motif': motif,
        },
      )
      .then(_asMap);

  Future<List<dynamic>> getDocuments() => _api
      .get('/documents', query: const <String, String>{'size': '1000'})
      .then(_asList);

  Future<Map<String, dynamic>> getDocument(String id) =>
      _api.get('/documents/$id').then(_asMap);

  Future<List<dynamic>> getAttestations() =>
      _api.get('/attestations').then(_asList);

  Future<Map<String, dynamic>> decideAttestation(
    String id, {
    required bool ok,
    String? motif,
  }) => _api
      .post(
        '/attestations/$id/decision',
        body: <String, dynamic>{'ok': ok, 'motif': motif},
      )
      .then(_asMap);

  Future<List<dynamic>> getUtilisateurs() => _api
      .get('/utilisateurs', query: const <String, String>{'size': '1000'})
      .then(_asList);

  Future<Map<String, dynamic>> getUtilisateur(String id) =>
      _api.get('/utilisateur-by-id/$id').then(_asMap);

  Future<Map<String, dynamic>> saveUtilisateur(Map<String, dynamic> body) =>
      (body['id'] == null || body['id'].toString().isEmpty)
      ? _api.post('/utilisateur', body: body).then(_asMap)
      : _api.put('/utilisateur', body: body).then(_asMap);

  Future<List<dynamic>> getMessages({String? mandantId, String? debiteurId}) {
    final query = <String, String>{
      'mandantId': ?mandantId,
      'debiteurId': ?debiteurId,
    };
    return _api
        .get('/messages', query: query.isEmpty ? null : query)
        .then(_asList);
  }

  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> body) =>
      _api.post('/messages', body: body).then(_asMap);

  Future<int> markMessagesRead({
    required String mandantId,
    required String debiteurId,
  }) async {
    final data = await _api.post(
      '/messages/lu',
      body: <String, dynamic>{'mandantId': mandantId, 'debiteurId': debiteurId},
    );
    return data is int ? data : int.tryParse(data?.toString() ?? '') ?? 0;
  }

  Future<List<dynamic>> getAdminControles() =>
      _api.get('/admin/controles').then(_asList);

  Future<List<dynamic>> getAdminDroits() =>
      _api.get('/admin/droits').then(_asList);

  Future<Map<String, dynamic>> getParametresMetier() =>
      _api.get('/parametres-metier').then(_asMap);

  Future<List<dynamic>> getProfilsAdmin() =>
      _api.get('/admin/profils').then(_asList);

  Future<List<dynamic>> getProfilsCatalogue() =>
      _api.get('/admin/profils/catalogue').then(_asList);

  Future<List<dynamic>> getAudit() => _api
      .get('/audit', query: const <String, String>{'size': '200'})
      .then(_asList);

  Future<Map<String, dynamic>> getAuditVerification() =>
      _api.get('/audit/verification').then(_asMap);

  Future<Map<String, dynamic>> me() => _api.get('/auth/me').then(_asMap);

  /* ------------------------------------------------------------------ *
   * Créances — création et traitement complet du dossier
   * ------------------------------------------------------------------ */

  Future<Map<String, dynamic>> createCreance(Map<String, dynamic> body) =>
      _api.post('/creances', body: body).then(_asMap);

  Future<Map<String, dynamic>> updateCreance(String id, Map<String, dynamic> body) =>
      _api.put('/creances/$id', body: body).then(_asMap);

  Future<Map<String, dynamic>> submitCreance(String id) =>
      _api.post('/creances/$id/soumission').then(_asMap);

  Future<Map<String, dynamic>> addCreancePiece(
    String id, {
    required String type,
    required String titre,
  }) =>
      _api
          .post('/creances/$id/pieces', body: <String, dynamic>{'type': type, 'titre': titre})
          .then(_asMap);

  Future<Map<String, dynamic>> validateCreance(String id) =>
      _api.post('/creances/$id/validation').then(_asMap);

  Future<Map<String, dynamic>> rejectCreance(String id, String motif) =>
      _api.post('/creances/$id/rejet', body: <String, dynamic>{'motif': motif}).then(_asMap);

  Future<Map<String, dynamic>> assignCreance(
    String id, {
    required String agentId,
    required String motif,
  }) =>
      _api
          .put('/creances/$id/affectation', body: <String, dynamic>{'agentId': agentId, 'motif': motif})
          .then(_asMap);

  Future<Map<String, dynamic>> recordCreanceAction(String id, Map<String, dynamic> body) =>
      _api.post('/creances/$id/actions', body: body).then(_asMap);

  Future<Map<String, dynamic>> planifierAction(
    String id, {
    required String type,
    String? date,
    required String label,
  }) =>
      _api
          .post(
            '/creances/$id/planifications',
            body: <String, dynamic>{'type': type, 'date': date, 'label': label},
          )
          .then(_asMap);

  Future<Map<String, dynamic>> realiserTache(String id) =>
      _api.post('/taches/$id/realisation').then(_asMap);

  Future<Map<String, dynamic>> addPromesse(String id, Map<String, dynamic> body) =>
      _api.post('/creances/$id/promesses', body: body).then(_asMap);

  Future<Map<String, dynamic>> addCourrier(String id, Map<String, dynamic> body) =>
      _api.post('/creances/$id/courriers', body: body).then(_asMap);

  Future<Map<String, dynamic>> updateCourrier(
    String id,
    String pieceId,
    Map<String, dynamic> body,
  ) =>
      _api.put('/creances/$id/courriers/$pieceId', body: body).then(_asMap);

  Future<Map<String, dynamic>> sendCourrier(String id, String pieceId, String canal) =>
      _api
          .post(
            '/creances/$id/courriers/$pieceId/envoi',
            body: <String, dynamic>{'canal': canal},
          )
          .then(_asMap);

  Future<Map<String, dynamic>> demanderCloture(String id, String motif) =>
      _api.post('/creances/$id/cloture', body: <String, dynamic>{'motif': motif}).then(_asMap);

  Future<Map<String, dynamic>> decideCloture(
    String id, {
    required bool ok,
    required String motif,
  }) =>
      _api
          .post(
            '/creances/$id/cloture/decision',
            body: <String, dynamic>{'ok': ok, 'motif': motif},
          )
          .then(_asMap);

  Future<Map<String, dynamic>> reopenCreance(String id, String motif) =>
      _api.post('/creances/$id/reouverture', body: <String, dynamic>{'motif': motif}).then(_asMap);

  Future<Map<String, dynamic>> demanderAttestation(String creanceId, String type) => _api
      .post('/creances/$creanceId/attestations', body: <String, dynamic>{'type': type})
      .then(_asMap);

  Future<Map<String, dynamic>> prepareAttestation(String id) =>
      _api.post('/attestations/$id/preparation').then(_asMap);

  Future<Map<String, dynamic>> createEcheancier(Map<String, dynamic> body) =>
      _api.post('/echeanciers', body: body).then(_asMap);

  Future<Map<String, dynamic>> demanderEchelonnementPortail(
    String creanceId,
    int? nb,
    String commentaire,
  ) =>
      _api
          .post(
            '/creances/$creanceId/echelonnement',
            body: <String, dynamic>{'nb': nb, 'commentaire': commentaire},
          )
          .then(_asMap);

  Future<Map<String, dynamic>> addEcheancierPreuve(String id, String acceptation) =>
      _api
          .post(
            '/echeanciers/$id/preuve',
            body: <String, dynamic>{'acceptation': acceptation},
          )
          .then(_asMap);

  Future<Map<String, dynamic>> reponseDebiteurEcheancier(
    String id,
    bool ok, {
    String motif = '',
  }) =>
      _api
          .post(
            '/echeanciers/$id/reponse-debiteur',
            body: <String, dynamic>{'ok': ok, 'motif': motif},
          )
          .then(_asMap);

  Future<Map<String, dynamic>> importerPortefeuille(Map<String, dynamic> body) =>
      _api.post('/imports', body: body).then(_asMap);

  Future<Map<String, dynamic>> contesterCreance(String id, String motif) =>
      _api.post('/creances/$id/contestation', body: <String, dynamic>{'motif': motif}).then(_asMap);

  Future<Map<String, dynamic>> decideContestation(String id, String issue, String motif) =>
      _api
          .post(
            '/creances/$id/contestation/decision',
            body: <String, dynamic>{'issue': issue, 'motif': motif},
          )
          .then(_asMap);

  Future<Map<String, dynamic>> addAjustement(String creanceId, Map<String, dynamic> body) =>
      _api.post('/creances/$creanceId/ajustements', body: body).then(_asMap);

  Future<Map<String, dynamic>> decideAjustement(
    String id, {
    required bool ok,
    required String motif,
  }) =>
      _api
          .post(
            '/ajustements/$id/decision',
            body: <String, dynamic>{'ok': ok, 'motif': motif},
          )
          .then(_asMap);

  Future<Map<String, dynamic>> executeRelances() =>
      _api.post('/regles/execution').then(_asMap);

  Future<Map<String, dynamic>> exportComptable() =>
      _api.post('/exports/comptables').then(_asMap);

  Future<Map<String, dynamic>> saveReversement(
    String mandantId,
    String mois,
    String statut,
  ) =>
      _api
          .put(
            '/reversements/$mandantId/$mois',
            body: <String, dynamic>{'statut': statut},
          )
          .then(_asMap);

  /* ------------------------------------------------------------------ *
   * Paiements et encaissements
   * ------------------------------------------------------------------ */

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> body) =>
      _api.post('/transactions', body: body).then(_asMap);

  Future<Map<String, dynamic>> rejectTransaction(String id, String motif) => _api
      .post('/transactions/$id/rejet', body: <String, dynamic>{'motif': motif})
      .then(_asMap);

  Future<Map<String, dynamic>> identifyTransaction(String id, String debiteurId) => _api
      .post('/transactions/$id/identification', body: <String, dynamic>{'debiteurId': debiteurId})
      .then(_asMap);

  Future<Map<String, dynamic>> allocateTransaction(String id, Map<String, dynamic> body) =>
      _api.post('/transactions/$id/affectations', body: body).then(_asMap);

  Future<dynamic> autoRapprochement() => _api.post('/rapprochements/auto');

  /* ------------------------------------------------------------------ *
   * Portails
   * ------------------------------------------------------------------ */

  Future<Map<String, dynamic>> portalPayment(String creanceId, Map<String, dynamic> body) =>
      _api.post('/creances/$creanceId/paiement-portail', body: body).then(_asMap);

  Future<Map<String, dynamic>> portalProof(String creanceId, Map<String, dynamic> body) =>
      _api.post('/creances/$creanceId/justificatif-portail', body: body).then(_asMap);

  /* ------------------------------------------------------------------ *
   * Contentieux
   * ------------------------------------------------------------------ */

  Future<List<dynamic>> getActes({
    int? page,
    int? size,
    String? statut,
    String? type,
  }) {
    final query = <String, String>{
      if (page != null) 'page': '$page',
      'size': '${size ?? 1000}',
      if (statut != null && statut.isNotEmpty) 'statut': statut,
      if (type != null && type.isNotEmpty) 'type': type,
    };
    return _api.get('/actes-contentieux', query: query).then(_asList);
  }

  Future<Map<String, dynamic>> createActe(String creanceId, String type) => _api
      .post(
        '/creances/$creanceId/actes-contentieux',
        body: <String, dynamic>{'type': type},
      )
      .then(_asMap);

  Future<Map<String, dynamic>> createFichePoursuites(String acteId) =>
      _api.post('/actes-contentieux/$acteId/fiche-poursuites').then(_asMap);

  Future<Map<String, dynamic>> visaFichePoursuites(
    String acteId, {
    required String decision,
    String? motif,
  }) =>
      _api
          .post(
            '/actes-contentieux/$acteId/fiche-poursuites/visa',
            body: <String, dynamic>{'decision': decision, 'motif': motif},
          )
          .then(_asMap);

  Future<Map<String, dynamic>> enregistrerAccuseReception(String acteId) =>
      _api.post('/actes-contentieux/$acteId/accuse-reception').then(_asMap);

  Future<Map<String, dynamic>> enregistrerSuite(String acteId, Map<String, dynamic> body) =>
      _api.post('/actes-contentieux/$acteId/suite', body: body).then(_asMap);

  Future<Map<String, dynamic>> visaSuite(
    String acteId, {
    required String decision,
    String? motif,
  }) =>
      _api
          .post(
            '/actes-contentieux/$acteId/suite/visa',
            body: <String, dynamic>{'decision': decision, 'motif': motif},
          )
          .then(_asMap);

  Future<dynamic> getContentieuxParametres() =>
      _api.get('/contentieux/parametres');

  Future<List<dynamic>> getCircuitsContentieux() =>
      _api.get('/contentieux/circuits').then(_asList);

  /* ------------------------------------------------------------------ *
   * Documents / GED
   * ------------------------------------------------------------------ */

  Future<List<dynamic>> getDocumentsFiltres(Map<String, String> query) =>
      _api.get('/documents', query: query).then(_asList);

  Future<Map<String, dynamic>> createDocument(Map<String, dynamic> body) =>
      _api.post('/documents', body: body).then(_asMap);

  Future<Map<String, dynamic>> addDocumentVersion(
    String id,
    Map<String, dynamic> body,
  ) =>
      _api.post('/documents/$id/versions', body: body).then(_asMap);

  Future<String> getDocumentContenu(String id) => _api.getText(
        '/documents/$id/contenu',
        accept: 'application/octet-stream',
      );

  Future<List<dynamic>> getDocumentTypes() =>
      _api.get('/documents/types').then(_asList);

  Future<List<dynamic>> getDocumentNiveaux() =>
      _api.get('/documents/niveaux').then(_asList);

  /* ------------------------------------------------------------------ *
   * Administration, mandants, profils
   * ------------------------------------------------------------------ */

  Future<Map<String, dynamic>> saveParametresMetier(Map<String, dynamic> body) =>
      _api.put('/admin/parametres-metier', body: body).then(_asMap);

  Future<List<dynamic>> getIntegrations() =>
      _api.get('/admin/integrations').then(_asList);

  Future<Map<String, dynamic>> createMandant(Map<String, dynamic> body) =>
      _api.post('/mandants', body: body).then(_asMap);

  Future<Map<String, dynamic>> updateMandant(String id, Map<String, dynamic> body) =>
      _api.put('/mandants/$id', body: body).then(_asMap);

  Future<Map<String, dynamic>> setMandantStatut(String id, bool actif) => _api
      .put('/mandants/$id/statut', body: <String, dynamic>{'actif': actif})
      .then(_asMap);

  Future<dynamic> deleteMandant(String id) => _api.delete('/mandants/$id');

  Future<Map<String, dynamic>> saveProfil(Map<String, dynamic> body) =>
      (body['code'] == null || body['code'].toString().isEmpty)
          ? _api.post('/admin/profils', body: body).then(_asMap)
          : _api.put('/admin/profils/${body['code']}', body: body).then(_asMap);

  Future<dynamic> deleteProfil(String code) => _api.delete('/admin/profils/$code');

  /* ------------------------------------------------------------------ *
   * Authentification — mot de passe oublié / réinitialisation
   * ------------------------------------------------------------------ */

  Future<String> forgotPassword(String login) => _api.getText(
        '/auth/forgot-password',
        query: <String, String>{'login': login},
        accept: 'application/json',
      );

  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> body) => _api
      .post(
        '/auth/signin-with-forget-password-url-connexion',
        body: body,
      )
      .then(_asMap);

  Future<Map<String, dynamic>> resetPasswordInit(Map<String, dynamic> body) => _api
      .post(
        '/auth/signin-with-url-connexion',
        body: body,
      )
      .then(_asMap);
}
