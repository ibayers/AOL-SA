import 'models.dart';

/// Dummy data for the Smart Money app
class DummyData {
  DummyData._();

  static final List<CategoryModel> categories = [
    const CategoryModel(id: '1', name: 'Makanan', icon: '🍔'),
    const CategoryModel(id: '2', name: 'Transportasi', icon: '🚗'),
    const CategoryModel(id: '3', name: 'Belanja', icon: '🛍️'),
    const CategoryModel(id: '4', name: 'Hiburan', icon: '🎮'),
    const CategoryModel(id: '5', name: 'Tagihan', icon: '📄'),
    const CategoryModel(id: '6', name: 'Gaji', icon: '💰'),
    const CategoryModel(id: '7', name: 'Kopi', icon: '☕'),
    const CategoryModel(id: '8', name: 'Kesehatan', icon: '🏥'),
  ];

  static final List<PaymentMethodModel> paymentMethods = [
    const PaymentMethodModel(id: '1', name: 'Cash'),
    const PaymentMethodModel(id: '2', name: 'GoPay'),
    const PaymentMethodModel(id: '3', name: 'Bank Transfer'),
    const PaymentMethodModel(id: '4', name: 'OVO'),
    const PaymentMethodModel(id: '5', name: 'Credit Card'),
  ];

  static final List<TransactionModel> transactions = [
    TransactionModel(
      id: '1',
      amount: 45000,
      type: 'expense',
      categoryName: 'Makanan',
      categoryIcon: '🍔',
      paymentMethodName: 'GoPay',
      note: 'Lunch Buffet',
      date: DateTime.now(),
      feeling: 'happy',
    ),
    TransactionModel(
      id: '2',
      amount: 5000000,
      type: 'income',
      categoryName: 'Gaji',
      categoryIcon: '💰',
      paymentMethodName: 'Bank Transfer',
      note: 'Salary Deposit',
      date: DateTime.now(),
    ),
    TransactionModel(
      id: '3',
      amount: 150000,
      type: 'expense',
      categoryName: 'Belanja',
      categoryIcon: '🛍️',
      paymentMethodName: 'Cash',
      note: 'Groceries',
      date: DateTime.now().subtract(const Duration(days: 1)),
      feeling: 'neutral',
    ),
    TransactionModel(
      id: '4',
      amount: 25000,
      type: 'expense',
      categoryName: 'Transportasi',
      categoryIcon: '🚗',
      paymentMethodName: 'OVO',
      note: 'Uber Ride',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransactionModel(
      id: '5',
      amount: 75000,
      type: 'expense',
      categoryName: 'Hiburan',
      categoryIcon: '🎮',
      paymentMethodName: 'GoPay',
      note: 'Cinema Tickets',
      date: DateTime.now().subtract(const Duration(days: 1)),
      feeling: 'happy',
    ),
    TransactionModel(
      id: '6',
      amount: 35000,
      type: 'expense',
      categoryName: 'Kopi',
      categoryIcon: '☕',
      paymentMethodName: 'GoPay',
      note: 'Starbucks',
      date: DateTime.now().subtract(const Duration(days: 2)),
      feeling: 'regret',
    ),
    TransactionModel(
      id: '7',
      amount: 200000,
      type: 'expense',
      categoryName: 'Tagihan',
      categoryIcon: '📄',
      paymentMethodName: 'Bank Transfer',
      note: 'Internet Bill',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TransactionModel(
      id: '8',
      amount: 1500000,
      type: 'income',
      categoryName: 'Gaji',
      categoryIcon: '💰',
      paymentMethodName: 'Bank Transfer',
      note: 'Freelance Payment',
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  static final List<WishlistItemModel> wishlistItems = [
    WishlistItemModel(
      id: '1',
      name: 'New Headphones',
      price: 2000000,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    WishlistItemModel(
      id: '2',
      name: 'Gaming Console',
      price: 7500000,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    WishlistItemModel(
      id: '3',
      name: 'Mechanical Keyboard',
      price: 1200000,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static const ProfileModel profile = ProfileModel(
    id: '1',
    name: 'Alex Johnson',
    email: 'alex.johnson@example.com',
    weeklyBudget: 1500000,
  );

  // Computed
  static double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  static double get totalExpense => transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  static double get netBalance => totalIncome - totalExpense;

  static Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final t in transactions.where((t) => t.isExpense)) {
      map[t.categoryName ?? 'Unknown'] = (map[t.categoryName ?? 'Unknown'] ?? 0) + t.amount;
    }
    return map;
  }
}
