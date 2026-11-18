List<String> _stringList(dynamic value) => value is List
    ? value.map((e) => e.toString()).toList()
    : const <String>[];

class CurrentUser {
  final String id;
  final String username;
  final String? prenom;
  final String? nom;
  final String? email;
  final String profil;
  final List<String> roles;
  final List<String> permissions;
  final List<String> portefeuilles;
  final String? mandantId;
  final String? debiteurId;

  const CurrentUser({
    required this.id,
    required this.username,
    this.prenom,
    this.nom,
    this.email,
    required this.profil,
    this.roles = const <String>[],
    this.permissions = const <String>[],
    this.portefeuilles = const <String>[],
    this.mandantId,
    this.debiteurId,
  });

  String get displayName {
    final name = <String>[
      if (prenom != null && prenom!.isNotEmpty) prenom!,
      if (nom != null && nom!.isNotEmpty) nom!,
    ].join(' ');
    return name.isEmpty ? username : name;
  }

  bool hasPermission(String permission) => permissions.contains(permission);

  factory CurrentUser.fromApi(Map<String, dynamic> m) => CurrentUser(
        id: (m['id'] ?? '').toString(),
        username: (m['username'] ?? '').toString(),
        prenom: m['prenom']?.toString(),
        nom: m['nom']?.toString(),
        email: m['email']?.toString(),
        profil: (m['profil'] ?? '').toString(),
        roles: _stringList(m['roles']),
        permissions: _stringList(m['permissions']),
        portefeuilles: _stringList(m['portefeuilles']),
        mandantId: m['mandantId']?.toString(),
        debiteurId: m['debiteurId']?.toString(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'username': username,
        'prenom': prenom,
        'nom': nom,
        'email': email,
        'profil': profil,
        'roles': roles,
        'permissions': permissions,
        'portefeuilles': portefeuilles,
        'mandantId': mandantId,
        'debiteurId': debiteurId,
      };
}
