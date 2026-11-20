import 'package:material_ui/material_ui.dart';

import '../../app/format.dart';
import '../../core/network/api_client.dart';
import '../../data/api/creances_api_service.dart';
import '../../data/snr_repository.dart';
import '../../widgets/empty_placeholder.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/pagination_bar.dart';

class _Fil {
  final String cle;
  final String type;
  final String id;
  final String nom;
  final Map<String, dynamic>? dernier;
  final int nonLus;

  const _Fil({
    required this.cle,
    required this.type,
    required this.id,
    required this.nom,
    required this.dernier,
    required this.nonLus,
  });
}

class EchangesScreen extends StatefulWidget {
  const EchangesScreen({super.key});

  @override
  State<EchangesScreen> createState() => _EchangesScreenState();
}

class _EchangesScreenState extends State<EchangesScreen> {
  final _repo = SnrRepository.instance;
  final _api = CreancesApiService.instance;
  final _searchController = TextEditingController();
  final _replyController = TextEditingController();

  late Future<void> _future;
  List<Map<String, dynamic>> _messages = const <Map<String, dynamic>>[];
  String? _selection;
  String? _nouvelle;
  String? _typeFiltre;
  bool _nonLusSeulement = false;
  bool _envoi = false;
  int _page = 0;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _repo.refreshAll();
    final data = await _api.getMessages();
    _messages = data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) => (b['date'] ?? '').toString().compareTo((a['date'] ?? '').toString()));
    if (!mounted) return;
    setState(() {
      _page = 0;
    });
  }

  String _nomMandant(String id) {
    for (final m in _repo.mandants) {
      if (m is Map && (m['id'] ?? '').toString() == id) {
        final sigle = (m['sigle'] ?? '').toString();
        final nom = (m['nom'] ?? '').toString();
        return sigle.isEmpty ? nom : '$sigle — $nom';
      }
    }
    return id;
  }

  String _nomDebiteur(String id) => _repo.debiteurNom(id);

  List<_Fil> _fils() {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final message in _messages) {
      final mandantId = message['mandantId']?.toString();
      final debiteurId = message['debiteurId']?.toString();
      final cle = mandantId != null && mandantId.isNotEmpty
          ? 'M:$mandantId'
          : 'D:${debiteurId ?? ''}';
      map.putIfAbsent(cle, () => <Map<String, dynamic>>[]).add(message);
    }
    if (_selection != null && !map.containsKey(_selection!)) {
      map[_selection!] = <Map<String, dynamic>>[];
    }
    final fils = map.entries.map((entry) {
      final type = entry.key.startsWith('M:') ? 'Mandant' : 'Débiteur';
      final id = entry.key.substring(2);
      return _Fil(
        cle: entry.key,
        type: type,
        id: id,
        nom: type == 'Mandant' ? _nomMandant(id) : _nomDebiteur(id),
        dernier: entry.value.isEmpty ? null : entry.value.last,
        nonLus: entry.value
            .where((m) => m['snr'] != true && m['lu'] != true)
            .length,
      );
    }).toList();
    fils.sort((a, b) =>
        (b.dernier?['date'] ?? '').toString().compareTo((a.dernier?['date'] ?? '').toString()));
    return fils;
  }

  String _apercu(_Fil fil) {
    final message = fil.dernier;
    if (message == null) return 'Aucun message : écrivez le premier.';
    final prefix = message['snr'] == true ? 'SNR : ' : '';
    final texte = (message['texte'] ?? '').toString();
    return prefix + (texte.length > 80 ? '${texte.substring(0, 80)}…' : texte);
  }

  DateTime _dateMessage(Map<String, dynamic>? message) {
    final raw = (message?['date'] ?? '').toString();
    return DateTime.tryParse(raw) ?? DateTime.now();
  }

  List<DropdownMenuItem<String>> _destinataires() {
    final avec = _fils().map((f) => f.cle).toSet();
    final items = <DropdownMenuItem<String>>[];
    for (final m in _repo.mandants) {
      if (m is! Map) continue;
      final id = (m['id'] ?? '').toString();
      if (id.isEmpty || avec.contains('M:$id')) continue;
      items.add(
        DropdownMenuItem<String>(
          value: 'M:$id',
          child: Text('Mandant · ${_nomMandant(id)}', overflow: TextOverflow.ellipsis),
        ),
      );
    }
    for (final d in _repo.debiteurs) {
      if (d.id.isEmpty || avec.contains('D:${d.id}')) continue;
      items.add(
        DropdownMenuItem<String>(
          value: 'D:${d.id}',
          child: Text('Débiteur · ${d.nom}', overflow: TextOverflow.ellipsis),
        ),
      );
    }
    return items;
  }

  Future<void> _ouvrir(_Fil fil) async {
    setState(() => _selection = fil.cle);
    if (fil.nonLus == 0) return;
    try {
      await _api.markMessagesRead(
        mandantId: fil.type == 'Mandant' ? fil.id : '',
        debiteurId: fil.type == 'Débiteur' ? fil.id : '',
      );
      if (!mounted) return;
      setState(() {
        _messages = _messages
            .map(
              (m) => ((fil.type == 'Mandant'
                          ? m['mandantId']?.toString() == fil.id
                          : m['debiteurId']?.toString() == fil.id) &&
                      m['snr'] != true)
                  ? <String, dynamic>{...m, 'lu': true}
                  : m,
            )
            .toList();
      });
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lecture conservée ; le compteur se mettra à jour au prochain chargement.')),
        );
      }
    }
  }

  Future<void> _envoyer() async {
    final fil = _fils().firstWhere(
          (f) => f.cle == _selection,
          orElse: () => const _Fil(cle: '', type: '', id: '', nom: '', dernier: null, nonLus: 0),
        );
    final texte = _replyController.text.trim();
    if (fil.cle.isEmpty || texte.isEmpty) return;
    setState(() => _envoi = true);
    try {
      await _repo.envoyerMessage(<String, dynamic>{
        'texte': texte,
        if (fil.type == 'Mandant') 'mandantId': fil.id,
        if (fil.type == 'Débiteur') 'debiteurId': fil.id,
      });
      _replyController.clear();
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Échanges')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Erreur de chargement des échanges.';
          return Scaffold(
            appBar: AppBar(title: const Text('Échanges')),
            body: Center(
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
        final filActif = _selection == null
            ? null
            : _fils().firstWhere(
                (f) => f.cle == _selection,
                orElse: () => const _Fil(cle: '', type: '', id: '', nom: '', dernier: null, nonLus: 0),
              );
        if (filActif != null && filActif.cle.isNotEmpty) {
          return _buildConversation(filActif);
        }
        return _buildListe();
      },
    );
  }

  Widget _buildListe() {
    final destinataires = _destinataires();
    var fils = _fils().where((f) {
      final matchType = _typeFiltre == null || f.type == _typeFiltre;
      final matchNonLus = !_nonLusSeulement || f.nonLus > 0;
      final query = normalizeText(_searchController.text);
      final matchRecherche = query.isEmpty ||
          normalizeText(f.nom).contains(query) ||
          normalizeText(_apercu(f)).contains(query);
      return matchType && matchNonLus && matchRecherche;
    }).toList();
    final totalNonLus = _fils().fold<int>(0, (sum, f) => sum + f.nonLus);
    final visibles = pageItems(fils, _page, _pageSize);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Échanges'),
        actions: [
          if (totalNonLus > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                radius: 12,
                child: Text('$totalNonLus', style: const TextStyle(fontSize: 11)),
              ),
            ),
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _future = _load()),
          ),
        ],
      ),
      body: Column(
        children: [
          FilterSearchField(
            controller: _searchController,
            hint: 'Rechercher une conversation',
            onChanged: (value) => setState(() {
              _page = 0;
            }),
          ),
          FilterChips<String>(
            values: const <String>['Mandant', 'Débiteur'],
            selected: _typeFiltre,
            label: (value) => value,
            onChanged: (value) => setState(() {
              _typeFiltre = value;
              _page = 0;
            }),
          ),
          Row(
            children: [
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Non lus seulement'),
                selected: _nonLusSeulement,
                onSelected: (value) => setState(() {
                  _nonLusSeulement = value;
                  _page = 0;
                }),
              ),
            ],
          ),
          if (destinataires.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _nouvelle,
                      decoration: const InputDecoration(
                        labelText: 'Nouvelle conversation',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      isExpanded: true,
                      items: destinataires,
                      onChanged: (value) => setState(() => _nouvelle = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Commencer',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: _nouvelle == null
                        ? null
                        : () => setState(() {
                              _selection = _nouvelle;
                              _nouvelle = null;
                            }),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: visibles.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 96),
                        EmptyPlaceholder(message: 'Aucun échange ne correspond à votre recherche.'),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: visibles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final fil = visibles[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                fil.type == 'Mandant' ? Icons.apartment_outlined : Icons.person_outline,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    fil.nom,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (fil.nonLus > 0)
                                  CircleAvatar(
                                    radius: 11,
                                    child: Text('${fil.nonLus}', style: const TextStyle(fontSize: 10)),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  _apercu(fil),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${fil.type} · ${fil.dernier == null ? '' : formatDate(_dateMessage(fil.dernier))}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            onTap: () => _ouvrir(fil),
                          ),
                        );
                      },
                    ),
            ),
          ),
          PaginationBar(
            page: _page,
            pageSize: _pageSize,
            total: fils.length,
            itemLabel: 'conversations',
            onPageChanged: (page) => setState(() => _page = page),
            onPageSizeChanged: (size) => setState(() {
              _pageSize = size;
              _page = 0;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildConversation(_Fil fil) {
    final messages = _messages.where((m) {
      return fil.type == 'Mandant'
          ? m['mandantId']?.toString() == fil.id
          : m['debiteurId']?.toString() == fil.id;
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(fil.nom),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selection = null),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${fil.type} · votre réponse apparaît dans son portail',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(child: EmptyPlaceholder(message: 'Aucun message : écrivez le premier.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final deMoi = message['snr'] == true;
                      return Align(
                        alignment: deMoi ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: deMoi
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (message['auteurNom'] ?? (deMoi ? 'SNR' : fil.nom)).toString(),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text((message['texte'] ?? '').toString()),
                              const SizedBox(height: 4),
                              Text(
                                formatDateTime(_dateMessage(message)),
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Votre réponse…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Envoyer',
                    icon: _envoi
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: _envoi ? null : _envoyer,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
