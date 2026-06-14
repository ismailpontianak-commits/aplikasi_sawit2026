import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterService {
  static final BlueThermalPrinter printer = BlueThermalPrinter.instance;

  // ================= GET DEVICES =================

  static Future<List<BluetoothDevice>> getDevices() async {
    return await printer.getBondedDevices();
  }

  // ================= CONNECT =================

  static Future<bool> connect(BluetoothDevice device) async {
    try {
      bool? connected = await printer.isConnected;

      if (connected == true) {
        return true;
      }

      await printer.connect(device);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ================= DISCONNECT =================

  static Future disconnect() async {
    await printer.disconnect();
  }

  // ================= STATUS =================

  static Future<bool> isConnected() async {
    return await printer.isConnected ?? false;
  }
}
