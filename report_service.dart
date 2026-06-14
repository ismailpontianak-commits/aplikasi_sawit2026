import 'database/database_helper.dart';
import '../models/report_model.dart';

class ReportService {
  static Future<ReportModel> getSummaryReport() async {
    final pembelian = await DatabaseHelper.instance.getTransactions();

    final penjualan = await DatabaseHelper.instance.getSalesTransactions();

    double totalPembelian = 0;
    double totalPenjualan = 0;
    double totalNettoPembelian = 0;
    double totalNettoPenjualan = 0;

    // ==========================
    // PEMBELIAN TBS
    // ==========================

    for (final item in pembelian) {
      final netto = ((item['netto'] ?? 0) as num).toDouble();

      final hargaBeli = ((item['harga'] ?? 0) as num).toDouble();

      final potongAngkut =
          double.tryParse(item['potongAngkut']?.toString() ?? '0') ?? 0;

      final potongLain =
          double.tryParse(item['potongLain']?.toString() ?? '0') ?? 0;

      final subtotal = (netto * hargaBeli) - potongAngkut - potongLain;

      totalNettoPembelian += netto;

      totalPembelian += subtotal;
    }

    // ==========================
    // PENJUALAN TBS
    // ==========================

    for (final item in penjualan) {
      final netto = ((item['netto'] ?? 0) as num).toDouble();

      final hargaJual = ((item['harga_jual'] ?? 0) as num).toDouble();

      final subtotal = netto * hargaJual;

      totalNettoPenjualan += netto;

      totalPenjualan += subtotal;
    }

    return ReportModel(
      totalPembelian: totalPembelian,

      totalPenjualan: totalPenjualan,

      totalLaba: totalPenjualan - totalPembelian,

      totalNettoPembelian: totalNettoPembelian,

      totalNettoPenjualan: totalNettoPenjualan,

      totalTransaksiPembelian: pembelian.length,

      totalTransaksiPenjualan: penjualan.length,
    );
  }
}
