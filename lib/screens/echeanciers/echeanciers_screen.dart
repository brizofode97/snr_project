import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/echeancier.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/status_badge.dart';

class EcheanciersScreen extends StatefulWidget {
  const EcheanciersScreen({super.key});

  @override
  State<EcheanciersScreen> createState() => _EcheanciersScreenState();
}

class _EcheanciersScreenState extends State<EcheanciersScreen> {
  late Future<void> _future;
  final _repo = SnrRepository.instance;

  @override
  void initState() {
    super.initState();
    _future = _repo.echeanciers.isEmpty ? _repo.refreshAll() : Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Erreur de chargement des échéanciers.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        setState(() => _future = _repo.refreshAll()),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.primary,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'À valider'),
                    Tab(text: 'En vigueur'),
                    Tab(text: 'Historique'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _EcheancierListe(statuts: const [StatutEcheancier.soumis]),
                    _EcheancierListe(statuts: const [StatutEcheancier.valide]),
                    _EcheancierListe(
                      statuts: const [
                        StatutEcheancier.rejete,
                        StatutEcheancier.remplace,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EcheancierListe extends StatelessWidget {
  final List<StatutEcheancier> statuts;

  const _EcheancierListe({required this.statuts});

  Color _couleur(StatutEcheancier statut) {
    switch (statut) {
      case StatutEcheancier.soumis:
        return Colors.orange;
      case StatutEcheancier.valide:
        return Colors.green;
      case StatutEcheancier.rejete:
        return Colors.red;
      case StatutEcheancier.remplace:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liste = SnrRepository.instance.echeanciers
        .where((e) => statuts.contains(e.statut))
        .toList();
    if (liste.isEmpty) {
      return const EmptyPlaceholder(
        message: 'Aucun échéancier dans cette catégorie.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: liste.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final e = liste[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/echeanciers/${e.id}'),
            title: Text(e.debiteurNom),
            subtitle: Text(
              '${e.nombreEcheances} échéances · ${formatFcfa(e.montantTotal)}',
            ),
            trailing: StatusBadge(
              label: e.statut.libelle,
              color: _couleur(e.statut),
            ),
          ),
        );
      },
    );
  }
}
