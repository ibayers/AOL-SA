import '../models/models.dart';

enum Period { daily, weekly, monthly }

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime _startOfWeek(DateTime d) {
  final date = DateTime(d.year, d.month, d.day);
  // In Dart, weekday: 1 = Monday, 7 = Sunday. Start week on Monday.
  return date.subtract(Duration(days: date.weekday - 1));
}

bool isSameWeek(DateTime a, DateTime b) {
  final sa = _startOfWeek(a);
  final sb = _startOfWeek(b);
  return sa.year == sb.year && sa.month == sb.month && sa.day == sb.day;
}

bool isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

List<TransactionModel> filterTransactionsByPeriod(
  List<TransactionModel> transactions,
  Period period, {
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();

  return transactions.where((t) {
    final d = t.date;
    switch (period) {
      case Period.daily:
        return isSameDay(d, ref);
      case Period.weekly:
        return isSameWeek(d, ref);
      case Period.monthly:
        return isSameMonth(d, ref);
    }
  }).toList();
}

double totalAmountByPeriod(
  List<TransactionModel> transactions,
  Period period, {
  DateTime? reference,
  String? typeFilter, // 'income' or 'expense' or null
}) {
  final list = filterTransactionsByPeriod(transactions, period, reference: reference);
  return list
      .where((t) => typeFilter == null ? true : t.type == typeFilter)
      .fold(0.0, (s, t) => s + t.amount);
}
