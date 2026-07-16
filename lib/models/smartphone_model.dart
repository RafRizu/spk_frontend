/// Model data Smartphone yang dipetakan dari response JSON Laravel.
class SmartphoneModel {
  final int id;
  final String namaModel;
  final String merk;
  final double harga;
  final int ram;
  final int rom;
  final int baterai;
  final double kamera;
  final bool statusTersedia;
  final String? gambar;

  // Field tambahan dari hasil rekomendasi MABAC
  final double? mabacScore;
  final int? rank;

  SmartphoneModel({
    required this.id,
    required this.namaModel,
    required this.merk,
    required this.harga,
    required this.ram,
    required this.rom,
    required this.baterai,
    required this.kamera,
    required this.statusTersedia,
    this.gambar,
    this.mabacScore,
    this.rank,
  });

  /// Parsing dari JSON katalog (GET /api/public/smartphones)
  factory SmartphoneModel.fromJson(Map<String, dynamic> json) {
    return SmartphoneModel(
      id: _parseInt(json['id']),
      namaModel: json['nama_model']?.toString() ?? '',
      merk: json['merk']?.toString() ?? '',
      harga: _parseDouble(json['harga']),
      ram: _parseInt(json['ram']),
      rom: _parseInt(json['rom']),
      baterai: _parseInt(json['baterai']),
      kamera: _parseDouble(json['kamera']),
      statusTersedia:
          json['status_tersedia'] == true ||
          json['status_tersedia'] == 1 ||
          json['status_tersedia'] == '1',
      gambar: json['gambar']?.toString(),
    );
  }

  /// Parsing dari JSON rekomendasi (POST /api/public/recommend)
  factory SmartphoneModel.fromRecommendJson(
    Map<String, dynamic> json,
    int rankIndex,
  ) {
    final smartphone = json['smartphone'] as Map<String, dynamic>? ?? json;
    return SmartphoneModel(
      id: _parseInt(smartphone['id']),
      namaModel: smartphone['nama_model']?.toString() ?? '',
      merk: smartphone['merk']?.toString() ?? '',
      harga: _parseDouble(smartphone['harga']),
      ram: _parseInt(smartphone['ram']),
      rom: _parseInt(smartphone['rom']),
      baterai: _parseInt(smartphone['baterai']),
      kamera: _parseDouble(smartphone['kamera']),
      statusTersedia:
          smartphone['status_tersedia'] == true ||
          smartphone['status_tersedia'] == 1 ||
          smartphone['status_tersedia'] == '1',
      gambar: smartphone['gambar']?.toString(),
      mabacScore: smartphone['mabac_score'] != null
          ? _parseDouble(smartphone['mabac_score'])
          : (json['mabac_score'] != null
                ? _parseDouble(json['mabac_score'])
                : null),
      rank: smartphone['ranking'] != null
          ? _parseInt(smartphone['ranking'])
          : rankIndex,
    );
  }

  // --- Helper parsers agar aman dari tipe data int/string/double ---
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Format harga menjadi Rupiah
  String get formattedHarga {
    final formatted = harga.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}
