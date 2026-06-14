import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../database/database_helper.dart';

enum PrinterStatus {
  connected,
  disconnected,
  bluetoothOff,
  printerNotFound,
  connectionFailed,
}

class ThermalPrinterService {
  static final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // =====================================================
  // ================= BLUETOOTH =========================
  // =====================================================

  static Future<bool> isBluetoothOn() async {
    try {
      return await bluetooth.isOn ?? false;
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // ================= CONNECTION ========================
  // =====================================================

  static Future<bool> isPrinterConnected() async {
    try {
      return await bluetooth.isConnected ?? false;
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // ================= SAVED PRINTER =====================
  // =====================================================

  static Future<BluetoothDevice?> getSavedPrinter() async {
    final settings = await DatabaseHelper.instance.getSettings();

    if (settings == null) {
      return null;
    }

    final printerAddress = settings['printer_address']?.toString() ?? '';

    if (printerAddress.isEmpty) {
      return null;
    }

    final devices = await bluetooth.getBondedDevices();

    for (var d in devices) {
      if (d.address == printerAddress) {
        return d;
      }
    }

    return null;
  }

  // =====================================================
  // ================= SMART CONNECT =====================
  // =====================================================

  static Future<PrinterStatus> ensurePrinterConnected() async {
    // ================= BLUETOOTH =================

    final bluetoothOn = await isBluetoothOn();

    if (!bluetoothOn) {
      return PrinterStatus.bluetoothOff;
    }

    // ================= DEVICE =================

    final device = await getSavedPrinter();

    if (device == null) {
      return PrinterStatus.printerNotFound;
    }

    // ================= CONNECTED =================

    final connected = await isPrinterConnected();

    if (connected) {
      try {
        await bluetooth.disconnect();
      } catch (_) {}
    }

    // ================= CONNECT =================

    try {
      try {
        await bluetooth.disconnect();
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 500));

      await bluetooth.connect(device);

      await Future.delayed(const Duration(seconds: 2));

      final nowConnected = await isPrinterConnected();

      if (nowConnected) {
        return PrinterStatus.connected;
      } else {
        return PrinterStatus.connectionFailed;
      }
    } catch (e) {
      return PrinterStatus.connectionFailed;
    }
  }

  // =====================================================
  // ================= PRINT TRANSACTION =================
  // =====================================================

  static Future<void> printTransaction({
    required Map<String, dynamic> trx,
  }) async {
    final settings = await DatabaseHelper.instance.getSettings();

    if (settings == null) return;

    final printerAddress = settings['printer_address']?.toString() ?? '';

    if (printerAddress.isEmpty) {
      throw Exception("Printer belum dipilih");
    }

    // =====================================================
    // ================= SMART CONNECTION ==================
    // =====================================================

    final status = await ensurePrinterConnected();

    if (status == PrinterStatus.bluetoothOff) {
      throw Exception("Bluetooth belum aktif");
    }

    if (status == PrinterStatus.printerNotFound) {
      throw Exception("Printer tidak ditemukan");
    }

    if (status == PrinterStatus.connectionFailed) {
      throw Exception("Gagal menghubungkan printer");
    }

    // =====================================================
    // ================= FORMATTER =========================
    // =====================================================

    String rupiah(num value) {
      return value
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    }

    String kg(num value) {
      return value
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    }

    // =====================================================
    // ================= DATA ==============================
    // =====================================================

    final bruto =
        double.tryParse((trx['bruto'] ?? trx['netto'] ?? 0).toString()) ?? 0;

    final grading = double.tryParse(trx['grading'].toString()) ?? 0;

    final harga = double.tryParse(trx['harga'].toString()) ?? 0;

    final potongAngkut = double.tryParse(trx['potongAngkut'].toString()) ?? 0;

    final potongLain = double.tryParse(trx['potongLain'].toString()) ?? 0;

    // =====================================================
    // ================= HITUNG ============================
    // =====================================================

    final netto = bruto - ((bruto * grading) / 100);

    final subtotal = netto * harga;

    final totalBayar = subtotal - potongAngkut - potongLain;

    // =====================================================
    // ================= HEADER ============================
    // =====================================================

    bluetooth.printNewLine();

    bluetooth.printCustom(settings['business_name'] ?? 'RAMP INDPARLOH', 2, 1);

    bluetooth.printCustom(settings['address'] ?? '', 0, 1);

    bluetooth.printCustom("WhatsApp ${settings['phone'] ?? ''}", 0, 1);

    bluetooth.printCustom("--------------------------------", 0, 1);

    // =====================================================
    // ================= PELANGGAN =========================
    // =====================================================

    bluetooth.printCustom("PELANGGAN / PETANI", 1, 0);

    bluetooth.printLeftRight("Pelanggan", trx['pelanggan'].toString(), 0);

    bluetooth.printLeftRight("Alamat", trx['alamat'].toString(), 0);

    bluetooth.printLeftRight("Produk", trx['kebun'].toString(), 0);

    bluetooth.printLeftRight("Tanggal", trx['tanggal'].toString(), 0);

    bluetooth.printCustom("--------------------------------", 0, 1);

    // =====================================================
    // ================= DETAIL ============================
    // =====================================================

    bluetooth.printCustom("DETAIL TRANSAKSI", 1, 0);

    bluetooth.printLeftRight("Bruto", "${kg(bruto)} Kg", 0);

    bluetooth.printLeftRight(
      "Grading",
      "${grading % 1 == 0 ? grading.toInt() : grading} %",
      0,
    );

    bluetooth.printLeftRight("Netto", "${kg(netto)} Kg", 0);

    bluetooth.printLeftRight("Harga / Kg", "Rp ${rupiah(harga)}", 0);

    bluetooth.printLeftRight("Sub Total", "Rp ${rupiah(subtotal)}", 0);

    bluetooth.printCustom("--------------------------------", 0, 1);

    // =====================================================
    // ================= POTONGAN ==========================

    if (potongAngkut > 0 || potongLain > 0) {
      bluetooth.printCustom("POTONGAN", 1, 0);

      if (potongAngkut > 0) {
        bluetooth.printLeftRight(
          "Pot. Angkut",
          "Rp ${rupiah(potongAngkut)}",
          0,
        );
      }

      if (potongLain > 0) {
        bluetooth.printLeftRight("Pot. Lain", "Rp ${rupiah(potongLain)}", 0);
      }

      bluetooth.printCustom("--------------------------------", 0, 1);
    }

    // =====================================================
    // ================= TOTAL =============================
    // =====================================================

    bluetooth.printCustom("TOTAL BAYAR", 1, 0);

    bluetooth.printCustom("Rp ${rupiah(totalBayar)}", 2, 0);

    bluetooth.printCustom("--------------------------------", 0, 1);

    bluetooth.printNewLine();

    // =====================================================
    // ================= FOOTER ============================
    // =====================================================

    final footer = settings['footer_line1']?.toString() ?? '';
    final footer2 = settings['footer_line2']?.toString() ?? '';

    if (footer.isNotEmpty) {
      bluetooth.printCustom(footer, 1, 1);
    }

    if (footer2.isNotEmpty) {
      bluetooth.printCustom(footer2, 1, 1);
    }

    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.printNewLine();

    await Future.delayed(const Duration(seconds: 2));
  }
}
