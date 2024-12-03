import 'package:expense_manager/model/expense_model.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static Future<Database> _getDatabase() async {
    final path = join(await getDatabasesPath(), 'expenses.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT,
            amount REAL,
            date TEXT,
            category TEXT
          )
        ''');
      },
    );
  }

  // Public method to get the database
  static Future<Database> getDatabase() => _getDatabase();

  static Future<List<Expense>> getAllExpenses() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }


  static Future<void> insertExpense(Expense expense) async {
    final db = await _getDatabase();

    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,  // Handle conflicts (if any)
    );
  }

  static Future<void> updateExpense(Expense expense) async {
    final db = await _getDatabase();

    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],  // Make sure expense.id is non-null here
    );
  }
  static Future<void> deleteExpense(int id) async {
    final db = await _getDatabase();  // Now _getDatabase is static
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> fetchExpenses(DateTime startDate, DateTime endDate) async {
    // Get the database path
    final databasePath = await getDatabasesPath();
    final db = await openDatabase(join(databasePath, 'expenses.db'));

    // Query the database
    final List<Map<String, dynamic>> result = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(endDate),
      ],
      orderBy: 'date ASC',
    );

    return result;
  }


}
