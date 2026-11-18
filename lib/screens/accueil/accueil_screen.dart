import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/navigation_history.dart';
import '../../app/theme.dart';
import '../../core/auth/auth_service.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  bool _loading = false;
  String? _error;
  final GlobalKey _cycleKey = GlobalKey();

  static const List<_Chiffre> _chiffres = [
    _Chiffre('1991', 'Année de création de la SNR, par la loi 91-21'),
    _Chiffre('14', 'Modules dans un seul espace de travail'),
    _Chiffre('10', "Phases suivies, de l'enregistrement à la clôture"),
    _Chiffre('12', 'Profils, chacun avec ses droits et son périmètre'),
  ];

  static const List<_Espace> _espaces = [
    _Espace(
      Icons.person_outline,
      'Débiteurs',
      'Votre dossier, en toute clarté',
      [
        'Consulter le solde et l\'historique de vos paiements',
        'Payer en ligne ou déposer un justificatif',
        'Demander un échéancier adapté',
        'Imprimer vos reçus et demander vos attestations',
      ],
    ),
    _Espace(
      Icons.business_outlined,
      'Mandants',
      'Vos créances confiées, suivies au jour le jour',
      [
        'Suivre l\'avancement de chaque dossier',
        'Consulter les encaissements et reversements',
        'Recevoir un reporting fiable et tracé',
      ],
    ),
    _Espace(
      Icons.groups_outlined,
      'Équipes de la SNR',
      'Un espace de travail unique',
      [
        'Agents, responsables, juristes et comptables',
        'Contrôles à quatre yeux et journal d\'audit',
        'Procédures du Manuel intégrées, du contrôle au contentieux',
      ],
    ),
  ];

  static const List<_GroupeModules> _modules = [
    _GroupeModules(Icons.dashboard_outlined, 'Pilotage', [
      'Tableau de bord', 'Validations', 'Rapports',
    ]),
    _GroupeModules(Icons.description_outlined, 'Recouvrement', [
      'Espace agents', 'Créances', 'Débiteurs', 'Échéanciers et accords',
    ]),
    _GroupeModules(Icons.payments_outlined, 'Finance', ['Encaissements']),
    _GroupeModules(Icons.account_balance_outlined, 'Juridique', ['Contentieux']),
    _GroupeModules(Icons.folder_open_outlined, 'Documents', [
      'Documents et attestations',
    ]),
    _GroupeModules(Icons.settings_outlined, 'Système', [
      'Administration', 'Utilisateurs', 'Profils et rôles', 'Mandants',
    ]),
  ];

  static const List<String> _phases = [
    'Enregistrement',
    'Contrôle',
    'Validation',
    'Affectation',
    'Prise de contact',
    'Négociation',
    'Accord en vigueur',
    'Contentieux',
    'Clôture demandée',
    'Clôturée',
  ];

  static const List<_Profil> _profils = [
    _Profil('Administrateur technique', "Comptes, profils, paramètres et audit"),
    _Profil('Direction générale', 'Pilotage et arbitrages'),
    _Profil('Responsable du recouvrement', 'Valide, affecte et supervise'),
    _Profil('Agent de recouvrement', 'Traite les dossiers qui lui sont affectés'),
    _Profil('Responsable juridique', 'Valide les actes juridiques'),
    _Profil('Juriste', 'Prépare les actes du contentieux'),
    _Profil('Comptable', 'Confirme et ventile les encaissements'),
    _Profil('Gestionnaire du patrimoine', 'Gère garanties et patrimoine'),
    _Profil('Auditeur (lecture seule)', 'Contrôle, en lecture seule'),
    _Profil('Organisme mandant', "Suit les dossiers qu'il a confiés"),
    _Profil('Débiteur', 'Suit et règle son dossier en ligne'),
  ];

  static const List<_Info> _securite = [
    _Info(Icons.group_outlined, 'Séparation des fonctions',
        "Créance, échéancier, ajustement, clôture, encaissement : préparé par l'un, validé par un autre."),
    _Info(Icons.fact_check_outlined, "Journal d'audit chaîné",
        "Chaque opération est numérotée et chaînée à la précédente : toute retouche a posteriori se voit."),
    _Info(Icons.key_outlined, 'Authentification forte',
        "Code à usage unique exigé pour les profils sensibles, via l'annuaire Keycloak."),
    _Info(Icons.lock_outlined, 'Cloisonnement des dossiers',
        "Chacun ne voit que son périmètre ; un agent n'agit que sur les dossiers qui lui sont affectés."),
  ];

  static const List<_Info> _competences = [
    _Info(Icons.lock_open_outlined, 'Recouvrement des créances gelées',
        'Recouvrement des créances issues de la restructuration du secteur bancaire sénégalais.'),
    _Info(Icons.account_balance_wallet_outlined, 'Remboursement du passif gelé',
        'Prise en charge du remboursement des passifs gelés des banques concernées par la restructuration économique.'),
    _Info(Icons.shield_outlined, 'Privilège général',
        "Exercice du privilège général pour garantir et sécuriser les créances de l'État sénégalais."),
    _Info(Icons.home_outlined, 'Hypothèque légale',
        "Mise en œuvre de l'hypothèque légale pour la sécurisation des créances compromises des partenaires."),
    _Info(Icons.work_outline, 'Recouvrement mandaté',
        'Gestion des mandats de recouvrement confiés par les partenaires institutionnels et financiers.'),
    _Info(Icons.trending_up, 'Assainissement du secteur bancaire',
        "Contribution active à l'assainissement de l'environnement économique et financier national."),
  ];

  static const List<_Info> _etapes = [
    _Info(Icons.description_outlined, 'Fiche synoptique',
        "Document préliminaire établissant la situation financière complète du débiteur. Préalable indispensable à toute procédure de recouvrement."),
    _Info(Icons.handshake_outlined, 'Recouvrement amiable',
        "Procédure privilégiée : règlement par la négociation (échéancier, promesse, paiement en ligne), sans voie d'exécution judiciaire."),
    _Info(Icons.gavel_outlined, 'Recouvrement forcé',
        "Lorsque l'amiable échoue : mise en demeure, contrainte, avis à tiers détenteur (ATD), saisie-exécution et saisie immobilière."),
  ];

  static const List<String> _partenaires = [
    'Banque Islamique du Sénégal',
    "Banque Internationale de l'Afrique de l'Ouest",
    'La Banque Agricole du Sénégal',
    'BCEAO',
    'Port de Dakar',
  ];

  Future<void> _connecter() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signIn();
      navigationHistory.reset();
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _voirLeCycle() {
    final context = _cycleKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _entete(),
              _heros(),
              _chiffresSection(),
              _apropos(),
              _plateforme(),
              _modulesSection(),
              _cycleSection(),
              _profilsSection(),
              _securiteSection(),
              _competencesSection(),
              _recouvrementSection(),
              _partenairesSection(),
              _piedDePage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entete() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: snrPrimary,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: snrBrandGradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'SNR',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SNR 360',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Société Nationale de Recouvrement',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _loading ? null : _connecter,
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Se connecter'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _heros() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071730), snrGradientStart, Color(0xFF0C2A4A)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white24),
            ),
            child: const Text(
              'Société Nationale de Recouvrement · depuis 1991',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
              children: [
                TextSpan(text: 'Le recouvrement des créances publiques, '),
                TextSpan(
                  text: 'clair, suivi et transparent.',
                  style: TextStyle(color: snrAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'SNR 360 réunit débiteurs, mandants et équipes de la SNR sur une même plateforme : '
            'suivez votre dossier, payez en ligne, obtenez vos attestations et imprimez vos reçus, '
            'où que vous soyez.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Color(0xFFFFB4AB), fontSize: 13)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _connecter,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(_loading ? 'Redirection vers Keycloak…' : 'Accéder à mon espace'),
              style: FilledButton.styleFrom(
                backgroundColor: snrAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _voirLeCycle,
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Découvrir le parcours'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_outlined, color: snrAccent, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Sous la tutelle du Ministère des Finances et du Budget · Loi 91-21 du 16 février 1991",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chiffresSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.7,
        children: [
          for (final chiffre in _chiffres)
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FB),
                border: Border.all(color: const Color(0xFFDCE3EC)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(chiffre.valeur,
                        style: const TextStyle(
                            color: snrGradientStart, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(chiffre.libelle,
                        style: const TextStyle(color: Color(0xFF52627A), fontSize: 11)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _apropos() {
    return _section(
      scratch: true,
      children: [
        _etiquette('À propos de la SNR'),
        const Text(
          "Une institution d'État au service de l'assainissement financier",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 12),
        const Text(
          'La Société Nationale de Recouvrement est une société nationale placée sous la tutelle du '
          'Ministère des Finances et du Budget. Elle a été créée par la loi 91-21 du 16 février 1991, '
          'dans le cadre de la politique générale de restructuration de l’économie sénégalaise et du '
          'programme d’assainissement du secteur bancaire parapublic.',
          style: TextStyle(color: Color(0xFF52627A), fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDCE3EC)),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: const Text(
            '« Le recouvrement, notre credo. »',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        _infoCard(
          Icons.account_balance_wallet_outlined,
          'Remboursement du passif des banques',
          'La SNR se charge du remboursement des passifs gelés des banques concernées par la restructuration économique.',
        ),
        const SizedBox(height: 10),
        _infoCard(
          Icons.lock_open_outlined,
          'Recouvrement des créances gelées',
          'La SNR assure le recouvrement des créances gelées issues de la restructuration du secteur bancaire sénégalais.',
        ),
      ],
    );
  }

  Widget _plateforme() {
    return _section(
      color: const Color(0xFFEAF6F5),
      children: [
        _etiquette('La plateforme SNR 360'),
        const Text(
          'Un espace pour chacun, une seule source de vérité',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 10),
        const Text(
          'Chaque acteur retrouve ce qui le concerne, avec les mêmes informations à jour et chaque opération tracée.',
          style: TextStyle(color: Color(0xFF52627A), fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 18),
        for (final espace in _espaces) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(espace.icon, color: snrAccent, size: 28),
                  const SizedBox(height: 10),
                  Text(espace.titre,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text(espace.accroche,
                      style: const TextStyle(color: Color(0xFF52627A), fontSize: 13)),
                  const SizedBox(height: 10),
                  for (final point in espace.points) _puce(point),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _loading ? null : _connecter,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text('Accéder à l\'espace ${espace.titre.toLowerCase()}'),
                    style: TextButton.styleFrom(foregroundColor: snrAccent, padding: EdgeInsets.zero),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _modulesSection() {
    return _section(
      children: [
        _etiquette('Les modules'),
        const Text(
          'Tout le recouvrement, dans un seul espace de travail',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 10),
        const Text(
          'Du tableau de bord au contentieux, chaque profil retrouve les modules que ses droits lui ouvrent.',
          style: TextStyle(color: Color(0xFF52627A), fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 18),
        for (final groupe in _modules)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(groupe.icon, color: snrAccent),
                      const SizedBox(width: 10),
                      Text(groupe.titre,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final module in groupe.modules) _puce(module),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _cycleSection() {
    return _section(
      key: _cycleKey,
      color: const Color(0xFFEAF6F5),
      children: [
        _etiquette("Cycle de vie d'une créance"),
        const Text(
          'Chaque dossier suit le même chemin, visible de tous',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 10),
        const Text(
          'La plateforme indique à chaque étape ce qui reste à faire et qui doit le faire ; les validations passent par un second regard.',
          style: TextStyle(color: Color(0xFF52627A), fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < _phases.length; i++)
              Chip(
                avatar: CircleAvatar(
                  backgroundColor: i >= 7 ? snrPrimary : snrAccent,
                  child: Text('${i + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
                label: Text(_phases[i], style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Le contentieux n\'intervient qu\'en cas d\'échec du recouvrement amiable ; une créance clôturée peut être rouverte, sur décision motivée.',
          style: TextStyle(color: Color(0xFF52627A), fontSize: 12),
        ),
      ],
    );
  }

  Widget _profilsSection() {
    return _section(
      children: [
        _etiquette('Qui fait quoi'),
        const Text(
          'Un profil pour chaque métier',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 10),
        const Text(
          "Chaque compte porte un profil : ses droits et son périmètre sont appliqués par le serveur. L'administrateur peut créer de nouveaux profils.",
          style: TextStyle(color: Color(0xFF52627A), fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 16),
        for (final profil in _profils)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: snrPrimary,
                    child: Text(
                      profil.libelle.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profil.libelle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(profil.role,
                            style: const TextStyle(color: Color(0xFF52627A), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _securiteSection() {
    return _section(
      color: const Color(0xFF0C2A4A),
      foreground: Colors.white,
      children: [
        _etiquette('Sécurité et contrôle', claire: true),
        const Text(
          'Des fonds publics, des règles strictes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 10),
        const Text(
          'Les contrôles du Manuel de procédures sont appliqués par la plateforme elle-même, pas seulement affichés.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 18),
        for (final info in _securite) ...[
          _infoCard(info.icon, info.titre, info.texte, clair: true),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _competencesSection() {
    return _section(
      children: [
        _etiquette('Nos compétences'),
        const Text(
          'Acteur clé du recouvrement des créances publiques',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 10),
        const Text(
          'La Société Nationale de Recouvrement intervient dans six domaines stratégiques pour assurer sa mission institutionnelle.',
          style: TextStyle(color: Color(0xFF52627A), fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 18),
        for (final competence in _competences) ...[
          _infoCard(competence.icon, competence.titre, competence.texte),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _recouvrementSection() {
    return _section(
      color: const Color(0xFF0C2A4A),
      foreground: Colors.white,
      children: [
        _etiquette('Procédures de recouvrement', claire: true),
        const Text(
          'Une démarche structurée et progressive',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 10),
        const Text(
          'Le dialogue d\'abord : la voie judiciaire n\'intervient qu\'après l\'échec du recouvrement amiable.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 18),
        for (int i = 0; i < _etapes.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: snrAccent,
                child: Text('0${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_etapes[i].titre,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(_etapes[i].texte,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
          if (i < _etapes.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _partenairesSection() {
    return _section(
      children: [
        _etiquette('Nos partenaires'),
        const Text(
          'Ils nous font confiance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final partenaire in _partenaires)
              Chip(
                label: Text(partenaire, style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _piedDePage() {
    return Container(
      color: const Color(0xFF071730),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SNR 360',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 6),
          const Text(
            "Institution d'État créée par la loi 91-21 du 16 février 1991, placée sous la tutelle du Ministère des Finances et du Budget.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 10),
          const Text(
            '« Le recouvrement, notre credo. »',
            style: TextStyle(color: Color(0xFF5EEAD4), fontStyle: FontStyle.italic, fontSize: 13),
          ),
          const SizedBox(height: 18),
          const _Contact(Icons.place_outlined, '13, rue de Thann × Dagorne, Dakar · B.P. 319'),
          const SizedBox(height: 8),
          const _Contact(Icons.phone_outlined, '+221 33 889 34 86'),
          const SizedBox(height: 8),
          const _Contact(Icons.email_outlined, 'snr@snr.sn'),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            '© Société Nationale de Recouvrement du Sénégal',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _section({
    Key? key,
    Color? color,
    Color foreground = const Color(0xFF10223D),
    bool scratch = false,
    required List<Widget> children,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      color: color ?? (scratch ? Colors.white : const Color(0xFFF6F8FB)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: DefaultTextStyle(
        style: TextStyle(color: foreground),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _etiquette(String texte, {bool claire = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        texte.toUpperCase(),
        style: TextStyle(
          color: claire ? const Color(0xFF5EEAD4) : snrAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _puce(String texte) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: snrAccent, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texte, style: const TextStyle(fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String titre, String texte, {bool clair = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: clair ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        border: Border.all(
          color: clair ? Colors.white24 : const Color(0xFFDCE3EC),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: clair ? const Color(0xFF5EEAD4) : snrAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: clair ? Colors.white : const Color(0xFF10223D))),
                const SizedBox(height: 4),
                Text(
                  texte,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: clair ? Colors.white70 : const Color(0xFF52627A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chiffre {
  final String valeur;
  final String libelle;
  const _Chiffre(this.valeur, this.libelle);
}

class _Espace {
  final IconData icon;
  final String titre;
  final String accroche;
  final List<String> points;
  const _Espace(this.icon, this.titre, this.accroche, this.points);
}

class _GroupeModules {
  final IconData icon;
  final String titre;
  final List<String> modules;
  const _GroupeModules(this.icon, this.titre, this.modules);
}

class _Profil {
  final String libelle;
  final String role;
  const _Profil(this.libelle, this.role);
}

class _Info {
  final IconData icon;
  final String titre;
  final String texte;
  const _Info(this.icon, this.titre, this.texte);
}

class _Contact extends StatelessWidget {
  final IconData icon;
  final String texte;

  const _Contact(this.icon, this.texte);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF5EEAD4), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(texte, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ],
    );
  }
}
