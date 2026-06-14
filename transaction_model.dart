class TransactionModel {
  final String pelanggan;
  final String alamat;
  final String kebun;

  final String potongAngkut;
  final String potongLain;

  final double netto;
  final double grading;
  final double harga;

  final String tanggal;

  TransactionModel({
    required this.pelanggan,
    required this.alamat,
    required this.kebun,

    required this.potongAngkut,
    required this.potongLain,

    required this.netto,
    required this.grading,
    required this.harga,

    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'pelanggan': pelanggan,
      'alamat': alamat,
      'kebun': kebun,

      'potongAngkut': potongAngkut,

      'potongLain': potongLain,

      'netto': netto,
      'grading': grading,
      'harga': harga,

      'tanggal': tanggal,
    };
  }
}
