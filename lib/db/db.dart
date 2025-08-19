import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  factory DatabaseHelper() {
    return _instance;
  }
  static Database? _database; // Private database instance

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'your_database_name.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: onConfigure,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE IF NOT EXISTS accounts(id INTEGER PRIMARY KEY,email TEXT,country TEXT,budget_reset_date TEXT,account_tier TEXT,created_at TEXT,resetPending INTEGER DEFAULT 0,auth_id TEXT)",
    );

    await db.execute(
      "CREATE TABLE IF NOT EXISTS wallets(id INTEGER PRIMARY KEY,balance REAL,name TEXT,savings REAL, account_id INTEGER,FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)",
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS transactions(id INTEGER PRIMARY KEY, type TEXT,source TEXT, amount REAL,date TEXT,category TEXT,desc TEXT,account_id INTEGER, message_hash_code TEXT UNIQUE,FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)',
    );
    await db.execute(
      "CREATE TABLE IF NOT EXISTS categories(id INTEGER PRIMARY KEY,budget REAL,category_name TEXT,spent REAL,account_id INTEGER,FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)",
    );

    await db.execute(
      "CREATE TABLE IF NOT EXISTS goals(id INTEGER PRIMARY KEY,name TEXT,target_amount REAL,target_date TEXT,current_amount REAL,account_id INTEGER, FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)",
    );
    await db.execute(
      "CREATE TABLE IF NOT EXISTS weekly_reports(id INTEGER PRIMARY KEY, from_date TEXT, to_date TEXT, report_data TEXT,key TEXT,account_id INTEGER, FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)",
    );
  }

  Future<void> onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
