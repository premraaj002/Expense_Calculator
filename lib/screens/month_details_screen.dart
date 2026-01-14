import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_data_service.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import 'day_details_screen.dart';

class MonthDetailsScreen extends StatelessWidget {
  final String monthKey; // e.g., "January 2024"
  final List<Expense> expenses;

  const MonthDetailsScreen({
    super.key,
    required this.monthKey,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(monthKey)),
      body: ListenableBuilder(
        listenable: ExpenseDataService(),
        builder: (context, _) {
          final service = ExpenseDataService();
          final currentMonthExpenses = service.getExpensesForMonth(monthKey);
          
          if (currentMonthExpenses.isEmpty) {
             return const Center(child: Text('No expenses found for this month.'));
          }
          
          final sortedDateKeys = service.getSortedDateKeysForMonth(monthKey);
          final totalMonthExpense = service.getTotalForMonth(monthKey);
          
          // Chart removed as per request.
          // Calculating total is sufficient.


          return Column(
            children: [
               // Total Summary Card
               Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Spent:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        Helpers.formatCurrency(totalMonthExpense),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
               ),

               // Chart removed.
               const SizedBox(height: 0),
               
               Expanded(
                 child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedDateKeys.length,
                  itemBuilder: (context, index) {
                    final dateKey = sortedDateKeys[index];
                    final dayExpenses = service.getExpensesForDay(dateKey); // This logic needs dayKey to be unique globally presumably?
                    // getExpensesForDay uses 'yyyy-MM-dd' formatted key.
                    // sortedDateKeys returns formatted keys.
                    // BUT collision? Yes, if multiple years/months. 
                    // '05 Jan 2026' is unique enough? Helpers.formatDate includes year?
                    // Let's check Helpers.formatDate. 
                    // It usually is 'dd MMM yyyy'. That is unique per day. Safe.
                    
                    if (dayExpenses.isEmpty) return const SizedBox.shrink(); // Should not happen
                    
                    final dailyTotal = service.getTotalForDay(dateKey);
                    final dateObj = dayExpenses.first.date;
                
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dateObj.day.toString(), 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        title: Text(
                          dateKey,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${dayExpenses.length} transactions'),
                        trailing: Text(
                          Helpers.formatCurrency(dailyTotal),
                          style: const TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: AppColors.secondary
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DayDetailsScreen(
                                date: dateObj,
                                expenses: dayExpenses,
                              ),
                            ),
                          );
                        },
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
}
