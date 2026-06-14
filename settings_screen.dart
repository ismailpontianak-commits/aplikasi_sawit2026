import 'package:flutter/material.dart';

import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

import 'business_settings_screen.dart';
import 'printer_settings_screen.dart';
import '../services/database/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String printerName = '';

  @override
  void initState() {
    super.initState();
    _loadPrinterName();
  }

  Future<void> _loadPrinterName() async {
    final settings = await DatabaseHelper.instance.getSettings();
    setState(() {
      printerName = settings?['printer_name'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF3568C9),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Pengaturan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),

            Text(
              "Konfigurasi Aplikasi",
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ================= USAHA =================
            SettingsSection(
              children: [
                SettingsTile(
                  icon: Icons.storefront_rounded,

                  title: "Profil Usaha",

                  subtitle: "Identitas & Informasi Usaha",

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => const BusinessSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ================= PRINTER =================
            SettingsSection(
              children: [
                SettingsTile(
                  icon: Icons.bluetooth,

                  title: "Printer / Bluetooth",

                  subtitle: printerName.isEmpty ? "Belum dipilih" : printerName,

                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrinterSettingsScreen(),
                      ),
                    );

                    _loadPrinterName();
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ================= SYSTEM =================
            SettingsSection(
              children: [
                SettingsTile(
                  icon: Icons.info_outline_rounded,

                  title: "Tentang Aplikasi",

                  subtitle: "Versi 1.0.0",

                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
