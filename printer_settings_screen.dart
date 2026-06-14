import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../services/database/database_helper.dart';
import '../services/printer/thermal_printer_service.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> devices = [];

  BluetoothDevice? selectedDevice;

  bool loading = true;

  bool connected = false;

  bool bluetoothOn = true;

  Map<String, dynamic>? settings;

  @override
  void initState() {
    super.initState();

    init();
  }

  // ================= INIT =================

  Future<void> init() async {
    settings = await DatabaseHelper.instance.getSettings();
    bluetoothOn = await ThermalPrinterService.isBluetoothOn();

    List<BluetoothDevice> bonded = [];

    try {
      bonded = await bluetooth.getBondedDevices();
    } catch (e) {
      debugPrint(e.toString());
    }

    // ================= CARI DEVICE TERSIMPAN =================

    BluetoothDevice? savedDevice;

    if (settings?['printer_address'] != null &&
        settings!['printer_address'].toString().isNotEmpty) {
      for (var d in bonded) {
        if (d.address == settings!['printer_address']) {
          savedDevice = d;

          break;
        }
      }
    }

    // ================= LOAD SAVED DEVICE =================

    bool isPrinterConnected = await ThermalPrinterService.isPrinterConnected();

    setState(() {
      devices = bonded;

      selectedDevice = savedDevice;

      connected = isPrinterConnected;

      loading = false;
    });
  }

  // ================= CONNECT =================

  Future<void> connectPrinter(BluetoothDevice device) async {
    try {
      bool? isConnected = await bluetooth.isConnected;

      // ================= SUDAH CONNECT =================

      if (isConnected == true) {
        setState(() {
          connected = true;

          selectedDevice = device;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,

            content: Text("Printer sudah terhubung"),
          ),
        );

        return;
      }

      // ================= CONNECT =================

      await bluetooth.connect(device);

      // ================= SAVE SETTINGS =================

      await DatabaseHelper.instance.updateSettings(
        businessName: settings?['business_name'] ?? '',

        ownerName: settings?['owner_name'] ?? '',

        phone: settings?['phone'] ?? '',

        address: settings?['address'] ?? '',

        city: settings?['city'] ?? '',

        province: settings?['province'] ?? '',

        logoPath: settings?['logo_path'] ?? '',

        footerLine1: settings?['footer_line1'] ?? '',

        footerLine2: settings?['footer_line2'] ?? '',

        printerName: device.name ?? '',

        printerAddress: device.address ?? '',
      );

      settings = await DatabaseHelper.instance.getSettings();

      setState(() {
        selectedDevice = device;

        connected = true;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,

          content: Text("Berhasil terhubung ke ${device.name}"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint(e.toString());

      // ================= CEK LAGI =================

      bool? isConnected = await bluetooth.isConnected;

      if (isConnected == true) {
        setState(() {
          connected = true;

          selectedDevice = device;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,

            content: Text("Printer berhasil terhubung"),
          ),
        );

        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,

          content: Text("Gagal menghubungkan printer"),
        ),
      );
    }
  }

  // ================= DISCONNECT =================

  Future<void> disconnect() async {
    try {
      await bluetooth.disconnect();
    } catch (_) {}

    await DatabaseHelper.instance.updateSettings(
      businessName: settings?['business_name'] ?? '',

      ownerName: settings?['owner_name'] ?? '',

      phone: settings?['phone'] ?? '',

      address: settings?['address'] ?? '',

      city: settings?['city'] ?? '',

      province: settings?['province'] ?? '',

      logoPath: settings?['logo_path'] ?? '',

      footerLine1: settings?['footer_line1'] ?? '',

      footerLine2: settings?['footer_line2'] ?? '',

      printerName: '',

      printerAddress: '',
    );

    setState(() {
      connected = false;

      selectedDevice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF3568C8),
        elevation: 0,

        title: const Text(
          "Printer Bluetooth",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),

        actions: [
          IconButton(
            onPressed: init,

            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ================= STATUS =================
                Container(
                  width: double.infinity,

                  margin: const EdgeInsets.all(18),

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: connected ? const Color(0xFFE9FFF1) : Colors.white,

                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,

                        decoration: BoxDecoration(
                          color: selectedDevice != null
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEAF1FF),

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Icon(
                          selectedDevice != null
                              ? Icons.check
                              : Icons.print_rounded,

                          color: selectedDevice != null
                              ? Colors.white
                              : const Color(0xFF3568C8),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              !bluetoothOn
                                  ? "Bluetooth Tidak Aktif"
                                  : connected
                                  ? "Printer Terhubung"
                                  : "Tidak ada printer terhubung",

                              style: const TextStyle(
                                fontSize: 17,

                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              !bluetoothOn
                                  ? "Aktifkan bluetooth terlebih dahulu"
                                  : connected
                                  ? "${selectedDevice?.name ?? '-'} (${selectedDevice?.address ?? '-'})"
                                  : "Silakan hubungkan printer bluetooth",

                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),

                      if (connected)
                        TextButton(
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Putuskan Printer"),
                                  content: const Text(
                                    "Yakin ingin memutuskan printer?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text("Batal"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text("Putuskan"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (result == true) {
                              disconnect();
                            }
                          },

                          child: const Text("Putuskan"),
                        ),
                    ],
                  ),
                ),

                // ================= BLUETOOTH OFF =================
                if (!bluetoothOn)
                  Container(
                    width: double.infinity,

                    margin: const EdgeInsets.symmetric(horizontal: 18),

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE9E9),

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Row(
                      children: const [
                        Icon(
                          Icons.bluetooth_disabled_rounded,
                          color: Color(0xFFDC2626),
                        ),

                        SizedBox(width: 14),

                        Expanded(
                          child: Text(
                            "Bluetooth tidak aktif. Aktifkan bluetooth untuk melihat daftar printer yang tersedia.",

                            style: TextStyle(color: Color(0xFFDC2626)),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ================= LIST =================
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),

                    itemCount: devices.length,

                    itemBuilder: (context, index) {
                      final device = devices[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),

                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,

                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF1FF),

                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: const Icon(
                                Icons.print_rounded,

                                color: Color(0xFF3568C8),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    device.name ?? '-',

                                    maxLines: 1,

                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      fontSize: 16,

                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    device.address ?? '-',

                                    maxLines: 1,

                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            selectedDevice?.address == device.address &&
                                    connected
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),

                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE9FFF1),

                                      borderRadius: BorderRadius.circular(12),
                                    ),

                                    child: const Text(
                                      "Terhubung",

                                      style: TextStyle(
                                        color: Color(0xFF16A34A),

                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3568C8),

                                      elevation: 0,
                                    ),

                                    onPressed: () {
                                      connectPrinter(device);
                                    },

                                    child: const Text(
                                      "Hubungkan",

                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
