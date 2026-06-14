import 'package:flutter/material.dart';

import '../core/utils/format_helper.dart';
import '../services/database/database_helper.dart';

import 'detail_transaction_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> transactions = [];

  List<Map<String, dynamic>> filteredTransactions = [];

  final TextEditingController searchC = TextEditingController();

  @override
  void initState() {
    super.initState();

    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();

    setState(() {
      transactions = data;
      filteredTransactions = data;
    });
  }

  // ================= SEARCH =================

  void searchTransaction(String value) {
    final result = transactions.where((e) {
      return e['pelanggan'].toString().toLowerCase().contains(
            value.toLowerCase(),
          ) ||
          e['alamat'].toString().toLowerCase().contains(value.toLowerCase());
    }).toList();

    setState(() {
      filteredTransactions = result;
    });
  }

  // ================= SUMMARY =================

  double get totalNetto1 {
    double total = 0;

    for (var item in filteredTransactions) {
      total += double.tryParse(item['netto'].toString()) ?? 0;
    }

    return total;
  }

  double get totalNetto2 {
    double total = 0;

    for (var item in filteredTransactions) {
      final netto = double.tryParse(item['netto'].toString()) ?? 0;

      final grading = double.tryParse(item['grading'].toString()) ?? 0;

      final nettoFinal = netto - ((grading / 100) * netto);

      total += nettoFinal;
    }

    return total;
  }

  double get totalSubtotal {
    double total = 0;

    for (var item in filteredTransactions) {
      final netto = double.tryParse(item['netto'].toString()) ?? 0;

      final grading = double.tryParse(item['grading'].toString()) ?? 0;

      final harga = double.tryParse(item['harga'].toString()) ?? 0;

      final nettoFinal = netto - ((grading / 100) * netto);

      total += nettoFinal * harga;
    }

    return total;
  }

  String getDateHeader(String date) {
    try {
      final split = date.split(' ');

      final dateOnly = split[0];

      final parts = dateOnly.split('-');

      final day = int.parse(parts[0]);

      final month = int.parse(parts[1]);

      final year = int.parse(parts[2]);

      final dt = DateTime(year, month, day);

      const hari = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];

      const bulan = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      return "${hari[dt.weekday - 1]}, "
          "${dt.day} "
          "${bulan[dt.month]} "
          "${dt.year}";
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color(0xFF4B74D9),

        elevation: 0,

        centerTitle: false,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Riwayat Transaksi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 4),

            Text(
              "Pembelian Tbs Petani",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // ================= BLUE HEADER =================
          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                // ================= SEARCH =================
                Container(
                  height: 52,

                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(18),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),

                        blurRadius: 10,

                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Colors.black54),

                      const SizedBox(width: 12),

                      Expanded(
                        child: TextField(
                          controller: searchC,

                          onChanged: searchTransaction,

                          decoration: const InputDecoration(
                            border: InputBorder.none,

                            hintText: "Cari nama pelanggan / petani",

                            hintStyle: TextStyle(color: Colors.black38),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ================= SUMMARY =================
                Container(
                  height: 108,

                  padding: const EdgeInsets.symmetric(horizontal: 4),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(22),
                  ),

                  child: Row(
                    children: [
                      Expanded(
                        child: summaryItem(
                          "Total Bruto",

                          FormatHelper.kg(totalNetto1),

                          "Kg",
                        ),
                      ),

                      summaryDivider(),

                      Expanded(
                        child: summaryItem(
                          "Transaksi",

                          filteredTransactions.length.toString(),

                          "Kali",
                        ),
                      ),

                      summaryDivider(),

                      Expanded(
                        child: summaryItem(
                          "Subtotal",

                          FormatHelper.shortCurrency(totalSubtotal),

                          "Rupiah",
                        ),
                      ),

                      summaryDivider(),

                      Expanded(
                        child: summaryItem(
                          "Total Netto",

                          FormatHelper.kg(totalNetto2),

                          "Kg",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: Container(
              width: double.infinity,

              decoration: const BoxDecoration(color: Color(0xFFF4F6FA)),

              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada transaksi",

                        style: TextStyle(
                          fontSize: 16,

                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),

                      itemCount: filteredTransactions.length,

                      itemBuilder: (context, index) {
                        final item = filteredTransactions[index];

                        // ================= MONTH =================

                        final currentDate = getDateHeader(
                          item['tanggal']?.toString() ?? '',
                        );

                        String previousDate = '';

                        if (index > 0) {
                          previousDate = getDateHeader(
                            filteredTransactions[index - 1]['tanggal']
                                    ?.toString() ??
                                '',
                          );
                        }

                        final showDateHeader = currentDate != previousDate;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // ================= MONTH HEADER =================
                            if (showDateHeader) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 12,
                                  top: 8,
                                ),

                                child: Text(
                                  currentDate.toUpperCase(),

                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4B74D9),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],

                            // ================= ITEM =================
                            Material(
                              color: Colors.transparent,

                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),

                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailTransactionScreen(data: item),
                                    ),
                                  );

                                  if (!mounted) return;

                                  if (result == true) {
                                    loadTransactions();
                                  }
                                },

                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.white,

                                    borderRadius: BorderRadius.circular(20),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.03,
                                        ),

                                        blurRadius: 12,

                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),

                                  child: Row(
                                    children: [
                                      // ================= AVATAR =================
                                      Container(
                                        width: 52,
                                        height: 52,

                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F1FF),

                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),

                                        alignment: Alignment.center,

                                        child: Text(
                                          (item['pelanggan']
                                                      ?.toString()
                                                      .isNotEmpty ??
                                                  false)
                                              ? item['pelanggan']
                                                    .toString()
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                              : '?',

                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF4B74D9),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      // ================= TEXT =================
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              item['pelanggan'].toString(),

                                              maxLines: 1,

                                              overflow: TextOverflow.ellipsis,

                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              item['alamat']?.toString() ?? '-',

                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,

                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      // ================= VALUE =================
                                      Text(
                                        "${FormatHelper.kg(double.tryParse(item['netto'].toString()) ?? 0)} Kg",

                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF4B74D9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= SUMMARY =================

Widget summaryDivider() {
  return Container(width: 1, height: 64, color: const Color(0xFFE5E7EB));
}

Widget summaryItem(String title, String value, String suffix) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,

    children: [
      Text(
        title,

        textAlign: TextAlign.center,

        style: const TextStyle(
          fontSize: 11,

          color: Colors.black54,

          fontWeight: FontWeight.w500,
        ),
      ),

      const SizedBox(height: 10),

      Text(
        value,

        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),

      const SizedBox(height: 4),

      Text(suffix, style: const TextStyle(fontSize: 11, color: Colors.black54)),
    ],
  );
}
