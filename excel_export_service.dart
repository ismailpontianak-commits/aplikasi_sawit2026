import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/report_model.dart';

class ExcelExportService {
  static Future<void> exportReport(ReportModel report) async {
    final excel = Excel.createExcel();

    final sheet = excel['Laporan'];

    sheet.appendRow([TextCellValue("Keterangan"), TextCellValue("Nilai")]);

    sheet.appendRow([
      TextCellValue("Total Pembelian"),
      TextCellValue(report.totalPembelian.toStringAsFixed(0)),
    ]);

    sheet.appendRow([
      TextCellValue("Total Penjualan"),
      TextCellValue(report.totalPenjualan.toStringAsFixed(0)),
    ]);

    sheet.appendRow([
      TextCellValue("Total Laba"),
      TextCellValue(report.totalLaba.toStringAsFixed(0)),
    ]);

    sheet.appendRow([
      TextCellValue("Netto Pembelian"),
      TextCellValue(report.totalNettoPembelian.toStringAsFixed(0)),
    ]);

    sheet.appendRow([
      TextCellValue("Netto Penjualan"),
      TextCellValue(report.totalNettoPenjualan.toStringAsFixed(0)),
    ]);

    sheet.appendRow([
      TextCellValue("Transaksi Pembelian"),
      TextCellValue(report.totalTransaksiPembelian.toString()),
    ]);

    sheet.appendRow([
      TextCellValue("Transaksi Penjualan"),
      TextCellValue(report.totalTransaksiPenjualan.toString()),
    ]);

    sheet.appendRow([
      TextCellValue("Total Transaksi"),
      TextCellValue(report.totalTransaksi.toString()),
    ]);

    final bytes = excel.encode();

    if (bytes == null) return;

    final dir = await getTemporaryDirectory();

    final file = File("${dir.path}/laporan_ramp.xlsx");

    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }
}
