import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/auth/auth_service.dart';
import 'menu.dart';
import '../screens/accueil/accueil_screen.dart';
import '../screens/administration/administration_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/agent/agent_espace_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/conception/conception_screen.dart';
import '../screens/contentieux/acte_detail_screen.dart';
import '../screens/contentieux/contentieux_list_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/debiteurs/debiteur_detail_screen.dart';
import '../screens/debiteurs/debiteurs_list_screen.dart';
import '../screens/documents/attestation_detail_screen.dart';
import '../screens/documents/document_detail_screen.dart';
import '../screens/documents/documents_screen.dart';
import '../screens/echeanciers/echeancier_detail_screen.dart';
import '../screens/echeanciers/echeanciers_screen.dart';
import '../screens/encaissements/encaissements_screen.dart';
import '../screens/encaissements/reversements_screen.dart';
import '../screens/encaissements/transaction_detail_screen.dart';
import '../screens/creances/creance_detail_screen.dart';
import '../screens/creances/creance_form_screen.dart';
import '../screens/creances/creances_list_screen.dart';
import '../screens/echanges/echanges_screen.dart';
import '../screens/home/home_hub_screen.dart';
import '../screens/mandants/mandants_screen.dart';
import '../screens/patrimoine/bien_detail_screen.dart';
import '../screens/profils/profils_screen.dart';
import '../screens/patrimoine/patrimoine_list_screen.dart';
import '../screens/portail_debiteur/portail_debiteur_screen.dart';
import '../screens/portail_mandant/portail_mandant_screen.dart';
import '../screens/rapports/rapports_screen.dart';
import '../screens/utilisateurs/nouvel_utilisateur_screen.dart';
import '../screens/utilisateurs/utilisateur_detail_screen.dart';
import '../screens/utilisateurs/utilisateurs_list_screen.dart';
import '../screens/validations/validations_screen.dart';
import 'app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: AuthService.instance.session,
  redirect: (context, state) {
    final connecte = AuthService.instance.isAuthenticated;
    final location = state.matchedLocation;
    final estPublic = location == '/' ||
        location == '/login' ||
        location == '/forgot-password' ||
        location == '/reset-password';
    if (!connecte && !estPublic) return '/login';
    if (connecte && estPublic) return '/home';
    if (connecte && !peutAccederChemin(AuthService.instance.currentUser, location)) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AccueilScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => ResetPasswordScreen(
        token: state.uri.queryParameters['token'],
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(path: state.matchedLocation, child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeHubScreen()),
        GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
        GoRoute(path: '/creances', builder: (context, state) => const CreancesListScreen()),
        GoRoute(
          path: '/creances/nouvelle',
          builder: (context, state) => const CreanceFormScreen(),
        ),
        GoRoute(
          path: '/creances/:id/edit',
          builder: (context, state) =>
              CreanceFormScreen(creanceId: state.pathParameters['id']),
        ),
        GoRoute(path: '/debiteurs', builder: (context, state) => const DebiteursListScreen()),
        GoRoute(path: '/echeanciers', builder: (context, state) => const EcheanciersScreen()),
        GoRoute(path: '/encaissements', builder: (context, state) => const EncaissementsScreen()),
        GoRoute(path: '/reversements', builder: (context, state) => const ReversementsScreen()),
        GoRoute(path: '/contentieux', builder: (context, state) => const ContentieuxListScreen()),
        GoRoute(path: '/patrimoine', builder: (context, state) => const PatrimoineListScreen()),
        GoRoute(path: '/documents', builder: (context, state) => const DocumentsScreen()),
        GoRoute(path: '/agent', builder: (context, state) => const AgentEspaceScreen()),
        GoRoute(path: '/validations', builder: (context, state) => const ValidationsScreen()),
        GoRoute(path: '/rapports', builder: (context, state) => const RapportsScreen()),
        GoRoute(path: '/administration', builder: (context, state) => const AdministrationScreen()),
        GoRoute(path: '/utilisateurs', builder: (context, state) => const UtilisateursListScreen()),
        GoRoute(path: '/profils', builder: (context, state) => const ProfilsScreen()),
        GoRoute(path: '/mandants', builder: (context, state) => const MandantsScreen()),
        GoRoute(path: '/portail-debiteur', builder: (context, state) => const PortailDebiteurScreen()),
        GoRoute(path: '/portail-mandant', builder: (context, state) => const PortailMandantScreen()),
        GoRoute(path: '/echanges', builder: (context, state) => const EchangesScreen()),
        GoRoute(path: '/conception', builder: (context, state) => const ConceptionScreen()),
      ],
    ),
    GoRoute(
      path: '/creances/:id',
      builder: (context, state) => CreanceDetailScreen(creanceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/debiteurs/:id',
      builder: (context, state) => DebiteurDetailScreen(debiteurId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/echeanciers/:id',
      builder: (context, state) => EcheancierDetailScreen(echeancierId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/encaissements/:id',
      builder: (context, state) => TransactionDetailScreen(transactionId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/contentieux/:id',
      builder: (context, state) => ActeDetailScreen(acteId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/patrimoine/:id',
      builder: (context, state) => BienDetailScreen(bienId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/documents/:id',
      builder: (context, state) => DocumentDetailScreen(documentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/attestations/:id',
      builder: (context, state) => AttestationDetailScreen(attestationId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/utilisateurs/nouveau',
      builder: (context, state) => const NouvelUtilisateurScreen(),
    ),
    GoRoute(
      path: '/utilisateurs/:id',
      builder: (context, state) => UtilisateurDetailScreen(utilisateurId: state.pathParameters['id']!),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page introuvable')),
    body: Center(child: Text('Aucune page pour ${state.uri}')),
  ),
);
