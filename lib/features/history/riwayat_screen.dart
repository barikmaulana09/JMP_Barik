import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/repositories/survey_repository.dart';
import '../../data/models/survey_record_model.dart';
import '../../data/repositories/store_repository.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final _surveyRepo = SurveyRepository();
  final _storeRepo = StoreRepository();

  List<SurveyRecordModel> _surveys = [];
  Map<int, String> _storeNames = {};

  bool _isLoading = true;
  String _searchQuery = '';

  // SORTING
  String _sortBy = 'terbaru';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final surveys = await _surveyRepo.getAll();
    final storeNames = <int, String>{};

    for (final s in surveys) {
      if (s.storeId != null && !storeNames.containsKey(s.storeId)) {
        final store = await _storeRepo.getById(s.storeId!);

        if (store != null) {
          storeNames[s.storeId!] = store.namaToko;
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _surveys = surveys;
      _storeNames = storeNames;
      _isLoading = false;
    });
  }

  // ════════════════════════════════════════════════════════
  // SORTING FUNCTION
  // ════════════════════════════════════════════════════════
  void _sortSurveys(List<SurveyRecordModel> list) {
    switch (_sortBy) {
      case 'terbaru':
        list.sort(
          (a, b) => DateTime.parse(b.tanggalSurvei)
              .compareTo(DateTime.parse(a.tanggalSurvei)),
        );
        break;

      case 'terlama':
        list.sort(
          (a, b) => DateTime.parse(a.tanggalSurvei)
              .compareTo(DateTime.parse(b.tanggalSurvei)),
        );
        break;

      case 'stok_terbanyak':
        list.sort(
          (a, b) => b.jumlahSaatIni.compareTo(a.jumlahSaatIni),
        );
        break;

      case 'stok_tersedikit':
        list.sort(
          (a, b) => a.jumlahSaatIni.compareTo(b.jumlahSaatIni),
        );
        break;

      case 'nama_toko':
        list.sort((a, b) {
          final storeA = (_storeNames[a.storeId] ?? '').toLowerCase();
          final storeB = (_storeNames[b.storeId] ?? '').toLowerCase();

          return storeA.compareTo(storeB);
        });
        break;
    }
  }

  // ════════════════════════════════════════════════════════
  // FILTER + SORT
  // ════════════════════════════════════════════════════════
  List<SurveyRecordModel> get _filteredSurveys {
    List<SurveyRecordModel> result;

    if (_searchQuery.isEmpty) {
      result = List.from(_surveys);
    } else {
      final q = _searchQuery.toLowerCase();

      result = _surveys.where((s) {
        final storeName = _storeNames[s.storeId] ?? '';

        return storeName.toLowerCase().contains(q) ||
            s.jumlahSaatIni.toString().contains(q) ||
            (s.namaPetugas?.toLowerCase().contains(q) ?? false) ||
            s.tanggalSurvei.contains(q);
      }).toList();
    }

    _sortSurveys(result);

    return result;
  }

  Future<void> _editSurvei(SurveyRecordModel survey) async {
    final jumlahCtrl =
        TextEditingController(text: survey.jumlahSaatIni.toString());

    final catatanCtrl =
        TextEditingController(text: survey.catatan ?? '');

    DateTime tanggal =
        DateTime.tryParse(survey.tanggalSurvei) ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: const Text('Edit Survei'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_storeNames[survey.storeId] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '📍 ${_storeNames[survey.storeId]}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                TextField(
                  controller: jumlahCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Stok Saat Ini',
                    suffixText: 'pcs',
                  ),
                ),

                const SizedBox(height: 12),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today,
                    color: AppTheme.primary,
                  ),
                  title: const Text('Tanggal Survei'),
                  subtitle: Text(
                    DateFormatter.toDisplay(
                      DateFormatter.toDb(tanggal),
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: tanggal,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );

                    if (picked != null) {
                      setLocalState(() => tanggal = picked);
                    }
                  },
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: catatanCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),

            TextButton(
              onPressed: () async {
                final jumlah = int.tryParse(jumlahCtrl.text);

                if (jumlah == null) return;

                final updated = survey.copyWith(
                  jumlahSaatIni: jumlah,
                  tanggalSurvei: DateFormatter.toDb(tanggal),
                  catatan: catatanCtrl.text.isEmpty
                      ? null
                      : catatanCtrl.text,
                );

                await _surveyRepo.update(updated);

                if (ctx.mounted) Navigator.pop(ctx);

                _loadData();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSurvei(SurveyRecordModel survey) async {
    final storeName = _storeNames[survey.storeId] ?? 'Toko';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Survei?'),
        content: Text(
          'Survei di "$storeName" tanggal '
          '${DateFormatter.toDisplay(survey.tanggalSurvei)} '
          '(${survey.jumlahSaatIni} pcs) akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _surveyRepo.delete(survey.id!);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSurveys;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Survei'),

        // SORT BUTTON
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),

            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },

            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'terbaru',
                child: Text('Tanggal Terbaru'),
              ),

              const PopupMenuItem(
                value: 'terlama',
                child: Text('Tanggal Terlama'),
              ),

              const PopupMenuItem(
                value: 'stok_terbanyak',
                child: Text('Stok Terbanyak'),
              ),

              const PopupMenuItem(
                value: 'stok_tersedikit',
                child: Text('Stok Tersedikit'),
              ),

              const PopupMenuItem(
                value: 'nama_toko',
                child: Text('Nama Toko A-Z'),
              ),
            ],
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),

          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

            child: TextField(
              onChanged: (v) {
                setState(() => _searchQuery = v);
              },

              decoration: InputDecoration(
                hintText: 'Cari toko, petugas, tanggal...',
                prefixIcon: const Icon(Icons.search, size: 20),

                isDense: true,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),

                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.9),
              ),

              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadData,

        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,

                    itemBuilder: (_, i) {
                      final s = filtered[i];

                      return _RiwayatTile(
                        survey: s,
                        storeName: _storeNames[s.storeId] ?? '-',
                        onEdit: () => _editSurvei(s),
                        onDelete: () => _deleteSurvei(s),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(40),

      children: [
        const SizedBox(height: 60),

        Icon(
          _searchQuery.isEmpty
              ? Icons.history_toggle_off_rounded
              : Icons.search_off_rounded,
          size: 80,
          color: AppTheme.textSecondary.withValues(alpha: 0.4),
        ),

        const SizedBox(height: 20),

        Text(
          _searchQuery.isEmpty
              ? 'Belum Ada Riwayat'
              : 'Tidak Ditemukan',

          textAlign: TextAlign.center,

          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _searchQuery.isEmpty
              ? 'Riwayat kunjungan survei akan muncul di sini setelah Anda melakukan survei.'
              : 'Tidak ada hasil untuk "$_searchQuery". Coba kata kunci lain.',

          textAlign: TextAlign.center,

          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// WIDGET: RIWAYAT TILE
// ══════════════════════════════════════════════════════════
class _RiwayatTile extends StatelessWidget {
  final SurveyRecordModel survey;
  final String storeName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RiwayatTile({
    required this.survey,
    required this.storeName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),

        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                AppTheme.primary.withValues(alpha: 0.1),

            child: Text(
              '${survey.jumlahSaatIni}',

              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                fontSize: 14,
              ),
            ),
          ),

          title: Text(
            storeName,

            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),

            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppTheme.textSecondary
                        .withValues(alpha: 0.6),
                  ),

                  const SizedBox(width: 4),

                  Text(
                    DateFormatter.toDisplay(
                      survey.tanggalSurvei,
                    ),

                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary
                          .withValues(alpha: 0.8),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Icon(
                    Icons.person_outline,
                    size: 12,
                    color: AppTheme.textSecondary
                        .withValues(alpha: 0.6),
                  ),

                  const SizedBox(width: 4),

                  Text(
                    survey.namaPetugas ?? '-',

                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),

              if (survey.catatan != null &&
                  survey.catatan!.isNotEmpty) ...[
                const SizedBox(height: 4),

                Text(
                  survey.catatan!,

                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),

          trailing: PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppTheme.textSecondary,
            ),

            onSelected: (value) {
              if (value == 'edit') onEdit();

              if (value == 'delete') onDelete();
            },

            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',

                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppTheme.primary,
                    ),

                    SizedBox(width: 8),

                    Text('Edit'),
                  ],
                ),
              ),

              const PopupMenuItem(
                value: 'delete',

                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppTheme.error,
                    ),

                    SizedBox(width: 8),

                    Text(
                      'Hapus',
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}