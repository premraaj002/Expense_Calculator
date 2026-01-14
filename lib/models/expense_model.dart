import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final List<String> categories;

  @HiveField(4)
  final String? otherName;

  @HiveField(5)
  final String? purchasedItems;

  @HiveField(6)
  final String? paymentMode;

  Expense({
    required this.id,
    required this.date,
    required this.amount,
    required this.categories,
    this.otherName,
    this.purchasedItems,
    this.paymentMode,
  });
}
