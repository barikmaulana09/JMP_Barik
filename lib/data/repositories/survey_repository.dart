import '../database/database_helper.dart';
import '../models/survey_record_model.dart';

class SurveyRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Ambil semua survei untuk satu toko, urutkan terbaru
  Future<List<SurveyRecordModel>> getByStoreId(int storeId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT sr.*, u.nama AS nama_petugas, s.nama_toko
      FROM survey_records sr
      LEFT JOIN users u ON sr.user_id = u.id
      LEFT JOIN stores s ON sr.store_id = s.id
      WHERE sr.store_id = ?
      ORDER BY sr.tanggal_survei DESC, sr.created_at DESC
    ''', [storeId]);
    return result.map(SurveyRecordModel.fromMap).toList();
  }

  Future<List<SurveyRecordModel>> getAll() async {
    final db = await _db.database;
    final maps = await db.query(
      'survey_records',
      orderBy: 'tanggal_survei DESC',
    );
    return maps.map((m) => SurveyRecordModel.fromMap(m)).toList();
  }

  /// Ambil survei terkini untuk satu toko
  Future<SurveyRecordModel?> getLatestByStoreId(int storeId) async {
    final records = await getByStoreId(storeId);
    if (records.isEmpty) return null;
    return records.first;
  }

  /// Tambah survei baru
  Future<int> insert(SurveyRecordModel record) async {
    final db = await _db.database;
    return db.insert('survey_records', record.toMap());
  }

  /// Update survei
  Future<void> update(SurveyRecordModel record) async {
    final db = await _db.database;
    await db.update(
      'survey_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// Hapus survei
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('survey_records', where: 'id = ?', whereArgs: [id]);
  }

  /// Hitung total kunjungan bulan ini
  Future<int> countThisMonth() async {
    final db = await _db.database;
    final now = DateTime.now();
    final monthPrefix = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM survey_records WHERE tanggal_survei LIKE ?',
      ['$monthPrefix%'],
    );
    return result.first['count'] as int;
  }
}
