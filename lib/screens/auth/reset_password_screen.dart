import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _repo = SnrRepository.instance;
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  late final Map<String, dynamic>? _infos;
  late final bool _tokenValide;
  late final bool _expire;

  @override
  void initState() {
    super.initState();
    final payload = _decodeJwt(widget.token);
    _infos = payload?['infos'] is Map
        ? Map<String, dynamic>.from(payload!['infos'] as Map)
        : null;
    final exp = payload?['exp'];
    _expire = exp is num
        ? DateTime.fromMillisecondsSinceEpoch((exp * 1000).toInt())
            .isBefore(DateTime.now())
        : false;
    _tokenValide = _infos != null && !_expire;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _decodeJwt(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final value = jsonDecode(decoded);
      return value is Map ? Map<String, dynamic>.from(value) : null;
    } catch (_) {
      return null;
    }
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Le mot de passe est obligatoire';
    if (password.length < 8) return 'Au moins 8 caractères sont requis';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Une majuscule est requise';
    if (!RegExp(r'[a-z]').hasMatch(password)) return 'Une minuscule est requise';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Un chiffre est requis';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Un caractère spécial est requis';
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) return 'La confirmation est obligatoire';
    if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  Future<void> _soumettre() async {
    if (_validatePassword(_passwordController.text) != null ||
        _validateConfirmation(_confirmationController.text) != null) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final body = <String, dynamic>{
        'login': _infos?['login'] ?? '',
        'password': _infos?['password'] ?? '',
        'newPassword': _passwordController.text,
      };
      final action = (_infos?['action'] ?? '').toString();
      final result = action == 'FIRST_CONNEXION'
          ? await _repo.initialiserMotDePasse(body)
          : await _repo.reinitialiserMotDePasse(body);
      if (!mounted) return;
      final message = (result['message'] ??
              'Mot de passe réinitialisé. Vous pouvez vous connecter.')
          .toString();
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Réinitialisation'),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
              child: const Text('Se connecter'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Le serveur est inaccessible pour le moment : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _expire
        ? 'Lien expiré'
        : !_tokenValide
            ? 'Lien invalide'
            : 'Nouveau mot de passe';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [snrGradientStart, snrAccent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          _tokenValide ? Icons.password : Icons.error_outline,
                          size: 56,
                          color: snrGradientStart,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tokenValide
                              ? 'Choisissez un mot de passe conforme aux règles de sécurité.'
                              : 'Vous devez utiliser le lien envoyé par e-mail pour réinitialiser votre mot de passe.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_tokenValide) ...[
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            validator: _validatePassword,
                            decoration: InputDecoration(
                              labelText: 'Nouveau mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmationController,
                            obscureText: _obscure,
                            validator: _validateConfirmation,
                            decoration: const InputDecoration(
                              labelText: 'Confirmer le mot de passe',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _loading ? null : _soumettre,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check),
                            label: Text(_loading ? 'Enregistrement…' : 'Réinitialiser'),
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Retour à la connexion'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
