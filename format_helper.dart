import 'package:intl/intl.dart';

class FormatHelper {
  static String rupiah(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  static String kg(num value) {
    return NumberFormat('#,##0', 'id_ID').format(value);
  }

  static String date(String value) {
    try {
      final date = DateFormat('dd-MM-yyyy').parse(value);

      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return value;
    }
  }

  static String dateTime(DateTime value) {
    return DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(value);
  }

  static String shortCurrency(double value) {
    // MILIAR
    if (value >= 1000000000) {
      return "${(value / 1000000000).toStringAsFixed(1).replaceAll('.', ',')} M";
    }

    // JUTA
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1).replaceAll('.', ',')} Jt";
    }

    // RIBU
    if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(0)} Rb";
    }

    return value.toStringAsFixed(0);
  }

  //=====Total Pembelian====

  static String totalPembelian(num value) {
    return "Rp ${NumberFormat('#,##0', 'id_ID').format(value)}";
  }

  //=====Total Penjualan====
  static String totalPenjualan(num value) {
    return "Rp ${NumberFormat('#,##0', 'id_ID').format(value)}";
  }

  //=====Total Laba====
  static String totalLaba(num value) {
    return "Rp ${NumberFormat('#,##0', 'id_ID').format(value)}";
  }

  //=====Total Transaksi====
  static String totalTransaksi(num value) {
    return value.toStringAsFixed(0);
  }
}
