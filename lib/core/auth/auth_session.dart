import '../../models/current_user.dart';

class AuthSession {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime? expiresAt;
  final CurrentUser user;

  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresAt,
    required this.user,
  });

  bool get isExpired => expiresAt == null
      ? false
      : !DateTime.now().add(const Duration(seconds: 30)).isBefore(expiresAt!);

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    String? idToken,
    DateTime? expiresAt,
    CurrentUser? user,
  }) =>
      AuthSession(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        idToken: idToken ?? this.idToken,
        expiresAt: expiresAt ?? this.expiresAt,
        user: user ?? this.user,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'idToken': idToken,
        'expiresAt': expiresAt?.toIso8601String(),
        'user': user.toJson(),
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: (json['accessToken'] ?? '').toString(),
        refreshToken: json['refreshToken']?.toString(),
        idToken: json['idToken']?.toString(),
        expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
        user: CurrentUser.fromApi(
          json['user'] is Map
              ? Map<String, dynamic>.from(json['user'] as Map)
              : <String, dynamic>{},
        ),
      );
}
