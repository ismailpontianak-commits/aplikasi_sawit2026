class ReportModel {
  final double totalPembelian;
  final double totalPenjualan;
  final double totalLaba;

  final double totalNettoPembelian;
  final double totalNettoPenjualan;

  final int totalTransaksiPembelian;
  final int totalTransaksiPenjualan;

  ReportModel({
    required this.totalPembelian,
    required this.totalPenjualan,
    required this.totalLaba,

    required this.totalNettoPembelian,
    required this.totalNettoPenjualan,

    required this.totalTransaksiPembelian,
    required this.totalTransaksiPenjualan,
  });

  int get totalTransaksi => totalTransaksiPembelian + totalTransaksiPenjualan;
}
