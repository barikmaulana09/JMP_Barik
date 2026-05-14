import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/survey_record_model.dart';
import '../../data/repositories/survey_repository.dart';

class DetailSurveiScreen extends StatefulWidget {
  final SurveyRecordModel survey;
  final String storeName;

  const DetailSurveiScreen({
    super.key,
    required this.survey,
    required this.storeName,
  });

  @override
  State<DetailSurveiScreen> createState() => _DetailSurveiScreenState();
}

class _DetailSurveiScreenState extends State<DetailSurveiScreen> {
  final _surveyRepo = SurveyRepository();

  late SurveyRecordModel _survey;

  @override
  void initState() {
    super.initState();
    _survey = widget.survey;
  }

  // ═════════════════════════════════════════════
  // DELETE CONFIRMATION
  // ═════════════════════════════════════════════
  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Survei?'),
        content: Text(
          'Data survei "${widget.storeName}" tanggal '
          '${DateFormatter.toDisplay(_survey.tanggalSurvei)} '
          'akan dihapus permanen.',
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
      await _surveyRepo.delete(_survey.id!);

      if (!mounted) return;

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoExists = File(_survey.fotoBukti).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Survei'),

        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // ═══════════════════════════════════════
          // FOTO PRODUK
          // ═══════════════════════════════════════
          ClipRRect(
            borderRadius: BorderRadius.circular(16),

            child: fotoExists
                ? Image.file(
                    File(_survey.fotoBukti),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey.shade200,

                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Foto tidak tersedia',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════
          // INFORMASI SURVEI
          // ═══════════════════════════════════════
          Card(
            margin: EdgeInsets.zero,

            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.store_outlined,
                    color: AppTheme.primary,
                  ),

                  title: const Text('Nama Toko'),

                  subtitle: Text(widget.storeName),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppTheme.primary,
                  ),

                  title: const Text('Tanggal Survei'),

                  subtitle: Text(
                    DateFormatter.toDisplay(
                      _survey.tanggalSurvei,
                    ),
                  ),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppTheme.primary,
                  ),

                  title: const Text('Status Stok'),

                  subtitle: Text(
                    '${_survey.jumlahSaatIni} pcs tersedia',
                  ),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: AppTheme.primary,
                  ),

                  title: const Text('Petugas Survei'),

                  subtitle: Text(
                    _survey.namaPetugas ?? '-',
                  ),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.notes_outlined,
                    color: AppTheme.primary,
                  ),

                  title: const Text('Catatan'),

                  subtitle: Text(
                    (_survey.catatan != null &&
                            _survey.catatan!.isNotEmpty)
                        ? _survey.catatan!
                        : 'Tidak ada catatan',
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