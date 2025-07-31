import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void onConfigure(Database db) {
  db.execute('PRAGMA foreign_keys = ON');
}

Future<Database> getDb() async {
  return await openDatabase(
    join(await getDatabasesPath(), 'budget_lite_database.db'),
    onConfigure: (db) {
      onConfigure(db);
    },
    onCreate: (db, version) {
      db.execute(
        "CREATE TABLE IF NOT EXISTS accounts(id INTEGER PRIMARY KEY,email TEXT,country TEXT,budget_reset_date TEXT,account_tier TEXT,created_at TEXT,resetPending INTEGER DEFAULT 0)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS wallets(id INTEGER PRIMARY KEY,balance REAL,name TEXT,savings REAL, account_id INTEGER,FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)",
      );
      db.execute(
        'CREATE TABLE IF NOT EXISTS transactions(id INTEGER PRIMARY KEY, type TEXT,source TEXT, amount REAL,date TEXT,category TEXT,desc TEXT,account_id INTEGER,FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)',
      );
      db.execute(
        "CREATE TABLE IF NOT EXISTS categories(id INTEGER PRIMARY KEY,budget REAL,category_name TEXT,spent REAL,account_id INTEGER,FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS goals(id INTEGER PRIMARY KEY,name TEXT,target_amount REAL,target_date TEXT,current_amount REAL,account_id INTEGER, FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)",
      );
    },

    // When the database is first created, create a table to store dogs.
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}

appDbInit() async {
  // await deleteDatabase(
  //   join(await getDatabasesPath(), 'budget_lite_database.db'),
  // );
  await openDatabase(
    join(await getDatabasesPath(), 'budget_lite_database.db'),
    onConfigure: (db) {
      onConfigure(db); // db.execute('PRAGMA foreign_keys = ON');
    },
    onCreate: (db, version) {
      db.execute(
        "CREATE TABLE IF NOT EXISTS accounts(id INTEGER PRIMARY KEY,email TEXT,country TEXT,budget_reset_date TEXT,account_tier TEXT,created_at TEXT ,resetPending INTEGER DEFAULT 0)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS wallets(id INTEGER PRIMARY KEY,balance REAL,name TEXT,savings REAL, account_id INTEGER,FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)",
      );
      db.execute(
        'CREATE TABLE IF NOT EXISTS transactions(id INTEGER PRIMARY KEY, type TEXT,source TEXT, amount REAL,date TEXT,category TEXT,desc TEXT,account_id INTEGER,FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)',
      );
      db.execute(
        "CREATE TABLE IF NOT EXISTS categories(id INTEGER PRIMARY KEY,budget REAL,category_name TEXT,spent REAL,account_id INTEGER,FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS goals(id INTEGER PRIMARY KEY,name TEXT,target_amount REAL,target_date TEXT,current_amount REAL,account_id INTEGER, FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE)",
      );
    },

    version: 1,
  );
}
