
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Wallet {
  final int? id;
  final String name;
  final double balance;

  Wallet({this.id, required this.name, required this.balance});

  Map<String, Object> toMap() {
    return {"id": ?id, "name": name, "balance": balance};
  }

  String toString() {
    return 'Wallet{name:$name,balance:$balance}';
  }
}

Future<void> insertWallet(Wallet wallet) async {
  final db = await openDatabase(
    join(await getDatabasesPath(), 'budget_lite_database.db'),
    version: 1,
  );
  await db.insert("wallets", wallet.toMap());
}