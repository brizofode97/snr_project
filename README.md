# SNR 360 Mobile

Application Flutter de recouvrement des créances. Les backends et le frontend web ne sont pas modifiés par ce projet.

## Configuration Keycloak

Le mobile utilise le flux **Authorization Code + PKCE** via `flutter_appauth`.

- Realm : `Gestion-recouvrement-creances-snr`
- Client public : `gestion-recouvrement-creances`
- Scopes : `openid profile email roles offline_access`
- URI de connexion à enregistrer dans le client Keycloak : `snr360://auth`
- Endpoint utilisateur : `GET /auth/me`

Le script `keycloak/start-local.ps1` du frontend n'enregistre que `http://localhost:4200/*` comme URI autorisée. Avant la première connexion mobile, ajouter `snr360://auth` dans **Valid redirect URIs** du client `gestion-recouvrement-creances`.

Si le realm a déjà été importé, modifier le client depuis la console Keycloak ou via l'API admin : le script ne met pas à jour un realm existant. Une erreur `Paramètre invalide : redirect_uri` signifie exactement que cette URI n'est pas enregistrée.

Ne pas remplacer l'URI de post-logout du web par `snr360://logout` : cette version de Keycloak refuse de mélanger une URI HTTP avec un scheme custom dans la même liste. Le mobile efface toujours sa session localement même si la déconnexion Keycloak distante échoue.

Les tokens sont stockés avec `flutter_secure_storage` (`kc_access_token`, `kc_refresh_token`, `kc_id_token`, `kc_expires_at`, `kc_user`). Le client API ajoute automatiquement `Authorization: Bearer <token>` et relance une requête unique après refresh sur un 401.

## Lancement

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Sous Windows, `flutter pub get` peut demander d'activer le **Developer Mode** pour les symlinks des plugins :

```powershell
start ms-settings:developers
```

## Dépannage de la connexion Keycloak

`discovery_failed / Network error` signifie que le mobile n'atteint pas le serveur Keycloak. Les deux URL doivent utiliser le même hôte que Keycloak :

- `KEYCLOAK_ISSUER` : l'issuer officiel validé par le backend, `http://localhost:8081/realms/Gestion-recouvrement-creances-snr`.
- `KEYCLOAK_BASE_URL` : par défaut l'origine de l'issuer, donc `http://localhost:8081`. Sur un appareil physique, la remplacer par l'IP LAN de la machine et démarrer Keycloak avec ce même hostname.

Ne pas utiliser `10.0.2.2` pour `KEYCLOAK_BASE_URL` : l'autorisation serait ouverte sur `10.0.2.2` alors que le formulaire Keycloak posterait sur `localhost`, ce qui fait perdre le cookie `KC_RESTART` (« Cookie de redémarrage de la connexion non trouvé »).

Sur l'émulateur Android, rediriger le `localhost` de l'émulateur vers la machine hôte :

```powershell
adb reverse tcp:8081 tcp:8081
```

Sans cette commande, la page de login ou sa soumission échoue avec `localhost refused to connect`. À réexécuter après chaque redémarrage de l'émulateur. Le simulateur iOS utilise déjà `localhost` et n'a pas besoin de cette commande.

Le mobile transmet explicitement les endpoints `auth`, `token` et `logout` à `flutter_appauth` via `serviceConfiguration` : la découverte OIDC n'est donc plus faite à partir de l'issuer, tout en gardant des jetons dont l'issuer reste `localhost` pour le backend.

Vérifier que Keycloak tourne réellement sur la machine (le port `8081` doit répondre) :

```powershell
Invoke-RestMethod -Uri 'http://localhost:8081/realms/Gestion-recouvrement-creances-snr/.well-known/openid-configuration' |
  Select-Object issuer, authorization_endpoint, token_endpoint
```

Si le port n'est pas ouvert, démarrer le Keycloak local depuis le dépôt frontend :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\keycloak\start-local.ps1
```

Le script frontend écoute sur `127.0.0.1:8081` ; avec `adb reverse`, le `localhost` de l'émulateur pointe dessus. Vérifier aussi que le firewall Windows autorise le port `8081`.

## Variables d'environnement

Les valeurs par défaut ciblent l'émulateur Android et un Keycloak/API en HTTP local :

| Variable | Défaut |
|---|---|
| `API_BASE_URL` | `http://10.0.2.2:8089/factory-starter-kit-api-v4` |
| `KEYCLOAK_ISSUER` | `http://localhost:8081/realms/Gestion-recouvrement-creances-snr` |
| `KEYCLOAK_BASE_URL` | `http://localhost:8081` |
| `KEYCLOAK_CLIENT_ID` | `gestion-recouvrement-creances` |
| `KEYCLOAK_REDIRECT_URI` | `snr360://auth` |
| `KEYCLOAK_POST_LOGOUT_REDIRECT_URI` | `snr360://logout` |

Simulateur iOS : aucun `dart-define` nécessaire, les valeurs par défaut utilisent déjà `localhost`.

Appareil physique ou autre hôte (remplacer `192.168.1.10` par l'IP de la machine) :

```powershell
flutter run ^
  --dart-define=API_BASE_URL=http://192.168.1.10:8089/factory-starter-kit-api-v4 ^
  --dart-define=KEYCLOAK_BASE_URL=http://192.168.1.10:8081 ^
  --dart-define=KEYCLOAK_ISSUER=http://192.168.1.10:8081/realms/Gestion-recouvrement-creances-snr
```

Dans ce dernier cas, aligner aussi `KEYCLOAK_ISSUER_URI` du backend sur la même IP. En production, utilisez HTTPS : les autorisations cleartext Android/iOS sont uniquement là pour le développement local.

## API utilisées

Toutes les données passent par `lib/data/snr_repository.dart` et `lib/data/api/creances_api_service.dart` : créances, débiteurs, échéanciers, transactions, reversements, tâches, promesses, documents, attestations, actes contentieux, utilisateurs, messages, audit et contrôles administratifs.

Deux écrans n'ont pas d'endpoint backend dédié et dérivent donc les données réelles disponibles :

- `Rapports` : catalogue local ; l'export appelle réellement `GET /creances/export`.
- `Patrimoine` : garanties lues depuis `Creance.garanties` (aucun endpoint `/biens` n'existe côté backend).

## Tests

`flutter test` couvre :

- le redirect vers l'écran Keycloak quand la session est vide ;
- le header Bearer, le déballage du payload, le refresh 401 et les erreurs `ApiException` ;
- le mapping des DTO utilisateur, reversement et transaction.
