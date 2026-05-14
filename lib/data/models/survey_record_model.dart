class SurveyRecordModel {
  final int? id;
  final int storeId;
  final int userId;
  final int jumlahSaatIni;
  final String tanggalSurvei;
  final String fotoBukti;
  final String? catatan;
  final String createdAt;

  // Join fields (opsional, dari query relasi)
  final String? namaToko;
  final String? namaPetugas;

  SurveyRecordModel({
    this.id,
    required this.storeId,
    required this.userId,
    required this.jumlahSaatIni,
    required this.tanggalSurvei,
    required this.fotoBukti,
    this.catatan,
    required this.createdAt,
    this.namaToko,
    this.namaPetugas,
  });

  factory SurveyRecordModel.fromMap(Map<String, dynamic> map) {
    return SurveyRecordModel(
      id: map['id'] as int?,
      storeId: map['store_id'] as int,
      userId: map['user_id'] as int,
      jumlahSaatIni: map['jumlah_saat_ini'] as int,
      tanggalSurvei: map['tanggal_survei'] as String,
      fotoBukti: map['foto_bukti'] as String,
      catatan: map['catatan'] as String?,
      createdAt: map['created_at'] as String,
      namaToko: map['nama_toko'] as String?,
      namaPetugas: map['nama_petugas'] as String?,
    );
  }

  get fotoPath => null;

  get _fotoPath => null;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'store_id': storeId,
      'user_id': userId,
      'jumlah_saat_ini': jumlahSaatIni,
      'tanggal_survei': tanggalSurvei,
      'foto_bukti': fotoBukti,
      'catatan': catatan,
      'created_at': createdAt,
    };
  }

  SurveyRecordModel copyWith({
    int? id,
    int? storeId,
    int? userId,
    int? jumlahSaatIni,
    String? tanggalSurvei,
    String? fotoBukti,
    String? catatan,
    String? createdAt,
  }) {
    return SurveyRecordModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      jumlahSaatIni: jumlahSaatIni ?? this.jumlahSaatIni,
      tanggalSurvei: tanggalSurvei ?? this.tanggalSurvei,
      fotoBukti: fotoBukti ?? this.fotoBukti,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
