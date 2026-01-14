import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import '../services/expense_data_service.dart';
import 'month_details_screen.dart';

class MonthsScreen extends StatelessWidget {
  const MonthsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Months')),
      body: ListenableBuilder(
        listenable: ExpenseDataService(),
        builder: (context, _) {
          final service = ExpenseDataService();
          final sortedKeys = service.sortedMonthKeys;
          
          if (sortedKeys.isEmpty) {
            return const Center(child: Text('No history available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final key = sortedKeys[index];
              // Use cached accessors
              final total = service.getTotalForMonth(key);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  trailing: Text(
                    Helpers.formatCurrency(total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonthDetailsScreen(
                          monthKey: key,
                          // No need to pass list, just key, but for interface compatibility let's see. 
                          // Wait, I need to update MonthDetailsScreen signature too or pass the list from service.
                          // Ideally screen fetches it. But to minimize diffs, I can pass it.
                          // Actually, refactoring MonthDetailsScreen is next. 
                          // I'll make MonthDetailsScreen fetch from service too.
                          expenses: service.getExpensesForMonth(key),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
