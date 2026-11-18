abstract class AuthTokens {
  Future<String?> get accessToken;

  Future<bool> refresh();

  Future<void> signOut();
}
