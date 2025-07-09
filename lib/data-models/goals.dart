import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Goal {
  final int? id;
  final String name;
  final String targetAmount;
  final String targetDate;
  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
  });

  Map<String, Object> toMap() {
    return {"id": ?id, "name": name, "target_amount": targetAmount,"target_date":targetDate};
  }

  @override
  String toString() {
    return 'Goal{id:$id,name:$name,target_amount:$targetAmount,target_date:$targetDate}';
  }
}
Future<void> insertGoal(Goal goal) async {
  final db = await openDatabase(
    join(await getDatabasesPath(), 'budget_lite_database.db'),
    version: 1,
  );
  await db.insert("goals", goal.toMap());
}
