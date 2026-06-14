import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../core/constants/app_colors.dart';
import '../services/database/database_helper.dart';
import 'input_sales_screen.dart';
import 'detail_sales_screen.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  List<Map<String, dynamic>> filteredSales = [];

  final TextEditingController searchC = TextEditingController();

  DateTime? selectedDate;

  List<Map<String, dynamic>> sales = [];

  bool isLoading = true;

  double totalNetto1 = 0;
  double totalNetto2 = 0;
  double totalBiayaBeli = 0;

  int totalTransaksi = 0;

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    final data = await DatabaseHelper.instance.getSalesTransactions();

    double totalNetto1Temp = 0;
    double totalNetto2Temp = 0;
    double totalBiayaTemp = 0;

    for (final item in data) {
      final netto1 = ((item['netto'] ?? 0) as num).toDouble();

      final grading = ((item['grading'] ?? 0) as num).toDouble();

      final harga = ((item['harga_jual'] ?? 0) as num).toDouble();

      final netto2 = netto1 - ((netto1 * grading) / 100);

      final biayaBeli = netto2 * harga;

      totalNetto1Temp += netto1;

      totalNetto2Temp += netto2;

      totalBiayaTemp += biayaBeli;
    }

    if (!mounted) return;

    setState(() {
      sales = data;
      filteredSales = data;

      totalTransaksi = data.length;
      totalNetto1 = totalNetto1Temp;

      totalNetto2 = totalNetto2Temp;

      totalBiayaBeli = totalBiayaTemp;

      isLoading = false;
    });
  }

  void filterData() {
    setState(() {
      filteredSales = sales.where((item) {
        final supir = item['supir']?.toString().toLowerCase() ?? '';

        final search = searchC.text.toLowerCase();

        bool matchSupir = supir.contains(search);

        bool matchTanggal = true;

        if (selectedDate != null) {
          final tanggal = item['tanggal']?.toString() ?? '';

          final filterDate =
              "${selectedDate!.day.toString().padLeft(2, '0')}-"
              "${selectedDate!.month.toString().padLeft(2, '0')}-"
              "${selectedDate!.year}";

          matchTanggal = tanggal.contains(filterDate);
        }

        return matchSupir && matchTanggal;
      }).toList();
    });
  }

  String rupiah(num value) {
    return toCurrencyString(
      value.toStringAsFixed(0),
      thousandSeparator: ThousandSeparator.Period,
      mantissaLength: 0,
    );
  }

  String initials(String name) {
    if (name.trim().isEmpty) return "?";

    final parts = name.trim().split(' ');

    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

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
              "Riwayat Penjualan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 4),

            Text(
              "Penjualan TBS ke Pabrik",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadSales,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                children: [
                  _buildFilter(),

                  const SizedBox(height: 16),

                  _buildSummary(),

                  const SizedBox(height: 20),

                  _buildInputButton(),

                  const SizedBox(height: 24),

                  const Text(
                    "Daftar Pengiriman TBS",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 8),

                  if (filteredSales.isEmpty)
                    _buildEmpty()
                  else
                    ...filteredSales.map(_buildItem),
                ],
              ),
            ),
    );
  }

  Widget _buildFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchC,
            onChanged: (_) => filterData(),
            decoration: InputDecoration(
              hintText: "Cari supir...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime(2035),
            );

            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });

              filterData();
            }
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),

            child: Row(
              children: [
                const Icon(Icons.date_range_rounded, color: Colors.grey),

                if (selectedDate != null) ...[
                  const SizedBox(width: 6),

                  Text(
                    "${selectedDate!.day.toString().padLeft(2, '0')}/"
                    "${selectedDate!.month.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],

                if (selectedDate != null) ...[
                  const SizedBox(width: 6),

                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedDate = null;
                      });

                      filterData();
                    },
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  Widget _buildSummary() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: "Total Bruto",
                value: "${rupiah(totalNetto1)} Kg",
                icon: Icons.scale_rounded,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _summaryCard(
                title: "Total Transaksi",
                value: "$totalTransaksi",
                icon: Icons.receipt_long_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: "Total Netto",
                value: "${rupiah(totalNetto2)} Kg",
                icon: Icons.inventory_2_rounded,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _summaryCard(
                title: "Sub Total",
                value: "Rp ${rupiah(totalBiayaBeli)}",
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      height: 72,

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,

            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: AppColors.primary, size: 22),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,

      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InputSalesScreen()),
          );

          if (result == true) {
            loadSales();
          }
        },

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text(
          "INPUT TBS PENJUALAN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final supir = item['supir']?.toString() ?? '';

    final netto1 = ((item['netto'] ?? 0) as num).toDouble();

    return InkWell(
      borderRadius: BorderRadius.circular(22),

      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailSalesScreen(data: item)),
        );

        if (result == true) {
          loadSales();
        }
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),

              child: Center(
                child: Text(
                  initials(supir),

                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    supir,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item['tanggal'] ?? '',

                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Text(
                  "${rupiah(netto1)} Kg",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(40),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 12),

          Text(
            "Belum ada data penjualan",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
