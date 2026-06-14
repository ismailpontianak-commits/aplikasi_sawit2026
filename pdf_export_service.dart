import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/report_model.dart';

class PdfExportService {
  static Future<void> exportReport(ReportModel report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "LAPORAN USAHA RAMP",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Table(
            border: pw.TableBorder.all(),

            children: [
              _row("Total Pembelian", _rupiah(report.totalPembelian)),

              _row("Total Penjualan", _rupiah(report.totalPenjualan)),

              _row("Total Laba", _rupiah(report.totalLaba)),

              _row(
                "Netto Pembelian",
                "${report.totalNettoPembelian.toStringAsFixed(0)} Kg",
              ),

              _row(
                "Netto Penjualan",
                "${report.totalNettoPenjualan.toStringAsFixed(0)} Kg",
              ),

              _row(
                "Transaksi Pembelian",
                report.totalTransaksiPembelian.toString(),
              ),

              _row(
                "Transaksi Penjualan",
                report.totalTransaksiPenjualan.toString(),
              ),

              _row("Total Transaksi", report.totalTransaksi.toString()),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static pw.TableRow _row(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(title)),

        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(value)),
      ],
    );
  }

  static String _rupiah(num value) {
    return "Rp ${value.toStringAsFixed(0)}";
  }
}
