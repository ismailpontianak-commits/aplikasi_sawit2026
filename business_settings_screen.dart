import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../services/database/database_helper.dart';

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  // ================= CONTROLLER =================

  final picker = ImagePicker();

  final businessC = TextEditingController();

  final ownerC = TextEditingController();

  final phoneC = TextEditingController();

  final addressC = TextEditingController();

  final cityC = TextEditingController();

  final provinceC = TextEditingController();

  final footerLine1C = TextEditingController();

  final footerLine2C = TextEditingController();

  String logoPath = '';

  bool isLoading = true;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();

    loadSettings();
  }

  // ================= LOAD SETTINGS =================

  Future<void> loadSettings() async {
    try {
      final data = await DatabaseHelper.instance.getSettings();

      if (data != null) {
        businessC.text = data['business_name'] ?? '';

        ownerC.text = data['owner_name'] ?? '';

        phoneC.text = data['phone'] ?? '';

        addressC.text = data['address'] ?? '';

        cityC.text = data['city'] ?? '';

        provinceC.text = data['province'] ?? '';

        footerLine1C.text = data['footer_line1'] ?? '';

        footerLine2C.text = data['footer_line2'] ?? '';

        logoPath = data['logo_path'] ?? '';
      }
    } catch (e) {
      debugPrint('LOAD SETTINGS ERROR: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickLogo() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,

        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          logoPath = picked.path;
        });
      }
    } catch (e) {
      debugPrint('PICK IMAGE ERROR: $e');
    }
  }

  // ================= SAVE SETTINGS =================

  Future<void> saveSettings() async {
    if (businessC.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama usaha wajib diisi")));

      return;
    }

    try {
      final settings = await DatabaseHelper.instance.getSettings();

      await DatabaseHelper.instance.updateSettings(
        businessName: businessC.text,
        ownerName: ownerC.text,
        phone: phoneC.text,
        address: addressC.text,
        city: cityC.text,
        province: provinceC.text,
        logoPath: logoPath,
        footerLine1: footerLine1C.text,
        footerLine2: footerLine2C.text,

        printerName: settings?['printer_name'] ?? '',
        printerAddress: settings?['printer_address'] ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengaturan berhasil disimpan")),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('SAVE SETTINGS ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan pengaturan")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      appBar: AppBar(
        elevation: 0,

        backgroundColor: const Color(0xFF3568C9),

        title: const Text(
          "Profil Usaha",

          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // ================= FORM =================
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),

                      child: Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: Column(
                          children: [
                            // ================= LOGO =================
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: pickLogo,

                                    child: Container(
                                      width: 110,
                                      height: 110,

                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),

                                        shape: BoxShape.circle,

                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                        ),
                                      ),

                                      child: logoPath.isNotEmpty
                                          ? ClipOval(
                                              child: Image.file(
                                                File(logoPath),

                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.storefront_rounded,

                                              size: 38,

                                              color: Color(0xFF3568C9),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  TextButton(
                                    onPressed: pickLogo,

                                    child: const Text("Pilih Logo Usaha"),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ================= FORM =================
                            buildField(
                              controller: businessC,

                              label: "Nama Usaha",
                            ),

                            const SizedBox(height: 16),

                            buildField(
                              controller: ownerC,

                              label: "Nama Pemilik",
                            ),

                            const SizedBox(height: 16),

                            buildField(
                              controller: phoneC,

                              label: "No Telepon",

                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 16),

                            buildField(
                              controller: addressC,

                              label: "Alamat",

                              maxLines: 2,
                            ),

                            const SizedBox(height: 16),

                            buildField(controller: cityC, label: "Kota"),

                            const SizedBox(height: 16),

                            buildField(
                              controller: provinceC,

                              label: "Provinsi",
                            ),

                            const SizedBox(height: 16),

                            buildField(
                              controller: footerLine1C,

                              label: "Footer Nota Baris 1",
                            ),

                            const SizedBox(height: 16),

                            buildField(
                              controller: footerLine2C,

                              label: "Footer Nota Baris 2",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ================= BUTTON =================
                  SafeArea(
                    top: false,

                    child: Container(
                      color: Colors.white,

                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),

                      child: SizedBox(
                        width: double.infinity,
                        height: 52,

                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3568C9),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),

                          onPressed: saveSettings,

                          icon: const Icon(
                            Icons.save_rounded,
                            color: Colors.white,
                          ),

                          label: const Text(
                            "Simpan Pengaturan",

                            style: TextStyle(
                              color: Colors.white,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ================= FIELD =================

  Widget buildField({
    required TextEditingController controller,

    required String label,

    int maxLines = 1,

    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,

      maxLines: maxLines,

      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,

        filled: true,

        fillColor: const Color(0xFFF7F8FA),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    businessC.dispose();
    ownerC.dispose();
    phoneC.dispose();
    addressC.dispose();
    cityC.dispose();
    provinceC.dispose();
    footerLine1C.dispose();
    footerLine2C.dispose();

    super.dispose();
  }
}
