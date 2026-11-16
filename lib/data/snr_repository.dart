import '../models/creance.dart';
import '../models/debiteur.dart';
import '../models/echeancier.dart';
import '../models/transaction.dart';
import 'api/creances_api_service.dart';

class SnrRepository {
  SnrRepository._();
  static final SnrRepository instance = SnrRepository._();
  final _api = CreancesApiService.instance;

  List<Creance> _creances = [];
  List<Debiteur> _debiteurs = [];
  List<Echeancier> _echeanciers = [];
  List<Transaction> _transactions = [];

  List<Creance> get creances => _creances;
  List<Debiteur> get debiteurs => _debiteurs;
  List<Echeancier> get echeanciers => _echeanciers;
  List<Transaction> get transactions => _transactions;

  Future<void> refreshAll() async {
    final results = await Future.wait([
      _api.getCreances(),
      _api.getDebiteurs(),
      _api.getEcheanciers().catchError((_) => <dynamic>[]),
      _api.getTransactions().catchError((_) => <dynamic>[]),
    ]);
    _creances = (results[0] as List)
        .whereType<Map>()
        .map((e) => Creance.fromApi(Map<String, dynamic>.from(e)))
        .toList();
    _debiteurs = (results[1] as List)
        .whereType<Map>()
        .map((e) => Debiteur.fromApi(Map<String, dynamic>.from(e)))
        .toList();
    _echeanciers = (results[2] as List)
        .whereType<Map>()
        .map((e) => Echeancier.fromApi(Map<String, dynamic>.from(e)))
        .toList();
    _transactions = (results[3] as List)
        .whereType<Map>()
        .map((e) => Transaction.fromApi(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Creance> fetchCreance(String id) async {
    final map = await _api.getCreance(id);
    final c = Creance.fromApi(map);
    final idx = _creances.indexWhere((x) => x.id == c.id);
    if (idx >= 0) {
      _creances[idx] = c;
    } else {
      _creances.add(c);
    }
    return c;
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

  List<Creance> creancesDuDebiteur(String debiteurId) =>
      _creances.where((c) => c.debiteurId == debiteurId).toList();

  Echeancier? echeancierParCreanceId(String creanceId) {
    for (final e in _echeanciers) {
      if (e.creanceId == creanceId) return e;
    }
    return null;
  }
}
