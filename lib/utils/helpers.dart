import 'package:intl/intl.dart';

class Helpers {
  static final _currencyFormat = NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0);
  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _monthFormat = DateFormat('MMMM yyyy');
  static final _dayFormat = DateFormat('EEE, dd MMM');

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatMonth(DateTime date) {
    return _monthFormat.format(date);
  }

  static String formatDay(DateTime date) {
    return _dayFormat.format(date);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
