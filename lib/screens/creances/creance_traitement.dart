import 'package:material_ui/material_ui.dart';

import '../../data/api/creances_api_service.dart';
import '../../data/snr_repository.dart';
import 'traitement_form_dialog.dart';

const List<String> typesAction = <String>[
  'Appel',
  'Relance',
  'Visite',
  'Courrier',
  'E-mail',
  'Réunion',
];

const List<String> resultatsAction = <String>[
  'Joignable',
  'Pas de réponse',
  'Engagement de paiement',
  'Refus de payer',
  'Déménagé',
  'Dossier contesté',
];

const List<String> typesPiece = <String>[
  'Contrat',
  'Facture',
  'Relevé de compte',
  'Pièce d’identité',
  'Preuve de paiement',
  'Courrier',
  'Autre',
];

const List<String> modelesCourrier = <String>[
  'Lettre de relance amiable',
  'Proposition d’échéancier',
  'Confirmation d’accord',
  'Accusé de réception de contestation',
  'Mise en demeure (projet soumis au juridique)',
];

const List<String> canauxEnvoi = <String>[
  'Courrier postal',
  'E-mail',
  'Remise en main propre',
  'Huissier',
];

const List<String> typesAttestation = <String>[
  'Attestation de situation',
  'Attestation de paiement',
  'Attestation de solde (mainlevée)',
];

const List<String> typesActe = <String>[
  'Mise en demeure',
  'Commandement de payer',
  'Contrainte',
  'Avis à tiers détenteur',
  'Saisie',
  'Vente',
  'Opposition',
];

const List<String> composantesAjustement = <String>[
  'principal',
  'interets',
  'frais',
];

const List<String> frequencesEcheancier = <String>[
  'Mensuelle',
  'Bimensuelle',
  'Trimestrielle',
  'Hebdomadaire',
];

String _entier(String value) => (int.tryParse(value.replaceAll(RegExp(r'\D'), '')) ?? 0).toString();

String? _dateOuNull(String value) => value.trim().isEmpty ? null : value.trim();

Future<bool?> enregistrerActionCreance(
  BuildContext context,
  String creanceId,
) =>
    showTraitementDialog(
      context: context,
      title: 'Enregistrer une action',
      champs: const [
        ChampFormulaire('type', 'Type d’action', TypeChamp.liste,
            options: typesAction, obligatoire: true),
        ChampFormulaire('resultat', 'Résultat', TypeChamp.liste,
            options: resultatsAction, obligatoire: true),
        ChampFormulaire('compteRendu', 'Compte rendu', TypeChamp.zoneTexte,
            obligatoire: true),
        ChampFormulaire('nextLabel', 'Prochaine action', TypeChamp.texte),
        ChampFormulaire('nextDate', 'Date de la prochaine action', TypeChamp.date),
      ],
      onSoumettre: (values) => SnrRepository.instance.enregistrerAction(creanceId, {
        'type': values['type'] ?? '',
        'resultat': values['resultat'] ?? '',
        'compteRendu': values['compteRendu'] ?? '',
        'nextLabel': values['nextLabel'] ?? '',
        'nextDate': _dateOuNull(values['nextDate'] ?? ''),
      }),
    );

Future<bool?> joindrePieceCreance(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Joindre une pièce',
      champs: const [
        ChampFormulaire('type', 'Type de pièce', TypeChamp.liste,
            options: typesPiece, obligatoire: true),
        ChampFormulaire('titre', 'Titre de la pièce', TypeChamp.texte,
            obligatoire: true),
      ],
      onSoumettre: (values) => SnrRepository.instance.joindrePiece(
        creanceId,
        type: values['type'] ?? '',
        titre: values['titre'] ?? '',
      ),
    );

Future<bool?> corrigerCreanceDialog(
  BuildContext context,
  String creanceId,
) =>
    showTraitementDialog(
      context: context,
      title: 'Corriger la saisie',
      champs: const [
        ChampFormulaire('motif', 'Motif de la correction', TypeChamp.zoneTexte,
            obligatoire: true),
      ],
      onSoumettre: (values) => SnrRepository.instance.rejeterCreance(
        creanceId,
        values['motif'] ?? '',
      ),
    );

Future<bool?> soumettreCreanceDialog(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Soumettre à validation',
      description:
          'La créance sera transmise au service de contrôle pour validation.',
      champs: const [],
      labelBouton: 'Soumettre',
      onSoumettre: (_) => SnrRepository.instance.soumettreCreance(creanceId),
    );

Future<bool?> validerCreanceDialog(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Valider la créance',
      champs: const [],
      labelBouton: 'Valider',
      onSoumettre: (_) => SnrRepository.instance.validerCreance(creanceId),
    );

Future<bool?> rejeterCreanceDialog(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Renvoyer au contrôle',
      champs: const [
        ChampFormulaire('motif', 'Motif du renvoi', TypeChamp.zoneTexte,
            obligatoire: true),
      ],
      onSoumettre: (values) =>
          SnrRepository.instance.rejeterCreance(creanceId, values['motif'] ?? ''),
    );

Future<bool?> affecterCreanceDialog(
  BuildContext context,
  String creanceId, {
  List<dynamic>? acteurs,
}) async {
  final repo = SnrRepository.instance;
  final agents = acteurs ?? await CreancesApiService.instance.getActeurs();
  final options = <String>[
    for (final acteur in agents)
      if (acteur is Map &&
          (acteur['role'] ?? acteur['profil'] ?? '').toString().toUpperCase() == 'AGENT')
        (acteur['id'] ?? '').toString(),
  ];
  if (options.isEmpty) {
    for (final acteur in agents) {
      if (acteur is Map && (acteur['id'] ?? '').toString().isNotEmpty) {
        options.add((acteur['id'] ?? '').toString());
      }
    }
  }
  if (options.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun agent disponible pour l’affectation.')),
      );
    }
    return false;
  }
  if (!context.mounted) return false;
  return showTraitementDialog(
    context: context,
    title: 'Affecter à un agent',
    champs: [
      ChampFormulaire('agentId', 'Agent', TypeChamp.liste,
          options: options, obligatoire: true),
      const ChampFormulaire('motif', 'Motif de l’affectation', TypeChamp.zoneTexte),
    ],
    onSoumettre: (values) => repo.affecterCreance(
      creanceId,
      agentId: values['agentId'] ?? '',
      motif: values['motif'] ?? '',
    ),
  );
}

Future<bool?> enregistrerPromesseDialog(
  BuildContext context,
  String creanceId,
) =>
    showTraitementDialog(
      context: context,
      title: 'Enregistrer une promesse',
      champs: const [
        ChampFormulaire('montant', 'Montant promis', TypeChamp.nombre,
            obligatoire: true),
        ChampFormulaire('date', 'Date prévue', TypeChamp.date, obligatoire: true),
      ],
      onSoumettre: (values) => SnrRepository.instance.enregistrerPromesse(creanceId, {
        'montant': int.tryParse(_entier(values['montant'] ?? '')) ?? 0,
        'date': _dateOuNull(values['date'] ?? ''),
      }),
    );

Future<bool?> enregistrerCourrierDialog(
  BuildContext context,
  String creanceId,
) =>
    showTraitementDialog(
      context: context,
      title: 'Générer un courrier',
      champs: [
        ChampFormulaire('modele', 'Modèle', TypeChamp.liste,
            options: modelesCourrier, obligatoire: true),
        const ChampFormulaire('contenu', 'Texte du courrier', TypeChamp.zoneTexte),
        ChampFormulaire('canal', 'Canal d’envoi', TypeChamp.liste,
            options: canauxEnvoi, obligatoire: true),
      ],
      onSoumettre: (values) async {
        final repo = SnrRepository.instance;
        final result = await repo.enregistrerCourrier(creanceId, {
          'modele': values['modele'] ?? '',
        });
        final cree = result['cree']?.toString() ??
            (result['piece'] is Map ? (result['piece'] as Map)['id']?.toString() : null);
        if (cree != null && cree.isNotEmpty && (values['contenu'] ?? '').isNotEmpty) {
          await repo.modifierCourrier(creanceId, cree, {
            'contenu': values['contenu'],
          });
        }
        if (values['canal'] != null && values['canal']!.isNotEmpty) {
          await CreancesApiService.instance.sendCourrier(
            creanceId,
            cree ?? '',
            values['canal']!,
          );
        }
      },
    );

Future<bool?> enregistrerAjustementDialog(
  BuildContext context,
  String creanceId,
) =>
    showTraitementDialog(
      context: context,
      title: 'Proposer un ajustement',
      champs: [
        ChampFormulaire('composante', 'Composante', TypeChamp.liste,
            options: composantesAjustement, obligatoire: true),
        const ChampFormulaire('montant', 'Montant (positif ou négatif)',
            TypeChamp.nombre, obligatoire: true),
        const ChampFormulaire('motif', 'Motif', TypeChamp.zoneTexte,
            obligatoire: true),
      ],
      onSoumettre: (values) => SnrRepository.instance.ajouterAjustement(creanceId, {
        'composante': values['composante'] ?? 'principal',
        'montant': int.tryParse(values['montant'] ?? '') ?? 0,
        'motif': values['motif'] ?? '',
      }),
    );

Future<bool?> creerEcheancierDialog(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Proposer un échéancier',
      champs: [
        const ChampFormulaire('montant', 'Montant total à échelonner',
            TypeChamp.nombre, obligatoire: true),
        const ChampFormulaire('acompte', 'Acompte', TypeChamp.nombre),
        const ChampFormulaire('acompteDate', 'Date de l’acompte', TypeChamp.date),
        const ChampFormulaire('nb', 'Nombre d’échéances', TypeChamp.nombre,
            obligatoire: true),
        ChampFormulaire('frequence', 'Fréquence', TypeChamp.liste,
            options: frequencesEcheancier, obligatoire: true),
        const ChampFormulaire('premiere', 'Première échéance', TypeChamp.date,
            obligatoire: true),
        const ChampFormulaire('conditions', 'Conditions', TypeChamp.zoneTexte),
      ],
      onSoumettre: (values) => SnrRepository.instance.creerEcheancier({
        'creanceId': creanceId,
        'montant': int.tryParse(_entier(values['montant'] ?? '')) ?? 0,
        'acompte': int.tryParse(_entier(values['acompte'] ?? '')) ?? 0,
        'acompteDate': _dateOuNull(values['acompteDate'] ?? ''),
        'nb': int.tryParse(_entier(values['nb'] ?? '')) ?? 1,
        'frequence': values['frequence'] ?? 'Mensuelle',
        'premiere': _dateOuNull(values['premiere'] ?? ''),
        'conditions': values['conditions'] ?? '',
        'acceptation': '',
        'motifRevision': '',
      }),
    );

Future<bool?> contesterCreanceDialog(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Contester la créance',
      champs: const [
        ChampFormulaire('motif', 'Motif de la contestation', TypeChamp.zoneTexte,
            obligatoire: true),
      ],
      onSoumettre: (values) =>
          SnrRepository.instance.contesterCreance(creanceId, values['motif'] ?? ''),
    );

Future<bool?> demanderClotureDialog(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Demander la clôture',
      champs: const [
        ChampFormulaire('motif', 'Motif de la clôture', TypeChamp.zoneTexte,
            obligatoire: true),
      ],
      onSoumettre: (values) =>
          SnrRepository.instance.demanderCloture(creanceId, values['motif'] ?? ''),
    );

Future<bool?> reouvrirCreanceDialog(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Réouvrir le dossier',
      champs: const [
        ChampFormulaire('motif', 'Motif de la réouverture', TypeChamp.zoneTexte,
            obligatoire: true),
      ],
      onSoumettre: (values) =>
          SnrRepository.instance.reouvrirCreance(creanceId, values['motif'] ?? ''),
    );

Future<bool?> demanderAttestationDialog(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Demander une attestation',
      champs: [
        ChampFormulaire('type', 'Type d’attestation', TypeChamp.liste,
            options: typesAttestation, obligatoire: true),
      ],
      onSoumettre: (values) => SnrRepository.instance.demanderAttestation(
        creanceId,
        values['type'] ?? typesAttestation.first,
      ),
    );

Future<bool?> ouvrirActeContentieuxDialog(
  BuildContext context,
  String creanceId,
) =>
    showTraitementDialog(
      context: context,
      title: 'Ouvrir un acte contentieux',
      champs: [
        ChampFormulaire('type', 'Type d’acte', TypeChamp.liste,
            options: typesActe, obligatoire: true),
      ],
      onSoumettre: (values) => SnrRepository.instance.creerActe(
        creanceId,
        values['type'] ?? typesActe.first,
      ),
    );

Future<bool?> enregistrerPaiementDialog(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Saisir un paiement',
      champs: [
        ChampFormulaire('canal', 'Canal', TypeChamp.liste,
            options: const <String>[
              'Virement bancaire',
              'Mobile money',
              'Chèque',
              'Versement guichet banque',
              'Paiement en ligne (carte)',
            ],
            obligatoire: true),
        const ChampFormulaire('montant', 'Montant', TypeChamp.nombre,
            obligatoire: true),
        const ChampFormulaire('date', 'Date du paiement', TypeChamp.date,
            obligatoire: true),
        const ChampFormulaire('reference', 'Référence', TypeChamp.texte),
        const ChampFormulaire('payeur', 'Payeur', TypeChamp.texte),
        const ChampFormulaire('note', 'Note', TypeChamp.zoneTexte),
      ],
      onSoumettre: (values) => SnrRepository.instance.enregistrerTransaction({
        'creanceId': creanceId,
        'canal': values['canal'] ?? '',
        'montant': int.tryParse(_entier(values['montant'] ?? '')) ?? 0,
        'date': _dateOuNull(values['date'] ?? ''),
        'reference': values['reference'] ?? '',
        'payeur': values['payeur'] ?? '',
        'note': values['note'] ?? '',
      }),
    );

Future<bool?> planifierActionDialog(BuildContext context, String creanceId) =>
    showTraitementDialog(
      context: context,
      title: 'Planifier une action',
      champs: const [
        ChampFormulaire('type', 'Type', TypeChamp.liste,
            options: typesAction, obligatoire: true),
        ChampFormulaire('date', 'Date', TypeChamp.date, obligatoire: true),
        ChampFormulaire('label', 'Objet', TypeChamp.texte, obligatoire: true),
      ],
      onSoumettre: (values) => SnrRepository.instance.planifierAction(
        creanceId,
        type: values['type'] ?? 'Appel',
        date: _dateOuNull(values['date'] ?? ''),
        label: values['label'] ?? '',
      ),
    );
