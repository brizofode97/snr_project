import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/auth/auth_service.dart';
import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../data/snr_repository.dart';
import '../../models/creance.dart';
import '../../models/message_portail.dart';
import '../../models/transaction.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/status_badge.dart';

const List<RapportPredefini> _rapports = <RapportPredefini>[
  RapportPredefini(
    id: 'rap1',
    titre: 'Synthèse des encaissements',
    description: 'Évolution mensuelle des encaissements par mandant.',
    icone: 'bar_chart',
  ),
  RapportPredefini(
    id: 'rap2',
    titre: 'Vieillissement des créances',
    description: 'Répartition des créances par ancienneté et phase.',
    icone: 'hourglass_bottom',
  ),
  RapportPredefini(
    id: 'rap3',
    titre: 'Performance des agents',
    description: 'Montants recouvrés et dossiers traités par agent.',
    icone: 'leaderboard',
  ),
  RapportPredefini(
    id: 'rap4',
    titre: 'Suivi du contentieux',
    description: 'Actes en cours et délais à surveiller.',
    icone: 'gavel',
  ),
];

const Map<String, IconData> _icones = <String, IconData>{
  'bar_chart': Icons.bar_chart,
  'hourglass_bottom': Icons.hourglass_bottom,
  'leaderboard': Icons.leaderboard,
  'gavel': Icons.gavel,
};

class PortailMandantScreen extends StatefulWidget {
  const PortailMandantScreen({super.key});

  @override
  State<PortailMandantScreen> createState() => _PortailMandantScreenState();
}

class _PortailMandantScreenState extends State<PortailMandantScreen> {
  final _repo = SnrRepository.instance;
  late Future<void> _future;
  String _mandantId = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _load() async {
    await _repo.refreshAll();
    var id = AuthService.instance.currentUser?.mandantId;
    if (id == null || id.isEmpty) {
      for (final mandant in _repo.mandants) {
        if (mandant is Map) {
          final candidat = (mandant['id'] ?? mandant['mandantId'] ?? '').toString();
          if (candidat.isNotEmpty) {
            id = candidat;
            break;
          }
        }
      }
    }
    if (id == null || id.isEmpty) {
      if (_repo.creances.isNotEmpty) {
        id = _repo.creances.first.mandant;
      }
    }
    _mandantId = id ?? '';
    await _repo.refreshMessages(mandantId: _mandantId.isEmpty ? null : _mandantId);
  }

  List<Creance> _dossiers() =>
      _repo.creances.where((c) => c.mandant == _mandantId).toList();

  List<Reversement> _reversements() =>
      _repo.reversements.where((r) => r.mandant == _mandantId).toList();

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
              : 'Erreur de chargement du portail mandant.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(() => _future = _load()),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }
        final dossiers = _dossiers();
        final mandantNom = _mandantId.isEmpty ? 'Mandant' : _repo.mandantNom(_mandantId);
        return DefaultTabController(
          length: 5,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.primary,
                child: const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Synthèse'),
                    Tab(text: 'Dossiers'),
                    Tab(text: 'Reversements'),
                    Tab(text: 'Rapports'),
                    Tab(text: 'Messages'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _SyntheseTab(mandantNom: mandantNom, dossiers: dossiers),
                    _DossiersTab(dossiers: dossiers),
                    _ReversementsTab(reversements: _reversements()),
                    const _RapportsTab(),
                    _MessagesTab(mandantId: _mandantId),
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

class _SyntheseTab extends StatelessWidget {
  final String mandantNom;
  final List<Creance> dossiers;

  const _SyntheseTab({required this.mandantNom, required this.dossiers});

  @override
  Widget build(BuildContext context) {
    final confie = dossiers.fold<int>(0, (s, c) => s + c.montantTotal);
    final encours = dossiers.fold<int>(0, (s, c) => s + c.soldeRestant);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Portefeuille $mandantNom', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.3,
          children: [
            KpiCard(label: 'Montant confié', value: formatFcfa(confie), icon: Icons.account_balance_wallet_outlined, color: Colors.indigo),
            KpiCard(label: 'Encours', value: formatFcfa(encours), icon: Icons.hourglass_bottom, color: Colors.orange),
            KpiCard(label: 'Dossiers', value: '${dossiers.length}', icon: Icons.folder_outlined, color: Colors.blueGrey),
            KpiCard(label: 'Taux de recouvrement', value: confie == 0 ? '0 %' : '${(((confie - encours) / confie) * 100).toStringAsFixed(0)} %', icon: Icons.trending_up, color: Colors.green),
          ],
        ),
        if (dossiers.isEmpty) const EmptyPlaceholder(message: 'Aucun dossier.'),
      ],
    );
  }
}

class _DossiersTab extends StatelessWidget {
  final List<Creance> dossiers;

  const _DossiersTab({required this.dossiers});

  @override
  Widget build(BuildContext context) {
    if (dossiers.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun dossier.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: dossiers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final c = dossiers[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/creances/${c.id}'),
            title: Text(c.reference),
            subtitle: Text('${c.nature} · ${formatFcfa(c.soldeRestant)} restant'),
            trailing: StatusBadge(label: c.phase.libelle, color: Colors.blueGrey),
          ),
        );
      },
    );
  }
}

class _ReversementsTab extends StatelessWidget {
  final List<Reversement> reversements;

  const _ReversementsTab({required this.reversements});

  @override
  Widget build(BuildContext context) {
    if (reversements.isEmpty) {
      return const EmptyPlaceholder(message: 'Aucun reversement.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reversements.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = reversements[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.compare_arrows_outlined),
            title: Text(r.mois),
            subtitle: Text(formatFcfa(r.montant)),
            trailing: StatusBadge(label: r.statut.libelle, color: Colors.blueGrey),
          ),
        );
      },
    );
  }
}

class _RapportsTab extends StatelessWidget {
  const _RapportsTab();

  Future<void> _exporter(BuildContext context) async {
    String message;
    try {
      final csv = await CreancesApiService.instance.exportCsv();
      message = 'Export CSV prêt (${csv.length} caractères).';
    } on ApiException catch (e) {
      message = e.message;
    } catch (_) {
      message = 'Erreur lors de l\'export CSV.';
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _rapports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = _rapports[index];
        return Card(
          child: ListTile(
            leading: Icon(_icones[r.icone] ?? Icons.description_outlined),
            title: Text(r.titre),
            subtitle: Text(r.description),
            trailing: IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Exporter en CSV',
              onPressed: () => _exporter(context),
            ),
          ),
        );
      },
    );
  }
}

class _MessagesTab extends StatefulWidget {
  final String mandantId;

  const _MessagesTab({required this.mandantId});

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final texte = _controller.text.trim();
    if (texte.isEmpty) return;
    try {
      await SnrRepository.instance.sendMessage(<String, dynamic>{
        'texte': texte,
        'mandantId': widget.mandantId,
      });
      await SnrRepository.instance.refreshMessages(mandantId: widget.mandantId);
      _controller.clear();
      if (!mounted) return;
      setState(() {});
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du message.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = SnrRepository.instance.messages;
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const EmptyPlaceholder(message: 'Aucun message.')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    return Align(
                      alignment: m.deMoi ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: m.deMoi ? Colors.blue.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.contenu),
                            const SizedBox(height: 4),
                            Text(formatDate(m.date), style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Écrire un message...', border: OutlineInputBorder()),
                  onSubmitted: (_) => _envoyer(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: _envoyer, icon: const Icon(Icons.send)),
            ],
          ),
        ),
      ],
    );
  }
}
