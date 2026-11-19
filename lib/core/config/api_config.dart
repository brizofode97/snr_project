class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8089/factory-starter-kit-api-v4',
  );

  static const String keycloakIssuer = String.fromEnvironment(
    'KEYCLOAK_ISSUER',
    defaultValue:
        'http://10.3.20.245:8081/realms/Gestion-recouvrement-creances-snr',
  );

  static const String _keycloakBaseOverride =
      String.fromEnvironment('KEYCLOAK_BASE_URL');

  static String get keycloakRealm {
    const marker = '/realms/';
    final index = keycloakIssuer.indexOf(marker);
    if (index < 0) return 'Gestion-recouvrement-creances-snr';
    final reste = keycloakIssuer.substring(index + marker.length);
    final fin = reste.indexOf('/');
    return fin < 0 ? reste : reste.substring(0, fin);
  }

  static String get keycloakBaseUrl {
    final override = _keycloakBaseOverride.trim();
    if (override.isNotEmpty) return override;
    final index = keycloakIssuer.indexOf('/realms/');
    return index < 0 ? keycloakIssuer : keycloakIssuer.substring(0, index);
  }

  static const String keycloakClientId = String.fromEnvironment(
    'KEYCLOAK_CLIENT_ID',
    defaultValue: 'gestion-recouvrement-creances',
  );

  static const String redirectUri = String.fromEnvironment(
    'KEYCLOAK_REDIRECT_URI',
    defaultValue: 'snr360://auth',
  );

  static const String postLogoutRedirectUri = String.fromEnvironment(
    'KEYCLOAK_POST_LOGOUT_REDIRECT_URI',
    defaultValue: 'snr360://auth',
  );

  static const List<String> scopes = <String>[
    'openid',
    'profile',
    'email',
    'roles',
  ];

  static bool get allowInsecureConnections =>
      keycloakBaseUrl.toLowerCase().startsWith('http://') ||
      keycloakIssuer.toLowerCase().startsWith('http://');

  /// Ancienne clé conservée uniquement pour migrer d'éventuels jetons legacy.
  static const String tokenKey = 'jwt_token';
}
