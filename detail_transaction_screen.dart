import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_long_screenshot/flutter_long_screenshot.dart';

import '../core/utils/format_helper.dart';
import 'input_tbs_screen.dart';
import '../services/database/database_helper.dart';
import '../services/printer/thermal_printer_service.dart';

class DetailTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailTransactionScreen({super.key, required this.data});

  @override
  State<DetailTransactionScreen> createState() =>
      _DetailTransactionScreenState();
}

class _DetailTransactionScreenState extends State<DetailTransactionScreen> {
  Map<String, dynamic>? settings;
  final GlobalKey _screenshotKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    loadSettings();
  }

  Future<void> loadSettings() async {
    final data = await DatabaseHelper.instance.getSettings();

    setState(() {
      settings = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final netto = double.tryParse(widget.data['netto'].toString()) ?? 0;

    final grading = double.tryParse(widget.data['grading'].toString()) ?? 0;

    final harga = double.tryParse(widget.data['harga'].toString()) ?? 0;

    final potongAngkut =
        double.tryParse(widget.data['potongAngkut'].toString()) ?? 0;

    final potongLain =
        double.tryParse(widget.data['potongLain'].toString()) ?? 0;

    final potonganGrading = (grading / 100) * netto;

    final nettoFinal = netto - potonganGrading;

    final subtotal = nettoFinal * harga;

    // ================= FIX TOTAL =================

    final totalBayar = (subtotal - potongAngkut - potongLain).clamp(
      0,
      double.infinity,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),

        backgroundColor: const Color(0xFF3568C8),

        elevation: 0,

        scrolledUnderElevation: 0,

        title: const Text(
          "Detail Transaksi",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),

        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => InputTBSScreen(data: widget.data),
                ),
              );

              // ================= REFRESH =================

              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },

            icon: const Icon(Icons.edit_rounded, color: Colors.white),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                child: RepaintBoundary(
                  key: _screenshotKey,

                  child: Container(
                    color: const Color(0xFFF4F4F4),

                    child: Column(
                      children: [
                        // ================= HEADER =================
                        Container(
                          width: double.infinity,

                          decoration: const BoxDecoration(color: Colors.white),

                          padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // ================= LOGO =================
                              if ((settings?['logo_path'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                ClipOval(
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,

                                    child: Image.file(
                                      File(settings!['logo_path']),

                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 70,
                                  height: 70,

                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),

                                    borderRadius: BorderRadius.circular(14),
                                  ),

                                  child: const Icon(
                                    Icons.storefront_rounded,

                                    size: 34,

                                    color: Color(0xFF3568C8),
                                  ),
                                ),

                              const SizedBox(width: 16),

                              // ================= TEXT =================
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      (settings?['business_name'] ??
                                              'RAMP INDPARLOH')
                                          .toString(),

                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        height: 1,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      (settings?['address'] ?? '-').toString(),

                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),

                                    const SizedBox(height: 2),

                                    Text(
                                      "WhatsApp ${settings?['phone'] ?? '-'}",

                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ================= PELANGGAN =================
                        whiteCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "Pelanggan / Petani",

                                style: TextStyle(
                                  fontSize: 14,

                                  color: Colors.black45,

                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                widget.data['pelanggan']
                                    .toString()
                                    .toUpperCase(),

                                style: const TextStyle(
                                  fontSize: 18,

                                  fontWeight: FontWeight.w800,

                                  height: 1,
                                ),
                              ),

                              const SizedBox(height: 12),

                              infoTopItem(
                                "Alamat",
                                widget.data['alamat'].toString(),
                              ),

                              infoTopItem(
                                "Produk / Asal Kebun",
                                widget.data['kebun']?.toString() ?? '-',

                                isLast: true,
                              ),

                              const SizedBox(height: 12),

                              infoTopItem(
                                "Tanggal",
                                widget.data['tanggal'].toString(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ================= DETAIL =================
                        whiteCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "Detail Transaksi",

                                style: TextStyle(
                                  fontSize: 14,

                                  color: Colors.black45,

                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 12),

                              detailItem(
                                "Bruto",

                                "${FormatHelper.kg(netto)} Kg",

                                bold: true,
                              ),

                              detailItem(
                                "Grading",

                                "${grading.toStringAsFixed(1)} %",
                              ),

                              detailItem(
                                "Netto",

                                "${FormatHelper.kg(nettoFinal)} Kg",
                              ),

                              detailItem(
                                "Harga / Kg",
                                FormatHelper.rupiah(harga),
                              ),

                              detailItem(
                                "Subtotal",

                                FormatHelper.rupiah(subtotal),

                                bold: true,
                              ),

                              if (potongAngkut > 0)
                                detailItem(
                                  "Potong Angkutan",
                                  FormatHelper.rupiah(potongAngkut),
                                ),

                              if (potongLain > 0)
                                detailItem(
                                  "Potong Lainnya",
                                  FormatHelper.rupiah(potongLain),
                                ),

                              totalItem(
                                "Total Bayar",

                                FormatHelper.rupiah(totalBayar),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ================= FOOTER =================
                        Container(
                          width: double.infinity,

                          decoration: const BoxDecoration(color: Colors.white),

                          padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),

                          child: Column(
                            children: [
                              Text(
                                settings?['footer_line1']?.toString() ?? '',

                                style: const TextStyle(
                                  fontSize: 14,

                                  color: Colors.black54,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                settings?['footer_line2']?.toString() ?? '',

                                style: const TextStyle(
                                  fontSize: 14,

                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ================= BUTTON =================
            SafeArea(
              top: false,

              child: Container(
                color: Colors.white,

                padding: const EdgeInsets.fromLTRB(40, 14, 40, 12),

                child: Row(
                  children: [
                    Expanded(
                      child: bottomButton(
                        icon: Icons.print_rounded,

                        title: "Print",

                        onTap: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const PopScope(
                              canPop: false,
                              child: AlertDialog(
                                content: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text("Sedang mencetak struk..."),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          try {
                            // ================= BLUETOOTH =================

                            final bluetoothOn =
                                await ThermalPrinterService.isBluetoothOn();

                            if (!bluetoothOn) {
                              if (!context.mounted) return;

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,

                                  content: Text("Bluetooth belum aktif"),
                                ),
                              );

                              return;
                            }

                            // ================= CONNECTION =================

                            final status =
                                await ThermalPrinterService.ensurePrinterConnected();

                            if (status == PrinterStatus.printerNotFound) {
                              if (!context.mounted) return;

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,

                                  content: Text("Printer belum dipilih"),
                                ),
                              );

                              return;
                            }

                            if (status == PrinterStatus.connectionFailed) {
                              if (!context.mounted) return;

                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text("Gagal menghubungkan printer"),
                                ),
                              );

                              return;
                            }

                            // ================= PRINT =================

                            await ThermalPrinterService.printTransaction(
                              trx: widget.data,
                            );

                            if (!context.mounted) return;

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,

                                content: Text(
                                  "Data berhasil dikirim ke printer",
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,

                                content: Text(e.toString()),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: bottomButton(
                        icon: Icons.share_outlined,

                        title: "Bagikan",

                        onTap: () async {
                          try {
                            final Uint8List imageData =
                                await FlutterLongScreenshot.captureLongScreenshot(
                                  key: _screenshotKey,
                                  pixelRatio: 3,
                                  quality: 1,
                                );

                            final namaPelanggan = widget.data['pelanggan']
                                .toString()
                                .replaceAll(' ', '_')
                                .toUpperCase();

                            final tanggal = widget.data['tanggal']
                                .toString()
                                .split(' ')
                                .first
                                .replaceAll('-', '');

                            final fileName =
                                "TRX_${widget.data['id']}_${namaPelanggan}_$tanggal";

                            debugPrint(fileName);

                            await FlutterLongScreenshot.shareScreenshot(
                              imageData,
                              fileName,
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(e.toString()),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WHITE CARD =================

  Widget whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,

      decoration: const BoxDecoration(color: Colors.white),

      padding: const EdgeInsets.fromLTRB(40, 14, 40, 12),

      child: child,
    );
  }

  // ================= TOP INFO =================

  Widget infoTopItem(String title, String value, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Text(
              title,

              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              value,

              textAlign: TextAlign.end,

              style: const TextStyle(
                fontSize: 14,

                fontWeight: FontWeight.w600,

                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DETAIL ITEM =================

  Widget detailItem(String title, String value, {bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),

      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Text(
              title,

              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              value,

              textAlign: TextAlign.end,

              style: TextStyle(
                fontSize: 16,

                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TOTAL =================

  Widget totalItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),

      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF000000), width: 1.1),

          bottom: BorderSide(color: Color(0xFF000000), width: 1.1),
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,

              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),

          Text(
            value,

            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================

  Widget bottomButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: onTap,

      child: Container(
        height: 48,

        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),

          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: const Color(0xFF3568C8), size: 22),

            const SizedBox(width: 8),

            Text(
              title,

              style: const TextStyle(
                color: Color(0xFF3568C8),

                fontSize: 14,

                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
