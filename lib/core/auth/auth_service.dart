import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../../models/current_user.dart';
import 'auth_session.dart';
import 'auth_tokens.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService implements AuthTokens {
  AuthService({
    FlutterAppAuth? appAuth,
    FlutterSecureStorage? storage,
    http.Client? httpClient,
  })  : _appAuth = appAuth ?? const FlutterAppAuth(),
        _storage = storage ?? const FlutterSecureStorage(),
        _httpClient = httpClient ?? http.Client();

  static final AuthService instance = AuthService();

  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _storage;
  final http.Client _httpClient;

  static const String _accessKey = 'kc_access_token';
  static const String _refreshKey = 'kc_refresh_token';
  static const String _idKey = 'kc_id_token';
  static const String _expiresKey = 'kc_expires_at';
  static const String _userKey = 'kc_user';

  final ValueNotifier<AuthSession?> session = ValueNotifier<AuthSession?>(null);
  bool _restored = false;
  Future<bool>? _refreshing;

  bool get isAuthenticated => session.value != null;
  CurrentUser? get currentUser => session.value?.user;

  AuthorizationServiceConfiguration get _keycloakEndpoints {
    final base = '${ApiConfig.keycloakBaseUrl}/realms/${ApiConfig.keycloakRealm}'
        '/protocol/openid-connect';
    return AuthorizationServiceConfiguration(
      authorizationEndpoint: '$base/auth',
      tokenEndpoint: '$base/token',
      endSessionEndpoint: '$base/logout',
    );
  }

  @override
  Future<String?> get accessToken async => session.value?.accessToken;

  Future<void> restore() async {
    if (_restored) return;
    _restored = true;
    try {
      final access = await _read(_accessKey);
      if (access == null || access.isEmpty) return;
      final userMap = await _readJson(_userKey);
      final stored = AuthSession(
        accessToken: access,
        refreshToken: await _read(_refreshKey),
        idToken: await _read(_idKey),
        expiresAt: DateTime.tryParse(await _read(_expiresKey) ?? ''),
        user: CurrentUser.fromApi(userMap ?? const <String, dynamic>{}),
      );
      if (stored.isExpired && stored.refreshToken != null) {
        if (await refresh()) return;
      }
      session.value = stored;
    } catch (_) {
      await clearLocalSession();
    }
  }

  Future<AuthSession> signIn() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          ApiConfig.keycloakClientId,
          ApiConfig.redirectUri,
          issuer: ApiConfig.keycloakIssuer,
          serviceConfiguration: _keycloakEndpoints,
          scopes: ApiConfig.scopes,
          allowInsecureConnections: ApiConfig.allowInsecureConnections,
        ),
      );
      final access = result.accessToken;
      if (access == null || access.isEmpty) {
        throw const AuthException('Connexion Keycloak refusée.');
      }
      await _persistTokens(
        accessToken: access,
        refreshToken: result.refreshToken,
        idToken: result.idToken,
        expiresAt: result.accessTokenExpirationDateTime,
      );
      final user = await fetchMe(access);
      await _storeUser(user);
      return _setSession(
        accessToken: access,
        refreshToken: result.refreshToken,
        idToken: result.idToken,
        expiresAt: result.accessTokenExpirationDateTime,
        user: user,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(_readableError(e));
    }
  }

  @override
  Future<bool> refresh() {
    final pending = _refreshing;
    if (pending != null) return pending;
    final future = _refreshSession();
    _refreshing = future;
    return future.whenComplete(() => _refreshing = null);
  }

  Future<bool> _refreshSession() async {
    final refreshToken = session.value?.refreshToken ?? await _read(_refreshKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      await clearLocalSession();
      return false;
    }
    try {
      final result = await _appAuth.token(
        TokenRequest(
          ApiConfig.keycloakClientId,
          ApiConfig.redirectUri,
          refreshToken: refreshToken,
          issuer: ApiConfig.keycloakIssuer,
          serviceConfiguration: _keycloakEndpoints,
          scopes: ApiConfig.scopes,
          allowInsecureConnections: ApiConfig.allowInsecureConnections,
        ),
      );
      final access = result.accessToken;
      if (access == null || access.isEmpty) {
        throw const AuthException('Renouvellement de session refusé.');
      }
      final nextRefresh = result.refreshToken ?? refreshToken;
      final nextId = result.idToken ?? session.value?.idToken;
      final nextExpiry =
          result.accessTokenExpirationDateTime ?? session.value?.expiresAt;
      await _persistTokens(
        accessToken: access,
        refreshToken: nextRefresh,
        idToken: nextId,
        expiresAt: nextExpiry,
      );
      final user = session.value?.user ??
          CurrentUser.fromApi(await _readJson(_userKey) ?? const {});
      await _storeUser(user);
      _setSession(
        accessToken: access,
        refreshToken: nextRefresh,
        idToken: nextId,
        expiresAt: nextExpiry,
        user: user,
      );
      return true;
    } catch (_) {
      await clearLocalSession();
      return false;
    }
  }

  Future<CurrentUser> fetchMe(String accessToken) async {
    late final http.Response response;
    try {
      response = await _httpClient.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
    } catch (_) {
      throw const AuthException('API indisponible lors de la connexion.');
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AuthException(
        'Votre compte Keycloak n\'a aucun profil SNR autorisé.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthException('Erreur serveur (${response.statusCode})');
    }
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final status = decoded is Map ? decoded['status']?.toString() : null;
      if (status != null && status != 'OK' && status != '200') {
        throw AuthException(
          decoded['message']?.toString() ?? 'Connexion refusée par l\'API.',
        );
      }
      final payload = decoded is Map ? decoded['payload'] : null;
      if (payload is! Map) {
        throw const AuthException('Réponse utilisateur invalide.');
      }
      return CurrentUser.fromApi(Map<String, dynamic>.from(payload));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Réponse utilisateur invalide.');
    }
  }

  Future<void> logout() async {
    final idToken = session.value?.idToken ?? await _read(_idKey);
    await clearLocalSession();
    if (idToken != null && idToken.isNotEmpty) {
      unawaited(_endKeycloakSession(idToken));
    }
  }

  Future<void> _endKeycloakSession(String idToken) async {
    try {
      await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: ApiConfig.postLogoutRedirectUri,
          issuer: ApiConfig.keycloakIssuer,
          serviceConfiguration: _keycloakEndpoints,
          allowInsecureConnections: ApiConfig.allowInsecureConnections,
        ),
      );
    } catch (_) {
      // La déconnexion locale reste effective même si Keycloak est injoignable.
    }
  }

  @override
  Future<void> signOut() => clearLocalSession();

  Future<void> clearLocalSession() async {
    session.value = null;
    for (final key in [
      _accessKey,
      _refreshKey,
      _idKey,
      _expiresKey,
      _userKey,
    ]) {
      try {
        await _storage.delete(key: key);
      } catch (_) {
        // Stockage indisponible : la session en mémoire est déjà effacée.
      }
    }
  }

  AuthSession _setSession({
    required String accessToken,
    required String? refreshToken,
    required String? idToken,
    required DateTime? expiresAt,
    required CurrentUser user,
  }) {
    final next = AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      expiresAt: expiresAt,
      user: user,
    );
    session.value = next;
    return next;
  }

  Future<void> _persistTokens({
    required String accessToken,
    required String? refreshToken,
    required String? idToken,
    required DateTime? expiresAt,
  }) async {
    await _write(_accessKey, accessToken);
    await _write(_refreshKey, refreshToken);
    await _write(_idKey, idToken);
    await _write(_expiresKey, expiresAt?.toIso8601String());
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _readJson(String key) async {
    final raw = await _read(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, String? value) async {
    try {
      if (value == null || value.isEmpty) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(key: key, value: value);
      }
    } catch (_) {
      // Le fonctionnement en mémoire reste possible.
    }
  }

  Future<void> _storeUser(CurrentUser user) => _write(_userKey, jsonEncode(user.toJson()));

  String _readableError(Object error) {
    final text = error.toString();
    if (text.contains('UserCancelled') || text.contains('user_cancelled')) {
      return 'Connexion annulée.';
    }
    if (text.contains('invalid_grant')) {
      return 'Session Keycloak expirée, veuillez recommencer.';
    }
    return text.length > 160 ? text.substring(0, 160) : text;
  }
}
