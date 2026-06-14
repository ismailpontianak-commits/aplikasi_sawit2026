import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../core/constants/app_colors.dart';
import '../services/database/database_helper.dart';
import 'input_sales_screen.dart';

class DetailSalesScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailSalesScreen({super.key, required this.data});

  @override
  State<DetailSalesScreen> createState() => _DetailSalesScreenState();
}

class _DetailSalesScreenState extends State<DetailSalesScreen> {
  String rupiah(num value) {
    return toCurrencyString(
      value.toStringAsFixed(0),
      thousandSeparator: ThousandSeparator.Period,
      mantissaLength: 0,
    );
  }

  Future<void> deleteData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Hapus Data"),
          content: const Text("Yakin ingin menghapus data penjualan ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await DatabaseHelper.instance.deleteSalesTransaction(widget.data['id']);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final netto1 = ((widget.data['netto'] ?? 0) as num).toDouble();

    final grading = ((widget.data['grading'] ?? 0) as num).toDouble();

    final hargaJual = ((widget.data['harga_jual'] ?? 0) as num).toDouble();

    final solar = ((widget.data['solar'] ?? 0) as num).toDouble();

    final upahMuat = ((widget.data['upah_muat'] ?? 0) as num).toDouble();

    final upahSupir = ((widget.data['upah_supir'] ?? 0) as num).toDouble();

    final biayaLain = ((widget.data['biaya_lain'] ?? 0) as num).toDouble();

    final netto2 = netto1 - ((netto1 * grading) / 100);

    final subtotal = netto2 * hargaJual;

    final totalBiaya = solar + upahMuat + upahSupir + biayaLain;

    final totalBersih = subtotal - totalBiaya;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "DETAIL PENJUALAN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: AppColors.primary,

                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                children: [
                  const Text(
                    "TOTAL BERSIH",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Rp ${rupiah(totalBersih)}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.data['tanggal'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.data['pabrik_tujuan'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= INFORMASI =================
            buildSection(
              title: "Informasi Pengiriman",
              children: [
                infoRow("Supir", widget.data['supir'] ?? ''),
                infoRow("Kendaraan", widget.data['nomor_kendaraan'] ?? ''),
                infoRow("Pabrik", widget.data['pabrik_tujuan'] ?? ''),
                infoRow("Tanggal", widget.data['tanggal'] ?? ''),
              ],
            ),

            const SizedBox(height: 14),

            // ================= TIMBANGAN =================
            buildSection(
              title: "Detail Timbangan",
              children: [
                infoRow("Netto I", "${rupiah(netto1)} Kg"),
                infoRow("Grading", "${grading.toStringAsFixed(1)} %"),
                infoRow("Netto II", "${rupiah(netto2)} Kg"),
                infoRow("Harga Jual", "Rp ${rupiah(hargaJual)}"),
              ],
            ),

            const SizedBox(height: 14),

            // ================= BIAYA =================
            buildSection(
              title: "Biaya Operasional",
              children: [
                infoRow("Solar", "Rp ${rupiah(solar)}"),
                infoRow("Upah Muat", "Rp ${rupiah(upahMuat)}"),
                infoRow("Upah Supir", "Rp ${rupiah(upahSupir)}"),
                infoRow("Biaya Lain", "Rp ${rupiah(biayaLain)}"),

                const Divider(height: 24),

                infoRow(
                  "Total Biaya",
                  "Rp ${rupiah(totalBiaya)}",
                  valueColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ================= RINGKASAN =================
            buildSection(
              title: "Ringkasan",
              children: [
                infoRow("Sub Total", "Rp ${rupiah(subtotal)}"),
                infoRow("Total Biaya", "Rp ${rupiah(totalBiaya)}"),
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "TOTAL BERSIH",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      Text(
                        "Rp ${rupiah(totalBersih)}",
                        style: TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= BUTTON =================
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: () async {
                      final navigator = Navigator.of(context);

                      final result = await navigator.push(
                        MaterialPageRoute(
                          builder: (_) => InputSalesScreen(data: widget.data),
                        ),
                      );

                      if (!mounted) return;

                      if (result == true) {
                        navigator.pop(true);
                      }
                    },

                    icon: const Icon(Icons.edit_rounded, color: Colors.white),

                    label: const Text(
                      "EDIT TRANSAKSI",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: deleteData,

                    icon: const Icon(Icons.delete_rounded, color: Colors.white),

                    label: const Text(
                      "HAPUS DATA",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 14),

          ...children,
        ],
      ),
    );
  }

  Widget infoRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),

          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
