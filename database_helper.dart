import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // ================= DATABASE =================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('ramp.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,

      version: 5,

      onCreate: _createDB,

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await db.execute('''
        CREATE TABLE IF NOT EXISTS sales_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,

          tanggal TEXT,

          supir TEXT,
          nomor_kendaraan TEXT,
          pabrik_tujuan TEXT,

          netto REAL,
          grading REAL,
          harga_jual REAL,

          solar REAL,
          upah_muat REAL,
          upah_supir REAL,
          biaya_lain REAL,

          subtotal REAL,
          total_biaya REAL,
          total_bersih REAL
        )
      ''');
        }

        if (oldVersion < 5) {
          try {
            await db.execute('ALTER TABLE settings ADD COLUMN logo_path TEXT');
          } catch (_) {}

          try {
            await db.execute(
              'ALTER TABLE settings ADD COLUMN footer_line1 TEXT',
            );
          } catch (_) {}

          try {
            await db.execute(
              'ALTER TABLE settings ADD COLUMN footer_line2 TEXT',
            );
          } catch (_) {}

          try {
            await db.execute(
              'ALTER TABLE settings ADD COLUMN printer_address TEXT',
            );
          } catch (_) {}
        }
      },
    );
  }

  // ================= CREATE TABLE =================

  Future _createDB(Database db, int version) async {
    // ================= TRANSACTIONS =================

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        pelanggan TEXT,
        alamat TEXT,
        kebun TEXT,

        potongAngkut TEXT,
        potongLain TEXT,

        netto REAL,
        grading REAL,
        harga REAL,

        tanggal TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        tanggal TEXT,

        supir TEXT,
        nomor_kendaraan TEXT,
        pabrik_tujuan TEXT,

        netto REAL,
        grading REAL,
        harga_jual REAL,

        solar REAL,
        upah_muat REAL,
        upah_supir REAL,
        biaya_lain REAL,

        subtotal REAL,
        total_biaya REAL,
        total_bersih REAL
      )
    ''');

    // ================= SETTINGS =================

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        business_name TEXT,
        owner_name TEXT,
        phone TEXT,
        address TEXT,
        city TEXT,
        province TEXT,

        logo_path TEXT,
        footer_line1 TEXT,
        footer_line2 TEXT,

        printer_name TEXT,
        printer_address TEXT
      )
    ''');

    // ================= DEFAULT SETTINGS =================

    await db.insert('settings', {
      'business_name': 'RAMP INDPARLOH',

      'owner_name': 'Ismail Qomar',

      'phone': '082157020314',

      'address': 'Jl. Parit Berkat',

      'city': 'Pontianak',
      'logo_path': '',
      'footer_line1': 'Terima kasih',
      'footer_line2': 'atas kepercayaan Anda',

      'province': 'Kalimantan Barat',

      'printer_name': '',
      'printer_address': '',
    });
  }

  // ================= CLOSE =================

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  // =====================================================
  // ================= TRANSACTIONS ======================
  // =====================================================

  // ================= GET ALL =================

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await instance.database;

    final result = await db.query('transactions', orderBy: 'id DESC');

    return result;
  }

  // ================= GET TODAY =================

  Future<List<Map<String, dynamic>>> getTodayTransactions() async {
    final db = await database;

    final now = DateTime.now();

    final today =
        "${now.day.toString().padLeft(2, '0')}"
        "-${now.month.toString().padLeft(2, '0')}"
        "-${now.year}";

    return await db.query(
      'transactions',

      where: 'tanggal LIKE ?',

      whereArgs: ['$today%'],

      orderBy: 'id DESC',
    );
  }

  // ================= INSERT =================

  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;

    return await db.insert('transactions', row);
  }

  // ================= UPDATE =================

  Future<int> updateTransaction(int id, Map<String, dynamic> row) async {
    final db = await instance.database;

    return await db.update(
      'transactions',
      row,

      where: 'id = ?',

      whereArgs: [id],
    );
  }

  // ================= DELETE =================

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;

    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // =====================================================
  // ================= SETTINGS ==========================
  // =====================================================

  // ================= GET SETTINGS =================

  Future<Map<String, dynamic>?> getSettings() async {
    final db = await database;

    final result = await db.query('settings');

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // =====================================================
  // ================= SALES =============================
  // =====================================================

  Future<List<Map<String, dynamic>>> getSalesTransactions() async {
    final db = await instance.database;

    return await db.query('sales_transactions', orderBy: 'id DESC');
  }

  Future<int> insertSalesTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;

    return await db.insert('sales_transactions', row);
  }

  Future<int> updateSalesTransaction(int id, Map<String, dynamic> row) async {
    final db = await instance.database;

    return await db.update(
      'sales_transactions',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSalesTransaction(int id) async {
    final db = await instance.database;

    return await db.delete(
      'sales_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= UPDATE SETTINGS =================

  Future<int> updateSettings({
    required String businessName,
    required String ownerName,
    required String phone,
    required String address,
    required String city,
    required String province,

    required String logoPath,
    required String footerLine1,
    required String footerLine2,

    required String printerName,
    required String printerAddress,
  }) async {
    final db = await database;

    return await db.update(
      'settings',
      {
        'business_name': businessName,

        'owner_name': ownerName,

        'phone': phone,

        'address': address,

        'city': city,

        'province': province,
        'logo_path': logoPath,
        'footer_line1': footerLine1,
        'footer_line2': footerLine2,
        'printer_name': printerName,
        'printer_address': printerAddress,
      },

      where: 'id = ?',

      whereArgs: [1],
    );
  }
}
