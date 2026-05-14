import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/maps_launcher.dart';
import '../../data/models/store_model.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/repositories/survey_repository.dart';
import '../../data/models/survey_record_model.dart';
import 'form_toko_screen.dart';
import '../survey/form_survei_screen.dart';


class DetailTokoScreen extends StatefulWidget {
  final StoreModel store;
  const DetailTokoScreen({super.key, required this.store});

  @override
  State<DetailTokoScreen> createState() => _DetailTokoScreenState();
}

class _DetailTokoScreenState extends State<DetailTokoScreen> {
  final _surveyRepo = SurveyRepository();
  final _storeRepo = StoreRepository();
  late StoreModel _store;
  List<SurveyRecordModel> _surveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _store = widget.store;
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    setState(() => _isLoading = true);
    final surveys = await _surveyRepo.getByStoreId(_store.id!);
    // Refresh store data
    final updated = await _storeRepo.getById(_store.id!);
    if (!mounted) return;
    setState(() {
      _surveys = surveys;
      if (updated != null) _store = updated;
      _isLoading = false;
    });
  }

  Future<void> _deleteToko() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Toko?'),
        content: Text('Data toko "${_store.namaToko}" dan semua riwayat surveinya akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _storeRepo.delete(_store.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  Future<void> _editSurvei(SurveyRecordModel survey) async {
    final jumlahCtrl =
        TextEditingController(text: survey.jumlahSaatIni.toString());
    final catatanCtrl = TextEditingController(text: survey.catatan ?? '');
    DateTime tanggal = DateTime.tryParse(survey.tanggalSurvei) ?? DateTime.now();

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
                  leading:
                      const Icon(Icons.calendar_today, color: AppTheme.primary),
                  title: const Text('Tanggal Survei'),
                  subtitle: Text(DateFormatter.toDisplay(
                      DateFormatter.toDb(tanggal))),
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
                child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                final jumlah = int.tryParse(jumlahCtrl.text);
                if (jumlah == null) return;
                final updated = survey.copyWith(
                  jumlahSaatIni: jumlah,
                  tanggalSurvei: DateFormatter.toDb(tanggal),
                  catatan: catatanCtrl.text.isEmpty ? null : catatanCtrl.text,
                );
                await _surveyRepo.update(updated);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadSurveys();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSurvei(SurveyRecordModel survey) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Survei?'),
        content: Text(
            'Survei tanggal ${DateFormatter.toDisplay(survey.tanggalSurvei)} '
            '(${survey.jumlahSaatIni} pcs) akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _surveyRepo.delete(survey.id!);
      _loadSurveys();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_store.namaToko),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormTokoScreen(store: _store)),
              );
              _loadSurveys();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteToko,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FormSurveiScreen(store: _store)),
          );
          _loadSurveys();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Survei'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSurveys,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Info Toko ─────────────────────────────────
            _InfoCard(store: _store, surveys: _surveys),
            const SizedBox(height: 16),

            // ── Lokasi ────────────────────────────────────
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📍 Lokasi Toko',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text('Lat: ${_store.latitude.toStringAsFixed(6)}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    Text('Lng: ${_store.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Buka di Google Maps'),
                        onPressed: () => MapsLauncher.openLocation(
                            _store.latitude, _store.longitude,
                            label: _store.namaToko),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Riwayat Survei ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Riwayat Kunjungan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('${_surveys.length} kunjungan',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_surveys.isEmpty)
              const Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Belum ada kunjungan survei')),
                ),
              )
            else
              ...(_surveys.map((s) => _SurveyTile(
                    survey: s,
                    onEdit: () => _editSurvei(s),
                    onDelete: () => _deleteSurvei(s),
                  ))),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final StoreModel store;
  final List<SurveyRecordModel> surveys;
  const _InfoCard({required this.store, required this.surveys});

  @override
  Widget build(BuildContext context) {
    final stokTerkini = surveys.isNotEmpty ? surveys.first.jumlahSaatIni : store.jumlahTerima;
    final tglUpdate = surveys.isNotEmpty
        ? DateFormatter.toDisplay(surveys.first.tanggalSurvei)
        : DateFormatter.toDisplay(store.tanggalTerima);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.namaToko,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Pemilik: ${store.namaPemilik}',
                style: const TextStyle(color: AppTheme.textSecondary)),
            Text('📍 ${store.alamat}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    label: 'Diterima',
                    value: '${store.jumlahTerima} pcs',
                    sub: DateFormatter.toDisplay(store.tanggalTerima),
                  ),
                ),
                Expanded(
                  child: _InfoRow(
                    label: 'Stok Terkini',
                    value: '$stokTerkini pcs',
                    sub: tglUpdate,
                    highlight: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final bool highlight;
  const _InfoRow({required this.label, required this.value, required this.sub, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Text(value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: highlight ? AppTheme.accent : AppTheme.textPrimary,
            )),
        Text(sub, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _SurveyTile extends StatelessWidget {
  final SurveyRecordModel survey;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SurveyTile({
    required this.survey,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE3F2FD),
          child: Icon(Icons.assignment, color: AppTheme.primary),
        ),
        title: Text(
          '${survey.jumlahSaatIni} pcs',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormatter.toDisplay(survey.tanggalSurvei)} · ${survey.namaPetugas ?? "-"}',
              style: const TextStyle(fontSize: 12),
            ),
            if (survey.catatan != null && survey.catatan!.isNotEmpty)
              Text(
                survey.catatan!,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: AppTheme.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
