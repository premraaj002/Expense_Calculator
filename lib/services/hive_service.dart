import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';

class HiveService {
  static const String expenseBoxName = 'expenses';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    await Hive.openBox<Expense>(expenseBoxName);
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
