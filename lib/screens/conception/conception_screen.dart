import 'package:material_ui/material_ui.dart';

class _DocSection {
  final String id;
  final String label;
  final List<String> paragraphs;
  final Map<String, List<String>> lists;
  final Map<String, List<List<String>>> tables;
  final Map<String, String> code;

  const _DocSection({
    required this.id,
    required this.label,
    this.paragraphs = const <String>[],
    this.lists = const <String, List<String>>{},
    this.tables = const <String, List<List<String>>>{},
    this.code = const <String, String>{},
  });
}

const List<_DocSection> _sections = <_DocSection>[
  _DocSection(
    id: 'perimetre',
    label: 'Périmètre et objectifs',
    paragraphs: [
      'SNR 360 gère le cycle de vie complet d\'une créance confiée à la Société Nationale de Recouvrement : enregistrement, contrôle, validation, affectation, recouvrement amiable, accord et échéancier, encaissements et rapprochement, contentieux, clôture validée.',
      'La solution couvre aussi les garanties et le patrimoine de la SNR, et offre deux portails externes (débiteurs et mandants).',
    ],
    lists: {
      'Objectifs': [
        'Centraliser créances, débiteurs, documents, garanties et historiques.',
        'Organiser le travail des agents : file de travail, prochaines actions, tâches automatiques.',
        'Faciliter les négociations et le suivi des échéanciers.',
        'Tracer les encaissements, leur confirmation et leur rapprochement comptable.',
        'Suivre les procédures contentieuses et leurs échéances.',
        'Offrir un espace sécurisé aux débiteurs et aux mandants.',
        'Donner à la direction une vision actualisée, avec des indicateurs définis.',
        'Réduire les doubles saisies et les dossiers sans suivi.',
      ],
    },
  ),
  _DocSection(
    id: 'modules',
    label: 'Organisation des modules',
    tables: {
      'Modules': [
        ['Pilotage', 'Tableau de bord direction, validations, rapports', 'DG, responsable recouvrement, comptable, auditeur'],
        ['Débiteurs', 'Fiche PP/PM, identifiants, historique, doublons et fusion validée', 'Agents, responsables'],
        ['Créances', 'Enregistrement, import contrôlé, validation, affectation, ajustements', 'Agents, responsable recouvrement'],
        ['Recouvrement amiable', 'Appels, relances, courriers, promesses, tâches automatiques', 'Agents'],
        ['Échéanciers et accords', 'Construction, validation, preuve d’acceptation, versions', 'Agents, responsable'],
        ['Paiements et comptabilité', 'Saisie, confirmation, rapprochement, ventilation, export, reversements', 'Comptables, responsable'],
        ['Contentieux', 'Dossier juridique, actes, audiences, phases validées, alertes', 'Juristes, responsable juridique'],
        ['Garanties et patrimoine', 'Biens SNR, garanties, évaluations, locations, cessions', 'Gestionnaire patrimoine, DG'],
        ['Portail débiteur', 'Consultation, solde, échéancier, paiement, contestation, messages', 'Débiteurs'],
        ['Portail mandant', 'Transmission de portefeuille, suivi, reversements, rapports, échanges', 'Organismes mandants'],
        ['Administration', 'Utilisateurs, droits, paramètres, intégrations, audit, contrôles', 'Administrateur, auditeur'],
      ],
    },
    lists: {
      'Écrans prioritaires réalisés': [
        'Connexion et tableau de bord de la direction.',
        'Liste des créances (filtres, tri, pagination, export, import).',
        'Fiche détaillée d’une créance (statuts séparés, parcours, onglets).',
        'Espace de travail de l’agent.',
        'Création et validation d’un échéancier.',
        'Encaissements et rapprochement.',
        'Suivi contentieux, garanties et patrimoine.',
        'Portails débiteur et mandant, rapports, administration.',
      ],
    },
  ),
  _DocSection(
    id: 'parcours',
    label: 'Parcours et statuts',
    paragraphs: [
      'Parcours de référence : import ou création → contrôle des données et pièces → validation → affectation → prise de contact → proposition d’accord → validation de l’échéancier → suivi des paiements → rapprochement comptable → contrôle du solde → clôture validée.',
      'Trois dimensions indépendantes sont affichées côte à côte sur chaque dossier pour éviter les statuts ambigus.',
    ],
    tables: {
      'Dimensions': [
        ['Phase de recouvrement', 'Enregistrement · Contrôle · Validation · Affectation · Prise de contact · Négociation · Accord · Contentieux · Clôture demandée · Clôturée', 'Transitions contrôlées par l’API'],
        ['Situation de paiement', 'Aucun paiement · Paiement partiel · Soldée', 'Calculée depuis les affectations confirmées'],
        ['Contestation', 'Aucune · En cours · Acceptée · Rejetée', 'Décision juridique ou responsable'],
        ['Ligne d’échéance', 'À venir · Partielle · Réglée · En retard · Partielle — en retard', 'Calculée par imputation chronologique'],
        ['Transaction', 'Justificatif déposé · En attente · Confirmé · Non identifié · Rejeté', 'Confirmation humaine et rapprochement'],
      ],
      'Branches prévues': [
        ['Contestation', 'Agent ou portail débiteur', 'Relances suspendues, tâche au juriste, décision motivée'],
        ['Paiement partiel', 'Affectation inférieure à l’échéance', 'Ligne partielle, reste dû visible, relance'],
        ['Échéance non respectée', 'Date + tolérance dépassée', 'Tâche automatique unique, alerte tableau de bord'],
        ['Révision de l’accord', 'Demande du débiteur ou de l’agent', 'Nouvelle version, ancienne conservée'],
        ['Passage au contentieux', 'Échec de l’amiable', 'Demande motivée puis validation juridique'],
        ['Paiement non identifié', 'Payeur sans référence', 'File non identifié, identification puis ventilation'],
        ['Réouverture motivée', 'Élément nouveau après clôture', 'Réservée au responsable, motif obligatoire'],
      ],
    },
  ),
  _DocSection(
    id: 'donnees',
    label: 'Modèle de données',
    paragraphs: [
      'Modèle relationnel PostgreSQL. Les montants sont stockés en entiers (FCFA, sans décimale) avec la devise ; toutes les tables métier portent created_at, created_by et version (verrou optimiste).',
      'Les tables d’événements, d’affectations et d’audit sont en ajout seul.',
    ],
    tables: {
      'Entités principales': [
        ['Debiteur', 'id, type, nom, identifiants, téléphone, courriel, ville, fusion', '1—n Creance, Document'],
        ['Mandant / Portefeuille', 'id, sigle, nom, référence mandat, périmètre', '1—n Creance'],
        ['Creance', 'référence, débiteur, mandant, nature, dates, montants, phase, état', '1—n Ajustement, Echeancier, Evenement'],
        ['Echeancier', 'version, montant, acompte, nb, fréquence, statut, preuve', '1—n LigneEcheance'],
        ['Transaction', 'référence normalisée, canal, date, montant, statut', '1—n Affectation'],
        ['DossierJuridique', 'référence, procédure, juridiction, phase, actes, frais', '1—1 Creance'],
        ['Bien', 'nature, catégorie, propriétaire, évaluations, location, cession', 'n—n Creance'],
        ['Document / Attestation', 'type, titre, version, confidentialité, empreinte', 'n—1 dossier'],
        ['JournalAudit', 'horodatage, utilisateur, action, objet, empreinte chaînée', 'append-only'],
      ],
    },
    code: {
      'Contraintes clés': '''
CREATE UNIQUE INDEX ux_transaction_ref ON transaction (canal_source, reference_normalisee)
  WHERE statut <> 'REJETE';
CREATE UNIQUE INDEX ux_echeancier_actif ON echeancier (creance_id) WHERE statut = 'VALIDE';
ALTER TABLE affectation ADD CONSTRAINT ck_aff_montant CHECK (montant > 0);
CREATE UNIQUE INDEX ux_tache_cle ON tache (cle_idempotence) WHERE cle_idempotence IS NOT NULL;
ALTER TABLE echeancier ADD CONSTRAINT ck_4yeux
  CHECK (valide_par IS NULL OR valide_par <> prepare_par);''',
    },
  ),
  _DocSection(
    id: 'regles',
    label: 'Règles métier et hypothèses',
    lists: {
      'Règles implémentées': [
        'R1 — Solde = principal + intérêts + frais + ajustements validés − affectations confirmées. Le solde ne peut pas être négatif.',
        'R2 — Aucune donnée financière n’est écrasée : toute correction passe par un ajustement motivé validé par une autre personne.',
        'R3 — Un justificatif ou un paiement saisi n’a aucun effet sur le solde avant confirmation comptable.',
        'R4 — La référence de transaction normalisée est unique : la double comptabilisation est bloquée.',
        'R5 — La ventilation ne peut dépasser ni le montant disponible ni le solde de chaque créance.',
        'R6 — Un encaissement exporté en comptabilité est verrouillé.',
        'R7 — Imputation des paiements sur les lignes d’échéancier par ordre chronologique.',
        'R8 — Retard d’échéance ou promesse non tenue crée une tâche unique (clé d’idempotence).',
        'R9 — Une contestation suspend les relances et bloque le passage au contentieux.',
        'R10 — Validation d’un échéancier : preuve d’acceptation et montant ≤ solde courant.',
        'R11 — Clôture : solde nul, aucun paiement en attente, aucune contestation ni ajustement en attente.',
        'R12 — Réouverture réservée au responsable et motivée.',
        'R13 — Passage au contentieux et actes préparés puis validés par le juridique.',
        'R14 — Assistant IA en lecture seule, avec citations et contrôle des droits.',
        'R15 — Cloisonnement par portefeuille, affectation, mandat et débiteur.',
      ],
      'Hypothèses à valider avec la SNR': [
        'Ordre d’imputation des paiements (frais → intérêts → principal).',
        'Calcul et capitalisation des intérêts de retard.',
        'Délai de tolérance de 5 jours et seuil d’inactivité de 30 jours.',
        'Procédures, délais et intitulés juridiques.',
        'Taux de commission, frais refacturables et fréquence des reversements.',
        'Pièces obligatoires pour valider une créance.',
        'Seuils d’approbation des remises.',
        'Durées de conservation des documents et données personnelles.',
        'Canaux de paiement et conventions bancaires.',
        'Format de l’export comptable et plan de comptes.',
      ],
      'Formules des indicateurs': [
        'Taux de recouvrement = recouvré / dû.',
        'Solde courant = montant initial + ajustements validés − encaissements confirmés.',
        'Ancienneté moyenne = somme des anciennetés / nombre de créances ouvertes.',
        'Taux de promesses tenues = promesses tenues / promesses échues.',
      ],
    },
  ),
  _DocSection(
    id: 'archi',
    label: 'Architecture technique',
    paragraphs: [
      'Monolithe modulaire Spring Boot (Java 21), un module par domaine, frontières explicites (packages publics / internes, événements applicatifs en mémoire).',
      'Une messagerie asynchrone ne sera ajoutée que si les volumes d’intégration bancaire ou d’import le justifient.',
    ],
    code: {
      'Arborescence cible': '''
snr360/
├── backend/            Spring Boot 3, Java 21
│   ├── snr-app/        démarrage, configuration, sécurité Keycloak
│   ├── module-referentiel, module-creance, module-amiable
│   ├── module-echeancier, module-paiement, module-juridique
│   ├── module-patrimoine, module-document, module-ia
│   └── module-portail, module-audit
├── frontend/           Angular 21, PrimeNG 21
├── db/migrations/      Flyway
└── deploy/             docker-compose.yml''',
      'Docker Compose': '''
services:
  postgres:  { image: postgres:16, volumes: [pgdata:/var/lib/postgresql/data] }
  keycloak:  { image: quay.io/keycloak/keycloak:25.0, command: start --optimized }
  minio:     { image: minio/minio, command: server /data --console-address ":9001" }
  backend:   { build: ./backend, depends_on: [postgres, keycloak, minio] }
  frontend:  { build: ./frontend, ports: ["443:443"] }''',
    },
  ),
  _DocSection(
    id: 'api',
    label: 'API REST',
    paragraphs: [
      'API documentée en OpenAPI 3 (springdoc). Erreurs au format RFC 7807, messages métier en français. Toutes les écritures financières acceptent un en-tête Idempotency-Key.',
    ],
    tables: {
      'Endpoints (extrait)': [
        ['GET', '/api/creances?phase=&mandant=&agent=&page=', 'Liste filtrée et paginée'],
        ['POST', '/api/creances', 'Création contrôlée'],
        ['POST', '/api/creances/{id}/validation', 'Validation (4 yeux)'],
        ['PUT', '/api/creances/{id}/affectation', 'Affectation / réaffectation'],
        ['POST', '/api/creances/{id}/actions', 'Appel, relance, compte rendu'],
        ['POST', '/api/ajustements/{id}/decision', 'Validation ou rejet d’ajustement'],
        ['POST', '/api/echeanciers', 'Soumission d’une version'],
        ['POST', '/api/transactions', 'Saisie (Idempotency-Key)'],
        ['POST', '/api/rapprochements/auto', 'Rapprochement automatique'],
        ['POST', '/api/exports/comptables', 'Génération d’un lot tracé'],
        ['POST', '/api/creances/{id}/cloture/decision', 'Validation / refus de clôture'],
        ['GET', '/api/public/attestations/{code}', 'Vérification publique minimale'],
      ],
    },
  ),
  _DocSection(
    id: 'securite',
    label: 'Sécurité et fiabilité',
    lists: {
      'Contrôles': [
        'Contrôle des droits côté serveur : rôle et périmètre vérifiés dans chaque service.',
        'Authentification renforcée (OTP/TOTP) pour les profils sensibles, sessions courtes.',
        'Chiffrement TLS 1.2+ et chiffrement au repos des volumes et objets MinIO.',
        'Journal d’audit protégé : ajout seul, chaînage par empreinte, copie non modifiable.',
        'Documents : URL signées courtes, niveau Restreint pour les pièces sensibles.',
        'Exports réservés aux profils autorisés et tracés.',
        'Secrets dans un coffre, jamais dans le code ni les images.',
        'Paiements : clé d’unicité, idempotence des webhooks, transactions sérialisables.',
        'Sauvegardes PostgreSQL quotidiennes + WAL, restauration testée chaque trimestre.',
        'Portails séparés du back-office, DTO restreints, limitation de débit.',
      ],
    },
    code: {
      'Ports d’intégration':
          'BankStatementPort, PaymentGatewayPort, DocumentStoragePort, NotificationPort, AccountingExportPort, AiAssistantPort, SignaturePort',
    },
  ),
  _DocSection(
    id: 'roadmap',
    label: 'Feuille de route',
    lists: {
      'MVP — 5 à 6 mois (estimation à affiner)': [
        'Socle : Keycloak, rôles, périmètres, audit, GED MinIO, paramétrage.',
        'Référentiels débiteurs, mandants, mandats, portefeuilles ; import contrôlé.',
        'Créances : contrôle, validation, affectation, ajustements.',
        'Amiable : file de travail, actions, relances, courriers, promesses.',
        'Échéanciers et circuit de validation.',
        'Paiements : saisie, confirmation, rapprochement, ventilation, export.',
        'Clôture validée et réouverture.',
        'Tableau de bord direction et 5 rapports.',
        'Portail débiteur (consultation, justificatif, messages, demandes).',
      ],
      'Extensions': [
        'Connecteurs bancaires et paiement en ligne.',
        'Portail mandant complet et reporting automatisé.',
        'Module contentieux complet.',
        'Patrimoine : gestion locative, cessions, SIG.',
        'Assistant IA : extraction OCR, résumés, Q/R avec citations.',
        'Signature électronique et QR code sur attestations.',
        'Notifications SMS / courriel.',
        'Application mobile agents de terrain (mode hors ligne).',
      ],
      'Prochaines étapes proposées': [
        'Ateliers de validation des règles (imputation, délais juridiques, seuils, conservation).',
        'Inventaire des conventions bancaires et du format comptable.',
        'Reprise des données existantes : échantillon réel anonymisé pour tester l’import.',
        'Maquettes validées → développement par lots de 2 semaines avec recette SNR.',
      ],
    },
  ),
  _DocSection(
    id: 'execution',
    label: 'Exécution',
    lists: {
      'Environnement': [
        'Les données fictives sont conservées dans le navigateur et réinitialisables dans Administration.',
        'La date de situation est fixée au 25/09/2026 pour que les retards et indicateurs restent cohérents.',
        'Le profil de démonstration se change depuis le menu du profil.',
        'Authentification : mode demo, legacy (API actuelle) ou keycloak (SSO cible).',
        'L’import Excel utilise SheetJS ; le CSV est lu directement.',
        'Les exports sont affichés à l’écran et téléchargeables.',
      ],
    },
    code: {
      'Commandes': '''npm install
npm start                    # http://localhost:4200
docker compose -f deploy/docker-compose.yml up -d postgres keycloak minio
./backend/mvnw -pl snr-app spring-boot:run''',
    },
  ),
  _DocSection(
    id: 'verif',
    label: 'Vérifications et scénarios',
    lists: {
      'Contrôles automatiques': [
        'Unicité des références de créances et de transactions.',
        'Cohérence des soldes et des montants d’échéanciers.',
        'Présence des pièces obligatoires avant validation.',
        'Séparation des fonctions sur validations financières.',
        'Cohérence des périmètres utilisateurs.',
        'Chaînage du journal d’audit.',
      ],
      'Scénarios de démonstration': [
        'Parcours complet : valider une créance importée, l’affecter, proposer un échéancier, joindre la preuve et valider.',
        'Paiement partiel et retard : échéance partielle et tâche automatique.',
        'Doublon de transaction : blocage de la seconde saisie.',
        'Justificatif ≠ encaissement : confirmation puis ventilation.',
        'Paiement non identifié : identification puis ventilation.',
        'Rapprochement et promesse : rapprochement automatique.',
        'Clôture : validation par une autre personne que le demandeur.',
        'Contestation : suspension des relances et blocage du contentieux.',
      ],
    },
  ),
];

class ConceptionScreen extends StatefulWidget {
  const ConceptionScreen({super.key});

  @override
  State<ConceptionScreen> createState() => _ConceptionScreenState();
}

class _ConceptionScreenState extends State<ConceptionScreen> {
  String _section = _sections.first.id;

  _DocSection get _courante => _sections.firstWhere(
        (section) => section.id == _section,
        orElse: () => _sections.first,
      );

  @override
  Widget build(BuildContext context) {
    final section = _courante;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dossier de conception'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _section = value),
            itemBuilder: (context) => [
              for (final item in _sections)
                PopupMenuItem<String>(value: item.id, child: Text(item.label)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final item = _sections[index];
                return ChoiceChip(
                  label: Text(item.label),
                  selected: item.id == _section,
                  onSelected: (_) => setState(() => _section = item.id),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.label,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Organisation, modèle de données, règles, architecture, sécurité, intégrations et feuille de route de SNR 360.',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                for (final paragraph in section.paragraphs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(paragraph, style: const TextStyle(fontSize: 14, height: 1.45)),
                  ),
                for (final entry in section.tables.entries) _buildTable(entry.key, entry.value),
                for (final entry in section.lists.entries) _buildList(entry.key, entry.value),
                for (final entry in section.code.entries) _buildCode(entry.key, entry.value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(String title, List<List<String>> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                columns: [
                  for (final header in rows.first)
                    DataColumn(label: Text(header, style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: [
                  for (final row in rows.skip(1))
                    DataRow(
                      cells: [
                        for (final cell in row)
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 260),
                              child: Text(cell, style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.chevron_right, size: 16),
                    const SizedBox(width: 4),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 13, height: 1.35))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCode(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  content,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
