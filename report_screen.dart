import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../core/utils/format_helper.dart';
import '../services/export/pdf_export_service.dart';
import '../services/export/excel_export_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isLoading = true;

  ReportModel? report;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await ReportService.getSummaryReport();

    if (!mounted) return;

    setState(() {
      report = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,

        title: const Text(
          "Laporan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          "Pembelian",
                          FormatHelper.rupiah(report!.totalPembelian),
                          Icons.shopping_basket,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _summaryCard(
                          "Penjualan",
                          FormatHelper.rupiah(report!.totalPenjualan),
                          Icons.local_shipping,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          "Laba",
                          FormatHelper.rupiah(report!.totalLaba),
                          Icons.account_balance_wallet,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _summaryCard(
                          "Transaksi",
                          report!.totalTransaksi.toString(),
                          Icons.receipt_long,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Ringkasan Operasional",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 12),

                  _infoTile(
                    "Netto Pembelian",
                    "${FormatHelper.kg(report!.totalNettoPembelian)} Kg",
                  ),

                  _infoTile(
                    "Netto Penjualan",
                    "${FormatHelper.kg(report!.totalNettoPenjualan)} Kg",
                  ),

                  _infoTile(
                    "Transaksi Pembelian",
                    report!.totalTransaksiPembelian.toString(),
                  ),

                  _infoTile(
                    "Transaksi Penjualan",
                    report!.totalTransaksiPenjualan.toString(),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Export Laporan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 12),

                  _exportButton("Export PDF", Icons.picture_as_pdf),

                  const SizedBox(height: 10),

                  _exportButton("Export Excel", Icons.table_chart),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: AppColors.primary),

          const SizedBox(height: 4),

          Text(title, style: const TextStyle(fontSize: 12)),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _exportButton(String title, IconData icon) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          if (title.contains("PDF")) {
            PdfExportService.exportReport(report!);
          } else {
            ExcelExportService.exportReport(report!);
          }
        },
        icon: Icon(icon),
        label: Text(title),
      ),
    );
  }
}
