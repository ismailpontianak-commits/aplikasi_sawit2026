class SalesTransactionModel {
  final String tanggal;

  final String supir;
  final String nomorKendaraan;
  final String pabrikTujuan;

  final double netto;
  final double grading;
  final double hargaJual;

  final double solar;
  final double upahMuat;
  final double upahSupir;
  final double biayaLain;

  final double subtotal;
  final double totalBiaya;
  final double totalBersih;

  SalesTransactionModel({
    required this.tanggal,

    required this.supir,
    required this.nomorKendaraan,
    required this.pabrikTujuan,

    required this.netto,
    required this.grading,
    required this.hargaJual,

    required this.solar,
    required this.upahMuat,
    required this.upahSupir,
    required this.biayaLain,

    required this.subtotal,
    required this.totalBiaya,
    required this.totalBersih,
  });

  Map<String, dynamic> toMap() {
    return {
      'tanggal': tanggal,

      'supir': supir,
      'nomor_kendaraan': nomorKendaraan,
      'pabrik_tujuan': pabrikTujuan,

      'netto': netto,
      'grading': grading,
      'harga_jual': hargaJual,

      'solar': solar,
      'upah_muat': upahMuat,
      'upah_supir': upahSupir,
      'biaya_lain': biayaLain,

      'subtotal': subtotal,
      'total_biaya': totalBiaya,
      'total_bersih': totalBersih,
    };
  }

  factory SalesTransactionModel.fromMap(Map<String, dynamic> map) {
    return SalesTransactionModel(
      tanggal: map['tanggal'] ?? '',

      supir: map['supir'] ?? '',
      nomorKendaraan: map['nomor_kendaraan'] ?? '',
      pabrikTujuan: map['pabrik_tujuan'] ?? '',

      netto: (map['netto'] as num?)?.toDouble() ?? 0,
      grading: (map['grading'] as num?)?.toDouble() ?? 0,
      hargaJual: (map['harga_jual'] as num?)?.toDouble() ?? 0,

      solar: (map['solar'] as num?)?.toDouble() ?? 0,
      upahMuat: (map['upah_muat'] as num?)?.toDouble() ?? 0,
      upahSupir: (map['upah_supir'] as num?)?.toDouble() ?? 0,
      biayaLain: (map['biaya_lain'] as num?)?.toDouble() ?? 0,

      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      totalBiaya: (map['total_biaya'] as num?)?.toDouble() ?? 0,
      totalBersih: (map['total_bersih'] as num?)?.toDouble() ?? 0,
    );
  }
}
