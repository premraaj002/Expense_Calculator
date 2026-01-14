import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';

class HiveService {
  static const String expenseBoxName = 'expenses';

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ExpenseAdapter());
      }
      await Hive.openBox<Expense>(expenseBoxName);
    } catch (e) {
      debugPrint('Hive initialization error: $e');
      // Potentially attempt to delete and reopen if it's a schema mismatch that prevents opening
      // But for now, just let it throw or handle it in main
      rethrow;
    }
  }

  static Box<Expense> get expenseBox => Hive.box<Expense>(expenseBoxName);

  // Expense Methods
  static Future<void> addExpense(Expense expense) async {
    await expenseBox.add(expense);
  }

  static Future<void> updateExpense(Expense expense) async {
    await expense.save();
  }

  static Future<void> deleteExpense(Expense expense) async {
    await expense.delete();
  }

  static List<Expense> getAllExpenses() {
    return expenseBox.values.toList();
  }
}
