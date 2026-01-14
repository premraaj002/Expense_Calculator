import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/expense_model.dart';
import '../services/expense_data_service.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import 'add_expense_screen.dart';

class DayDetailsScreen extends StatelessWidget {
  final DateTime date;
  final List<Expense> expenses;

  const DayDetailsScreen({
    super.key,
    required this.date,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Helpers.formatDate(date))),
      body: ListenableBuilder(
        listenable: ExpenseDataService(),
        builder: (context, _) {
          final service = ExpenseDataService();
          final dateKey = Helpers.formatDate(date);
          final dayExpenses = service.getExpensesForDay(dateKey);

          if (dayExpenses.isEmpty) {
            return const Center(child: Text('No expenses found for this date.'));
          }

          final total = service.getTotalForDay(dateKey);

          return Column(
            children: [
              // Total Summary
               Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Spent:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        Helpers.formatCurrency(total),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
               ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dayExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = dayExpenses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                        ),
                        title: Text(
                          expense.categories.join(', '),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (expense.otherName != null && expense.otherName!.isNotEmpty)
                              Text(expense.otherName!),
                            if (expense.purchasedItems != null && expense.purchasedItems!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Items: ${expense.purchasedItems}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            if (expense.paymentMode != null && expense.paymentMode!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Paid via ${expense.paymentMode}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Helpers.formatCurrency(expense.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.secondary,
                              ),
                            ),
                            PopupMenuButton(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddExpenseScreen(
                                        expenseToEdit: expense,
                                        onSaved: () {
                                          // Just pop back to refresh
                                          Navigator.pop(context); 
                                        },
                                      ),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  await _showDeleteConfirmation(context, expense);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Expense expense) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await HiveService.deleteExpense(expense);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
