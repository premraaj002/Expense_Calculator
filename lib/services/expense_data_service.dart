import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';
import '../services/hive_service.dart';
import '../utils/helpers.dart';

class ExpenseDataService extends ChangeNotifier {
  static final ExpenseDataService _instance = ExpenseDataService._internal();
  factory ExpenseDataService() => _instance;
  ExpenseDataService._internal();

  List<Expense> _allExpenses = [];
  Map<String, List<Expense>> _groupedByMonth = {};
  Map<String, List<Expense>> _groupedByDay = {}; // Key: "yyyy-MM-dd" or formatted
  
  // Cached Totals
  Map<String, double> _monthlyTotals = {};
  Map<String, double> _dailyTotals = {};

  List<Expense> get allExpenses => _allExpenses;

  void init() {
    // Listen to Hive box changes
    HiveService.expenseBox.listenable().addListener(_onBoxChanged);
    // Initial Load
    _onBoxChanged();
  }

  void _onBoxChanged() {
    // Load all data
    _allExpenses = HiveService.expenseBox.values.toList();
    
    // Sort logic: Recent first
    _allExpenses.sort((a, b) => b.date.compareTo(a.date));

    _recomputeCache();
    notifyListeners();
  }

  void _recomputeCache() {
    _groupedByMonth.clear();
    _groupedByDay.clear();
    _monthlyTotals.clear();
    _dailyTotals.clear();

    for (var e in _allExpenses) {
      // Month Cache
      final monthKey = Helpers.formatMonth(e.date);
      _groupedByMonth.putIfAbsent(monthKey, () => []).add(e);
      _monthlyTotals[monthKey] = (_monthlyTotals[monthKey] ?? 0) + e.amount;

      // Day Cache
      final dayKey = Helpers.formatDate(e.date);
      _groupedByDay.putIfAbsent(dayKey, () => []).add(e);
      _dailyTotals[dayKey] = (_dailyTotals[dayKey] ?? 0) + e.amount;
    }
  }

  // --- Public Accessors (Fast Lookups) ---

  List<String> get sortedMonthKeys {
    final keys = _groupedByMonth.keys.toList();
    // Sort keys based on date of first expense in that group (approx)
    // Or parse the key string. Better to rely on the fact that _allExpenses is sorted by date desc,
    // so keys appearing in insertion order might be rough. 
    // But map iteration isn't guaranteed order in older Dart versions? 
    // Actually LinkedHashMap preserves insertion order.
    // Let's safe sort based on a representative expense.
    keys.sort((a, b) {
      final dateA = _groupedByMonth[a]!.first.date;
      final dateB = _groupedByMonth[b]!.first.date;
      return dateB.compareTo(dateA);
    });
    return keys;
  }

  List<Expense> getExpensesForMonth(String monthKey) {
    return _groupedByMonth[monthKey] ?? [];
  }

  double getTotalForMonth(String monthKey) {
    return _monthlyTotals[monthKey] ?? 0.0;
  }

  List<String> getSortedDateKeysForMonth(String monthKey) {
    // Get expenses for month
    final expenses = _groupedByMonth[monthKey] ?? [];
    if (expenses.isEmpty) return [];

    // Group local for unique dates keys 
    // or checks _groupedByDay keys that belong to this month?
    // Efficient: Just grab distinct formatted dates from the month list.
    final Set<String> uniqueDates = {};
    for (var e in expenses) {
      uniqueDates.add(Helpers.formatDate(e.date));
    }
    
    final sorted = uniqueDates.toList();
    // Re-sort dates
    // They are strings like "05 Jan 2026". Hard to sort string.
    // Better rely on expense objects.
    // Use the first expense of the date group to compare.
    sorted.sort((a, b) {
       // Find *any* expense with this date key
       final expA = _groupedByDay[a]!.first;
       final expB = _groupedByDay[b]!.first;
       return expB.date.compareTo(expA.date);
    });
    return sorted;
  }

  List<Expense> getExpensesForDay(String dayKey) {
    return _groupedByDay[dayKey] ?? [];
  }

  double getTotalForDay(String dayKey) {
    return _dailyTotals[dayKey] ?? 0.0;
  }
}
