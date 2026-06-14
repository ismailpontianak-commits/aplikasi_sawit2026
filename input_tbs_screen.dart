import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../models/transaction_model.dart';
import '../services/database/database_helper.dart';
import '../core/constants/app_colors.dart';
import 'detail_transaction_screen.dart';
import '../core/utils/thousand_formatter.dart';

class InputTBSScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const InputTBSScreen({super.key, this.data});

  @override
  State<InputTBSScreen> createState() => _InputTBSScreenState();
}

class _InputTBSScreenState extends State<InputTBSScreen> {
  final nettoC = TextEditingController();

  final gradingC = TextEditingController();

  final hargaC = TextEditingController();

  final tanggalC = TextEditingController();

  final pelangganC = TextEditingController();

  final alamatC = TextEditingController();

  final kebunC = TextEditingController();

  final potongAngkutC = TextEditingController();

  final potongLainC = TextEditingController();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    tanggalC.text =
        "${now.day.toString().padLeft(2, '0')}"
        "-${now.month.toString().padLeft(2, '0')}"
        "-${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";

    if (widget.data != null) {
      nettoC.text = toCurrencyString(
        widget.data!['netto'].toString().replaceAll('.0', ''),

        thousandSeparator: ThousandSeparator.Period,

        mantissaLength: 0,
      );

      gradingC.text = widget.data!['grading'].toString();

      hargaC.text = toCurrencyString(
        widget.data!['harga'].toString().replaceAll('.0', ''),

        thousandSeparator: ThousandSeparator.Period,

        mantissaLength: 0,
      );

      tanggalC.text = widget.data!['tanggal'].toString();

      pelangganC.text = capitalizeWords(widget.data!['pelanggan'].toString());

      alamatC.text = capitalizeWords(widget.data!['alamat'].toString());

      kebunC.text = capitalizeWords(widget.data!['kebun'].toString());

      potongAngkutC.text = toCurrencyString(
        widget.data!['potongAngkut'].toString().replaceAll('.0', ''),

        thousandSeparator: ThousandSeparator.Period,

        mantissaLength: 0,
      );

      potongLainC.text = toCurrencyString(
        widget.data!['potongLain'].toString().replaceAll('.0', ''),

        thousandSeparator: ThousandSeparator.Period,

        mantissaLength: 0,
      );
    }

    pelangganC.addListener(() {
      final text = capitalizeWords(pelangganC.text);

      if (pelangganC.text != text) {
        pelangganC.value = pelangganC.value.copyWith(
          text: text,

          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });

    alamatC.addListener(() {
      final text = capitalizeWords(alamatC.text);

      if (alamatC.text != text) {
        alamatC.value = alamatC.value.copyWith(
          text: text,

          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });

    kebunC.addListener(() {
      final text = capitalizeWords(kebunC.text);

      if (kebunC.text != text) {
        kebunC.value = kebunC.value.copyWith(
          text: text,

          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  // ================= CAPITALIZE =================

  String capitalizeWords(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return '';
          }

          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // ================= DATE PICKER =================

  Future<void> pickDate() async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();

    DateTime initialDate = now;

    try {
      final dateOnly = tanggalC.text.split(' ')[0];

      final split = dateOnly.split('-');

      initialDate = DateTime(
        int.parse(split[2]),
        int.parse(split[1]),
        int.parse(split[0]),
      );
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,

      initialDate: initialDate,

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),

      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),

          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final now = DateTime.now();

        tanggalC.text =
            "${picked.day.toString().padLeft(2, '0')}"
            "-${picked.month.toString().padLeft(2, '0')}"
            "-${picked.year} "
            "${now.hour.toString().padLeft(2, '0')}:"
            "${now.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,

        elevation: 0,

        title: Text(
          widget.data != null ? "Edit Transaksi" : "Input Masuk TBS",

          style: const TextStyle(
            color: Colors.white,

            fontWeight: FontWeight.w700,

            fontSize: 19,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            MediaQuery.of(context).viewInsets.bottom + 120,
          ),

          child: Column(
            children: [
              sectionTitle("PELANGGAN / PETANI"),
              // ================= TANGGAL =================
              formField(
                controller: tanggalC,
                icon: Icons.calendar_month_rounded,
                hint: "Tanggal & Waktu Timbang",
                readOnly: true,
                onTap: pickDate,
              ),

              const SizedBox(height: 12),

              // ================= PELANGGAN =================
              formField(
                controller: pelangganC,
                icon: Icons.person_rounded,
                hint: "Pelanggan / Petani",
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 12),

              // ================= ALAMAT =================
              formField(
                controller: alamatC,
                icon: Icons.location_on_rounded,
                hint: "Alamat",
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 12),

              // ================= PRODUK =================
              formField(
                controller: kebunC,
                icon: Icons.inventory_2_rounded,
                hint: "Produk / Asal Kebun",
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),
              sectionTitle("DATA TIMBANGAN"),

              // ================= CARD TIMBANGAN =================
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Color(0xFFEFF5FF).withValues(alpha: 0.6),
                  border: Border.all(color: Color(0xFFD1D5DB), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  children: [
                    topField(
                      controller: nettoC,
                      icon: Icons.scale_rounded,
                      hint: "Bruto",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandFormatter(),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: bigField(
                            controller: hargaC,
                            icon: Icons.payments_rounded,
                            hint: "Harga / Kg",
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ThousandFormatter(),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: topField(
                            controller: gradingC,
                            icon: Icons.percent_rounded,
                            hint: "Grading",
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,2}([.,]\d{0,1})?$'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              sectionTitle("POTONGAN"),
              // ================= POTONGAN =================
              Row(
                children: [
                  Expanded(
                    child: formField(
                      controller: potongAngkutC,
                      icon: Icons.local_shipping_rounded,
                      hint: "Angkutan",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandFormatter(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: formField(
                      controller: potongLainC,
                      icon: Icons.remove_circle_rounded,
                      hint: "Lainnya",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandFormatter(),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ================= INFO =================
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      "Pastikan semua data sudah benar sebelum disimpan",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: saveData,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: Text(
                    widget.data != null ? "Update Transaksi" : "Simpan",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOP FIELD =================

  Widget topField({
    required TextEditingController controller,

    required IconData icon,

    required String hint,

    TextInputType? keyboardType,

    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 56,

      padding: const EdgeInsets.symmetric(horizontal: 18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),

            blurRadius: 6,

            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3568C8), size: 24),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: controller,

              cursorColor: const Color(0xFF3568C8),

              keyboardType: keyboardType,

              inputFormatters: inputFormatters,

              style: const TextStyle(
                fontSize: 15,

                fontWeight: FontWeight.w600,

                color: Color(0xFF111827),
              ),

              decoration: InputDecoration(
                border: InputBorder.none,

                hintText: hint,

                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),

                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BIG FIELD =================

  Widget bigField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,

    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 56,

      padding: const EdgeInsets.symmetric(horizontal: 18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),

            blurRadius: 6,

            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3568C8), size: 24),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: controller,

              cursorColor: const Color(0xFF3568C8),

              keyboardType: keyboardType,

              inputFormatters: inputFormatters,

              style: const TextStyle(
                fontSize: 15,

                fontWeight: FontWeight.w600,

                color: Color(0xFF111827),
              ),

              decoration: InputDecoration(
                border: InputBorder.none,

                hintText: hint,

                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),

                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FORM FIELD =================

  Widget formField({
    required TextEditingController controller,

    required IconData icon,

    required String hint,

    IconData? suffixIcon,

    TextInputType? keyboardType,

    bool readOnly = false,

    VoidCallback? onTap,

    List<TextInputFormatter>? inputFormatters,

    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      height: 56,

      padding: const EdgeInsets.symmetric(horizontal: 18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),

            blurRadius: 10,

            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),

          const SizedBox(width: 14),

          Expanded(
            child: TextField(
              controller: controller,

              onTap: onTap,

              cursorColor: AppColors.primary,

              keyboardType: keyboardType,

              readOnly: readOnly,

              inputFormatters: inputFormatters,

              textCapitalization: textCapitalization,

              style: const TextStyle(
                fontSize: 15,

                fontWeight: FontWeight.w600,

                color: Color(0xFF111827),
              ),

              decoration: InputDecoration(
                border: InputBorder.none,

                hintText: hint,

                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),

                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          if (suffixIcon != null)
            Icon(suffixIcon, color: Colors.black54, size: 24),
        ],
      ),
    );
  }

  // ================= SAVE =================

  Future<void> saveData() async {
    FocusScope.of(context).unfocus();

    if (pelangganC.text.trim().isEmpty ||
        alamatC.text.trim().isEmpty ||
        kebunC.text.trim().isEmpty ||
        nettoC.text.trim().isEmpty ||
        gradingC.text.trim().isEmpty ||
        hargaC.text.trim().isEmpty ||
        potongAngkutC.text.trim().isEmpty ||
        potongLainC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data belum lengkap, mohon isi semua kolom"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final data = TransactionModel(
      pelanggan: pelangganC.text,

      alamat: alamatC.text,

      kebun: kebunC.text,

      potongAngkut: potongAngkutC.text.isEmpty
          ? "0"
          : toNumericString(potongAngkutC.text),

      potongLain: potongLainC.text.isEmpty
          ? "0"
          : toNumericString(potongLainC.text),

      netto: double.tryParse(toNumericString(nettoC.text)) ?? 0,

      grading: double.tryParse(gradingC.text.replaceAll(',', '.')) ?? 0,

      harga: double.tryParse(toNumericString(hargaC.text)) ?? 0,

      tanggal: tanggalC.text,
    );

    if (widget.data != null) {
      await DatabaseHelper.instance.updateTransaction(
        widget.data!['id'],
        data.toMap(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } else {
      final id = await DatabaseHelper.instance.insertTransaction(data.toMap());

      final trx = {'id': id, ...data.toMap()};

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailTransactionScreen(data: trx),
        ),
      );
    }
  }

  @override
  void dispose() {
    nettoC.dispose();
    gradingC.dispose();
    hargaC.dispose();

    tanggalC.dispose();
    pelangganC.dispose();
    alamatC.dispose();
    kebunC.dispose();

    potongAngkutC.dispose();
    potongLainC.dispose();

    super.dispose();
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),

            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),

          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        ],
      ),
    );
  }
}
