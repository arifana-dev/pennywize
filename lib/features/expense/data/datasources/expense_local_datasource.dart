import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/expense.dart';
import '../models/expense_model.dart';

class ExpenseLocalDataSource {
  static const _dbName = 'penny.db';
  static const _table = 'expenses';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            merchant_name TEXT NOT NULL,
            amount INTEGER NOT NULL,
            date INTEGER NOT NULL,
            category TEXT NOT NULL,
            notes TEXT,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_date ON $_table(date)');
      },
    );
  }

  Future<int> insert(Expense expense) async {
    final db = await database;
    return db.insert(_table, ExpenseModel.toMap(expense));
  }

  Future<int> update(Expense expense) async {
    final db = await database;
    return db.update(
      _table,
      ExpenseModel.toMap(expense),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getAll() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'date DESC, id DESC');
    return rows.map(ExpenseModel.fromMap).toList();
  }

  Future<List<Expense>> getInRange(DateTime start, DateTime end) async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(ExpenseModel.fromMap).toList();
  }

  Future<int> totalInRange(DateTime start, DateTime end) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount),0) AS total FROM $_table WHERE date BETWEEN ? AND ?',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    final v = rows.first['total'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }
}
