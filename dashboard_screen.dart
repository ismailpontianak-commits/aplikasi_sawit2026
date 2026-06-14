import 'package:flutter/material.dart';

import '../core/utils/format_helper.dart';
import '../services/database/database_helper.dart';

import '../widgets/transaction_item.dart';
import '../widgets/summary_card.dart';
import '../core/constants/app_colors.dart';

import 'history_screen.dart';
import 'input_tbs_screen.dart';
import 'detail_transaction_screen.dart';
import 'settings_screen.dart';
import 'sales_history_screen.dart';

import 'report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> transactions = [];
  Map<String, dynamic>? settings;

  @override
  void initState() {
    super.initState();

    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await DatabaseHelper.instance.getTodayTransactions();

    final settingData = await DatabaseHelper.instance.getSettings();

    setState(() {
      transactions = data;

      settings = settingData;
    });
  }

  double get totalBruto {
    double total = 0;

    for (var item in transactions) {
      total += double.tryParse(item['netto'].toString()) ?? 0;
    }

    return total;
  }

  double get totalNetto {
    double total = 0;

    for (var item in transactions) {
      final netto = double.tryParse(item['netto'].toString()) ?? 0;

      final grading = double.tryParse(item['grading'].toString()) ?? 0;

      final netto2 = netto - ((grading / 100) * netto);

      total += netto2;
    }

    return total;
  }

  double get totalSubtotal {
    double total = 0;

    for (var item in transactions) {
      final netto = double.tryParse(item['netto'].toString()) ?? 0;

      final grading = double.tryParse(item['grading'].toString()) ?? 0;

      final harga = double.tryParse(item['harga'].toString()) ?? 0;

      final netto2 = netto - ((grading / 100) * netto);

      total += netto2 * harga;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: SizedBox(
        width: 66,
        height: 66,

        child: FloatingActionButton(
          backgroundColor: AppColors.primary,

          elevation: 8,

          shape: const CircleBorder(),

          onPressed: () {
            showTransactionSheet(context);
          },

          child: const Icon(Icons.add_rounded, color: Colors.white, size: 38),
        ),
      ),

      body: Stack(
        children: [
          // ================= BACKGROUND BLUE =================
          Container(
            height: 220,
            width: double.infinity,

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                  AppColors.primaryDark,
                ],
              ),
            ),
          ),

          // ================= CONTENT =================
          SafeArea(
            child: Column(
              children: [
                // ================= HEADER =================
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),

                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,

                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),

                            child: const Center(
                              child: Text(
                                "RI",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
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
                                  settings?['business_name']
                                          ?.toString()
                                          .toUpperCase() ??
                                      '-',

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),

                                Text(
                                  settings?['address']?.toString() ?? '-',

                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,

                                child: IconButton(
                                  onPressed: showMainMenu,
                                  icon: const Icon(
                                    Icons.settings_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SummaryCard(
                        totalValue: "${FormatHelper.kg(totalBruto)} Kg",

                        totalLabel:
                            "Update ${TimeOfDay.now().format(context)} WIB",

                        title1: "Total Netto",
                        value1: "${FormatHelper.kg(totalNetto)} Kg",
                        icon1: Icons.scale_rounded,

                        title2: "Transaksi",
                        value2: "${transactions.length} Kali",
                        icon2: Icons.local_shipping_rounded,

                        title3: "Sub Total",
                        value3:
                            'Rp ${FormatHelper.shortCurrency(totalSubtotal)}',
                        icon3: Icons.account_balance_wallet_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ================= WHITE BODY =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 130),

                    child: Column(
                      children: [
                        const SizedBox(height: 18),

                        // ================= TRANSACTION CARD =================
                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.fromLTRB(14, 22, 14, 8),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(14),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Column(
                            children: [
                              // ================= TITLE =================
                              Row(
                                children: [
                                  const Icon(
                                    Icons.receipt_long_rounded,
                                    color: Color(0xFF3568C8),
                                    size: 18,
                                  ),

                                  const SizedBox(width: 12),

                                  const Expanded(
                                    child: Text(
                                      "Daftar Transaksi",

                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ================= LIST =================
                              transactions.isEmpty
                                  ? Column(
                                      children: [
                                        const SizedBox(height: 40),

                                        Icon(
                                          Icons.receipt_long_outlined,
                                          size: 90,
                                          color: Colors.grey.shade300,
                                        ),

                                        const SizedBox(height: 18),

                                        Text(
                                          "Belum ada transaksi hari ini",

                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(height: 40),
                                      ],
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,

                                      physics:
                                          const NeverScrollableScrollPhysics(),

                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        bottom: 12,
                                      ),

                                      itemCount: transactions.length,

                                      separatorBuilder: (_, index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),

                                        child: Divider(
                                          color: Colors.grey.shade200,
                                          height: 1,
                                        ),
                                      ),

                                      itemBuilder: (context, index) {
                                        final item = transactions[index];

                                        return InkWell(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),

                                          onTap: () async {
                                            final result = await Navigator.push(
                                              context,

                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DetailTransactionScreen(
                                                      data: item,
                                                    ),
                                              ),
                                            );

                                            await loadTransactions();

                                            if (result == true) {
                                              await loadTransactions();
                                            }
                                          },

                                          child: TransactionItem(
                                            name:
                                                item['pelanggan']?.toString() ??
                                                '',

                                            address: item['alamat'].toString(),

                                            netto:
                                                "${FormatHelper.kg(double.tryParse(item['netto'].toString()) ?? 0)} Kg",
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU =================

  void showMainMenu() {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            MediaQuery.of(context).padding.bottom + 20,
          ),

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 50,
                height: 5,

                decoration: BoxDecoration(
                  color: Colors.grey.shade300,

                  borderRadius: BorderRadius.circular(50),
                ),
              ),

              const SizedBox(height: 18),

              modernMenuItem(
                icon: Icons.history_rounded,
                title: "Riwayat Transaksi",

                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),

              modernMenuItem(
                icon: Icons.point_of_sale_rounded,

                title: "Riwayat Penjualan",

                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => const SalesHistoryScreen(),
                    ),
                  );
                },
              ),

              modernMenuItem(
                icon: Icons.bar_chart_rounded,
                title: "Laporan",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportScreen()),
                  );
                },
              ),

              modernMenuItem(
                icon: Icons.settings_rounded,
                title: "Pengaturan",
                onTap: () async {
                  Navigator.pop(context);

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );

                  await loadTransactions();

                  if (result == true) {
                    await loadTransactions();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget modernMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),

        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(icon, color: const Color(0xFF3568C8)),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM SHEET =================

  void showTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // ================= HANDLE =================
              Container(
                width: 52,
                height: 5,

                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.22),

                  borderRadius: BorderRadius.circular(50),
                ),
              ),

              const SizedBox(height: 18),

              // ================= TITLE =================
              const Text(
                "Pilih Transaksi",

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),

              const SizedBox(height: 18),

              // ================= MENU 1 =================
              transactionMenu(
                icon: Icons.download_rounded,

                title: "Input TBS Masuk",

                subtitle: "Input timbang TBS",

                onTap: () async {
                  Navigator.pop(context);

                  final result = await Navigator.push(
                    context,

                    MaterialPageRoute(builder: (_) => const InputTBSScreen()),
                  );

                  await loadTransactions();

                  if (result == true) {
                    await loadTransactions();
                  }
                },
              ),

              const SizedBox(height: 10),

              // ================= MENU 2 =================
              transactionMenu(
                icon: Icons.scale_rounded,

                title: "Input Manual",

                subtitle: "Input transaksi manual",

                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget transactionMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),

      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),

          borderRadius: BorderRadius.circular(22),
        ),

        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,

              decoration: BoxDecoration(
                color: const Color(0xFF3568C8).withValues(alpha: 0.12),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(icon, color: const Color(0xFF3568C8), size: 28),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,

                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black54,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
