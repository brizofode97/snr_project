import '../../core/network/api_client.dart';

class CreancesApiService {
  CreancesApiService._();
  static final CreancesApiService instance = CreancesApiService._();
  final _api = ApiClient.instance;

  Future<List<dynamic>> getCreances() async {
    final data = await _api.get('/creances', query: {'size': '1000'});
    return (data as List?)?.toList() ?? const [];
  }

  Future<Map<String, dynamic>> getCreance(String id) async {
    final data = await _api.get('/creances/$id');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<dynamic>> getDebiteurs() async {
    final data = await _api.get('/debiteurs');
    return (data as List?)?.toList() ?? const [];
  }

  Future<List<dynamic>> getEvenements([String? creanceId]) async {
    final data = await _api.get(creanceId == null ? '/evenements' : '/creances/$creanceId/evenements');
    return (data as List?)?.toList() ?? const [];
  }

  Future<List<dynamic>> getTaches() async {
    final data = await _api.get('/taches');
    return (data as List?)?.toList() ?? const [];
  }

  Future<List<dynamic>> getPieces() async {
    final data = await _api.get('/pieces');
    return (data as List?)?.toList() ?? const [];
  }

  Future<List<dynamic>> getEcheanciers() async {
    final data = await _api.get('/echeanciers');
    return (data as List?)?.toList() ?? const [];
  }

  Future<List<dynamic>> getTransactions() async {
    final data = await _api.get('/transactions');
    return (data as List?)?.toList() ?? const [];
  }

  Future<Map<String, dynamic>> me() async {
    final data = await _api.get('/auth/me');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<String> exportCsv() => _api.getText('/creances/export');
}
