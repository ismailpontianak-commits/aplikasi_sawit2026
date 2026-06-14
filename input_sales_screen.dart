import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../services/database/database_helper.dart';
import '../core/constants/app_colors.dart';
import '../models/sales_transaction_model.dart';

class InputSalesScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const InputSalesScreen({super.key, this.data});

  @override
  State<InputSalesScreen> createState() => _InputSalesScreenState();
}

class _InputSalesScreenState extends State<InputSalesScreen> {
  final nettoC = TextEditingController();

  final gradingC = TextEditingController();

  final hargaC = TextEditingController();

  final tanggalC = TextEditingController();

  final supirC = TextEditingController();

  final nomorKendaraanC = TextEditingController();

  final pabrikTujuanC = TextEditingController();

  final solarC = TextEditingController();
  final upahMuatC = TextEditingController();
  final upahSupirC = TextEditingController();
  final biayaLainC = TextEditingController();

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
        widget.data!['harga_jual'].toString().replaceAll('.0', ''),

        thousandSeparator: ThousandSeparator.Period,

        mantissaLength: 0,
      );

      tanggalC.text = widget.data!['tanggal'].toString();

      supirC.text = capitalizeWords(widget.data!['supir'].toString());

      nomorKendaraanC.text = widget.data!['nomor_kendaraan'].toString();

      pabrikTujuanC.text = capitalizeWords(
        widget.data!['pabrik_tujuan'].toString(),
      );

      solarC.text = toCurrencyString(
        widget.data!['solar'].toString().replaceAll('.0', ''),

        thousandSeparator: ThousandSeparator.Period,

        mantissaLength: 0,
      );
      upahMuatC.text = toCurrencyString(
        widget.data!['upah_muat'].toString().replaceAll('.0', ''),

        thousandSeparator: ThousandSeparator.Period,

        mantissaLength: 0,
      );

      upahSupirC.text = toCurrencyString(
        widget.data!['upah_supir'].toString().replaceAll('.0', ''),

        thousandSeparator: ThousandSeparator.Period,

        mantissaLength: 0,
      );

      biayaLainC.text = toCurrencyString(
        widget.data!['biaya_lain'].toString().replaceAll('.0', ''),
        thousandSeparator: ThousandSeparator.Period,
        mantissaLength: 0,
      );
    }

    supirC.addListener(() {
      final text = capitalizeWords(supirC.text);

      if (supirC.text != text) {
        supirC.value = supirC.value.copyWith(
          text: text,

          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });

    pabrikTujuanC.addListener(() {
      final text = capitalizeWords(pabrikTujuanC.text);

      if (pabrikTujuanC.text != text) {
        pabrikTujuanC.value = pabrikTujuanC.value.copyWith(
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
          widget.data != null ? "Edit Penjualan" : "Input TBS Penjualan",

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
              // ================= TOP FIELD =================
              Row(
                children: [
                  Expanded(
                    child: topField(
                      controller: nettoC,

                      icon: Icons.scale_rounded,

                      hint: "Netto (Kg)",

                      keyboardType: TextInputType.number,

                      inputFormatters: [
                        CurrencyInputFormatter(
                          thousandSeparator: ThousandSeparator.Period,

                          mantissaLength: 0,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

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

              const SizedBox(height: 12),

              // ================= HARGA =================
              bigField(
                controller: hargaC,

                icon: Icons.payments_rounded,

                hint: "Harga / Kg",
              ),

              const SizedBox(height: 18),

              // ================= FORM =================
              formField(
                controller: tanggalC,

                icon: Icons.calendar_month_rounded,

                hint: "12 Mei 2026",

                suffixIcon: Icons.calendar_today_rounded,

                readOnly: true,

                onTap: pickDate,
              ),

              const SizedBox(height: 12),

              formField(
                controller: supirC,

                icon: Icons.person_rounded,

                hint: "Nama Supir",

                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 12),

              formField(
                controller: nomorKendaraanC,

                icon: Icons.location_on_rounded,

                hint: "Nomor Kendaraan",

                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 12),

              formField(
                controller: pabrikTujuanC,

                icon: Icons.inventory_2_rounded,

                hint: "Pabrik Tujuan",

                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 12),

              formField(
                controller: solarC,

                icon: Icons.local_shipping_rounded,

                hint: "Solar",

                keyboardType: TextInputType.number,

                inputFormatters: [
                  CurrencyInputFormatter(
                    thousandSeparator: ThousandSeparator.Period,

                    mantissaLength: 0,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              formField(
                controller: upahMuatC,

                icon: Icons.remove_circle_rounded,

                hint: "Upah Muat",

                keyboardType: TextInputType.number,

                inputFormatters: [
                  CurrencyInputFormatter(
                    thousandSeparator: ThousandSeparator.Period,

                    mantissaLength: 0,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              formField(
                controller: upahSupirC,
                icon: Icons.person_rounded,
                hint: "Upah Supir",
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyInputFormatter(
                    thousandSeparator: ThousandSeparator.Period,
                    mantissaLength: 0,
                  ),
                ],
              ),

              const SizedBox(height: 12),
              formField(
                controller: biayaLainC,
                icon: Icons.attach_money_rounded,
                hint: "Biaya Lain",
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyInputFormatter(
                    thousandSeparator: ThousandSeparator.Period,
                    mantissaLength: 0,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ================= INFO =================
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF3568C8)),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        "Pastikan data transaksi sudah benar sebelum disimpan",

                        style: TextStyle(
                          color: Colors.blue.shade700,

                          fontSize: 13,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,

                height: 54,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3568C8),

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  onPressed: saveData,

                  child: Text(
                    widget.data != null ? "Update" : "Simpan",

                    style: const TextStyle(
                      color: Colors.white,

                      fontWeight: FontWeight.w700,

                      fontSize: 19,
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
      height: 60,

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
  }) {
    return Container(
      height: 64,

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

              keyboardType: TextInputType.number,

              inputFormatters: [
                CurrencyInputFormatter(
                  thousandSeparator: ThousandSeparator.Period,

                  mantissaLength: 0,
                ),
              ],

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
      height: 64,

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

    if (supirC.text.isEmpty ||
        nomorKendaraanC.text.isEmpty ||
        pabrikTujuanC.text.isEmpty ||
        nettoC.text.isEmpty ||
        gradingC.text.isEmpty ||
        hargaC.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data wajib diisi")));

      return;
    }

    final netto = double.tryParse(nettoC.text.replaceAll('.', '')) ?? 0;

    final hargaJual = double.tryParse(hargaC.text.replaceAll('.', '')) ?? 0;

    final solar = double.tryParse(solarC.text.replaceAll('.', '')) ?? 0;

    final upahMuat = double.tryParse(upahMuatC.text.replaceAll('.', '')) ?? 0;

    final upahSupir = double.tryParse(upahSupirC.text.replaceAll('.', '')) ?? 0;

    final biayaLain = double.tryParse(biayaLainC.text.replaceAll('.', '')) ?? 0;

    final subtotal = netto * hargaJual;

    final totalBiaya = solar + upahMuat + upahSupir + biayaLain;

    final totalBersih = subtotal - totalBiaya;

    final trx = SalesTransactionModel(
      tanggal: tanggalC.text,

      supir: supirC.text,
      nomorKendaraan: nomorKendaraanC.text,
      pabrikTujuan: pabrikTujuanC.text,

      netto: netto,

      grading: double.tryParse(gradingC.text.replaceAll(',', '.')) ?? 0,

      hargaJual: hargaJual,

      solar: solar,
      upahMuat: upahMuat,
      upahSupir: upahSupir,
      biayaLain: biayaLain,

      subtotal: subtotal,
      totalBiaya: totalBiaya,
      totalBersih: totalBersih,
    );

    if (widget.data != null) {
      await DatabaseHelper.instance.updateSalesTransaction(
        widget.data!['id'],
        trx.toMap(),
      );
    } else {
      await DatabaseHelper.instance.insertSalesTransaction(trx.toMap());
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    tanggalC.dispose();
    supirC.dispose();
    nomorKendaraanC.dispose();
    pabrikTujuanC.dispose();
    nettoC.dispose();
    gradingC.dispose();
    hargaC.dispose();
    solarC.dispose();
    upahMuatC.dispose();
    upahSupirC.dispose();
    biayaLainC.dispose();

    super.dispose();
  }
}
