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
    final data = await _api.get('/creances', query: <String, String>{
      'size': '1000',
      ...?query,
    });
    return _asList(data);
  }

  Future<Map<String, dynamic>> getCreance(String id) =>
      _api.get('/creances/$id').then(_asMap);

  Future<List<dynamic>> getEvenements(String creanceId) =>
      _api.get('/creances/$creanceId/evenements').then(_asList);

  Future<Map<String, dynamic>> getSolde(String creanceId) =>
      _api.get('/creances/$creanceId/solde').then(_asMap);

  Future<String> exportCsv() => _api.getText('/creances/export');

  Future<List<dynamic>> getDebiteurs() =>
      _api.get('/debiteurs').then(_asList);

  Future<Map<String, dynamic>> getDebiteur(String id) =>
      _api.get('/debiteurs/$id').then(_asMap);

  Future<Map<String, dynamic>> setDebiteurAcces(String id, bool actif) =>
      _api.put('/debiteurs/$id/acces', body: <String, dynamic>{'actif': actif}).then(_asMap);

  Future<List<dynamic>> getMandants() => _api.get('/mandants').then(_asList);

  Future<List<dynamic>> getPortefeuilles() =>
      _api.get('/portefeuilles').then(_asList);

  Future<List<dynamic>> getActeurs() => _api.get('/acteurs').then(_asList);

  Future<List<dynamic>> getTaches({String? assignee}) => _api
      .get('/taches', query: assignee == null ? null : <String, String>{'assignee': assignee})
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
  }) =>
      _api.post('/echeanciers/$id/decision', body: <String, dynamic>{
        'ok': ok,
        'motif': motif,
      }).then(_asMap);

  Future<List<dynamic>> getTransactions() =>
      _api.get('/transactions').then(_asList);

  Future<Map<String, dynamic>> getTransaction(String id) =>
      _api.get('/transactions/$id').then(_asMap);

  Future<Map<String, dynamic>> confirmTransaction(String id, String bankRef) =>
      _api.post('/transactions/$id/confirmation', body: <String, dynamic>{
        'bankRef': bankRef,
      }).then(_asMap);

  Future<List<dynamic>> getReversements({String? mandant}) => _api
      .get('/reversements', query: mandant == null ? null : <String, String>{'mandant': mandant})
      .then(_asList);

  Future<List<dynamic>> getActesContentieux() =>
      _api.get('/actes-contentieux', query: const <String, String>{'size': '1000'})
          .then(_asList);

  Future<Map<String, dynamic>> getActeContentieux(String id) =>
      _api.get('/actes-contentieux/$id').then(_asMap);

  Future<Map<String, dynamic>> decideActe(
    String id, {
    required bool vise,
    String? motif,
  }) =>
      _api.post('/actes-contentieux/$id/visa', body: <String, dynamic>{
        'decision': vise ? 'VISE' : 'REJETE',
        'motif': motif,
      }).then(_asMap);

  Future<List<dynamic>> getDocuments() =>
      _api.get('/documents', query: const <String, String>{'size': '1000'})
          .then(_asList);

  Future<Map<String, dynamic>> getDocument(String id) =>
      _api.get('/documents/$id').then(_asMap);

  Future<List<dynamic>> getAttestations() =>
      _api.get('/attestations').then(_asList);

  Future<Map<String, dynamic>> decideAttestation(
    String id, {
    required bool ok,
    String? motif,
  }) =>
      _api.post('/attestations/$id/decision', body: <String, dynamic>{
        'ok': ok,
        'motif': motif,
      }).then(_asMap);

  Future<List<dynamic>> getUtilisateurs() =>
      _api.get('/utilisateurs', query: const <String, String>{'size': '1000'})
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
    return _api.get('/messages', query: query.isEmpty ? null : query).then(_asList);
  }

  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> body) =>
      _api.post('/messages', body: body).then(_asMap);

  Future<int> markMessagesRead({
    required String mandantId,
    required String debiteurId,
  }) async {
    final data = await _api.post('/messages/lu', body: <String, dynamic>{
      'mandantId': mandantId,
      'debiteurId': debiteurId,
    });
    return data is int ? data : int.tryParse(data?.toString() ?? '') ?? 0;
  }

  Future<List<dynamic>> getAdminControles() =>
      _api.get('/admin/controles').then(_asList);

  Future<List<dynamic>> getAudit() =>
      _api.get('/audit', query: const <String, String>{'size': '200'}).then(_asList);

  Future<Map<String, dynamic>> me() => _api.get('/auth/me').then(_asMap);
}
