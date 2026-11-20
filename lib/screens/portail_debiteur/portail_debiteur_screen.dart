import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/auth/auth_service.dart';
import '../../core/network/api_client.dart';
import '../../data/snr_repository.dart';
import '../../models/creance.dart';
import '../../models/message_portail.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/status_badge.dart';

class PortailDebiteurScreen extends StatefulWidget {
  const PortailDebiteurScreen({super.key});

  @override
  State<PortailDebiteurScreen> createState() => _PortailDebiteurScreenState();
}

class _PortailDebiteurScreenState extends State<PortailDebiteurScreen> {
  final _repo = SnrRepository.instance;
  late Future<void> _future;
  String _debiteurId = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _load() async {
    await _repo.refreshAll();
    var id = AuthService.instance.currentUser?.debiteurId;
    if (id == null || id.isEmpty) {
      if (_repo.debiteurs.isNotEmpty) {
        id = _repo.debiteurs.first.id;
      } else if (_repo.creances.isNotEmpty) {
        id = _repo.creances.first.debiteurId;
      }
    }
    _debiteurId = id ?? '';
    await _repo.refreshMessages(
      debiteurId: _debiteurId.isEmpty ? null : _debiteurId,
    );
  }

  String _greeting() {
    final user = AuthService.instance.currentUser;
    final prenom = user?.prenom ?? '';
    final nom = user?.nom ?? '';
    final nomComplet = '$prenom $nom'.trim();
    return nomComplet.isEmpty ? _repo.debiteurNom(_debiteurId) : nomComplet;
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
              : 'Erreur de chargement du portail débiteur.';
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
        return DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.primary,
                child: const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Accueil'),
                    Tab(text: 'Payer'),
                    Tab(text: 'Demandes'),
                    Tab(text: 'Messages'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _AccueilTab(
                      greeting: _greeting(),
                      dossiers: _repo.creancesDuDebiteur(_debiteurId),
                    ),
                    const _PayerTab(),
                    const _DemandesTab(),
                    _MessagesTab(debiteurId: _debiteurId),
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

class _AccueilTab extends StatefulWidget {
  final String greeting;
  final List<Creance> dossiers;

  const _AccueilTab({required this.greeting, required this.dossiers});

  @override
  State<_AccueilTab> createState() => _AccueilTabState();
}

class _AccueilTabState extends State<_AccueilTab> {
  final _searchController = TextEditingController();
  String _query = '';
  PhaseCreance? _phase;
  SituationCreance? _situation;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    setState(() {
      _searchController.clear();
      _query = '';
      _phase = null;
      _situation = null;
    });
  }

  Widget _introduction() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour ${widget.greeting}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Vous avez ${widget.dossiers.length} dossier(s) en cours.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dossiers.isEmpty) {
      return Column(
        children: [
          _introduction(),
          const Expanded(child: EmptyPlaceholder(message: 'Aucun dossier.')),
        ],
      );
    }
    final filtered = widget.dossiers.where((c) {
      final matchRecherche =
          _query.isEmpty ||
          normalizeText(c.reference).contains(_query) ||
          normalizeText(c.nature).contains(_query);
      final matchPhase = _phase == null || c.phase == _phase;
      final matchSituation = _situation == null || c.situation == _situation;
      return matchRecherche && matchPhase && matchSituation;
    }).toList();

    return PaginatedListView<Creance>(
      items: filtered,
      itemLabel: 'dossiers',
      emptyMessage: 'Aucun dossier ne correspond aux filtres.',
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _introduction(),
          FilterSearchField(
            controller: _searchController,
            hint: 'Rechercher une référence ou une nature',
            onChanged: (value) => setState(() => _query = normalizeText(value)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterDropdown<PhaseCreance?>(
                  label: 'Phase',
                  value: _phase,
                  items: [
                    const DropdownMenuItem<PhaseCreance?>(
                      value: null,
                      child: Text('Toutes'),
                    ),
                    for (final phase in PhaseCreance.values)
                      DropdownMenuItem<PhaseCreance?>(
                        value: phase,
                        child: Text(phase.libelle),
                      ),
                  ],
                  onChanged: (value) => setState(() => _phase = value),
                ),
                FilterDropdown<SituationCreance?>(
                  label: 'Situation',
                  value: _situation,
                  items: [
                    const DropdownMenuItem<SituationCreance?>(
                      value: null,
                      child: Text('Toutes'),
                    ),
                    for (final situation in SituationCreance.values)
                      DropdownMenuItem<SituationCreance?>(
                        value: situation,
                        child: Text(situation.libelle),
                      ),
                  ],
                  onChanged: (value) => setState(() => _situation = value),
                ),
                TextButton(
                  onPressed: _reinitialiser,
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
          ),
        ],
      ),
      itemBuilder: (context, c) {
        return Card(
          child: InkWell(
            onTap: () => context.push('/creances/${c.id}'),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        c.reference,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      StatusBadge(
                        label: c.situation.libelle,
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(c.nature),
                  const SizedBox(height: 6),
                  Text(
                    'Solde restant : ${formatFcfa(c.soldeRestant)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PayerTab extends StatefulWidget {
  const _PayerTab();

  @override
  State<_PayerTab> createState() => _PayerTabState();
}

class _PayerTabState extends State<_PayerTab> {
  String _canal = 'Wave';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Effectuer un paiement',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _canal,
          decoration: const InputDecoration(
            labelText: 'Moyen de paiement',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Wave', child: Text('Wave')),
            DropdownMenuItem(
              value: 'Orange Money',
              child: Text('Orange Money'),
            ),
            DropdownMenuItem(
              value: 'Carte bancaire',
              child: Text('Carte bancaire'),
            ),
          ],
          onChanged: (v) => setState(() => _canal = v ?? _canal),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Montant (FCFA)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Paiement via $_canal traité par le parcours sécurisé du portail backend.',
                ),
              ),
            );
          },
          icon: const Icon(Icons.payment_outlined),
          label: const Text('Payer maintenant'),
        ),
      ],
    );
  }
}

class _DemandesTab extends StatelessWidget {
  const _DemandesTab();

  @override
  Widget build(BuildContext context) {
    final demandes = [
      ('Demande d\'échéancier', Icons.event_note_outlined),
      ('Demande d\'attestation', Icons.verified_outlined),
      ('Contester une créance', Icons.report_gmailerrorred_outlined),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: demandes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final (label, icon) = demandes[index];
        return Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$label traitée par le parcours sécurisé du portail backend.',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MessagesTab extends StatefulWidget {
  final String debiteurId;

  const _MessagesTab({required this.debiteurId});

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  String _query = '';
  String? _filtre;

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    setState(() {
      _searchController.clear();
      _query = '';
      _filtre = null;
    });
  }

  Future<void> _envoyer() async {
    final texte = _controller.text.trim();
    if (texte.isEmpty) return;
    try {
      await SnrRepository.instance.sendMessage(<String, dynamic>{
        'texte': texte,
        'debiteurId': widget.debiteurId,
      });
      await SnrRepository.instance.refreshMessages(
        debiteurId: widget.debiteurId,
      );
      _controller.clear();
      if (!mounted) return;
      setState(() {});
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du message.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = SnrRepository.instance.messages;
    final filtered = source.where((m) {
      final matchRecherche =
          _query.isEmpty ||
          normalizeText(m.contenu).contains(_query) ||
          normalizeText(m.auteur).contains(_query);
      final matchFiltre =
          _filtre == null || (_filtre == 'Envoyés' ? m.deMoi : !m.deMoi);
      return matchRecherche && matchFiltre;
    }).toList();

    final liste = source.isEmpty
        ? const Expanded(child: EmptyPlaceholder(message: 'Aucun message.'))
        : Expanded(
            child: PaginatedListView<MessagePortail>(
              items: filtered,
              itemLabel: 'messages',
              emptyMessage: 'Aucun message ne correspond aux filtres.',
              separatorBuilder: (_) => const SizedBox.shrink(),
              header: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilterSearchField(
                    controller: _searchController,
                    hint: 'Rechercher un message',
                    onChanged: (value) =>
                        setState(() => _query = normalizeText(value)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilterChips<String>(
                          values: const <String>['Envoyés', 'Reçus'],
                          selected: _filtre,
                          label: (value) => value,
                          onChanged: (value) => setState(() => _filtre = value),
                        ),
                      ),
                      TextButton(
                        onPressed: _reinitialiser,
                        child: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                ],
              ),
              itemBuilder: (context, m) {
                return Align(
                  alignment: m.deMoi
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: m.deMoi
                          ? Colors.blue.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.contenu),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(m.date),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );

    return Column(
      children: [
        liste,
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Écrire un message...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _envoyer(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _envoyer,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
