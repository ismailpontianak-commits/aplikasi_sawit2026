import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = int.tryParse(newValue.text.replaceAll('.', ''));

    if (number == null) {
      return oldValue;
    }

    final formatted = NumberFormat(
      '#,###',
      'id_ID',
    ).format(number).replaceAll(',', '.');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
