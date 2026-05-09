import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/models/dummy_data.dart';

/// In-memory implementation of [TransactionRepository] using dummy data.
class TransactionRepositoryImpl implements TransactionRepository {
  final List<TransactionModel> _transactions = List.from(DummyData.transactions);

  @override
  Future<List<TransactionModel>> getTransactions({DateTime? from, DateTime? to}) async {
    var result = List<TransactionModel>.from(_transactions);
    if (from != null) {
      result = result.where((t) => t.date.isAfter(from) || t.date.isAtSameMomentAs(from)).toList();
    }
    if (to != null) {
      result = result.where((t) => t.date.isBefore(to) || t.date.isAtSameMomentAs(to)).toList();
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel txn) async {
    final newTxn = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: txn.amount,
      type: txn.type,
      categoryId: txn.categoryId,
      paymentMethodId: txn.paymentMethodId,
      note: txn.note,
      date: txn.date,
      feeling: txn.feeling,
      categoryName: txn.categoryName,
      categoryIcon: txn.categoryIcon,
      paymentMethodName: txn.paymentMethodName,
    );
    _transactions.add(newTxn);
    return newTxn;
  }

  @override
  Future<void> updateTransaction(TransactionModel txn) async {
    final index = _transactions.indexWhere((t) => t.id == txn.id);
    if (index != -1) _transactions[index] = txn;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
  }
}

/// In-memory implementation of [CategoryRepository] using dummy data.
class CategoryRepositoryImpl implements CategoryRepository {
  final List<CategoryModel> _categories = List.from(DummyData.categories);

  @override
  Future<List<CategoryModel>> getCategories() async {
    return List<CategoryModel>.from(_categories);
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    final newCat = CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: category.name,
      icon: category.icon,
      type: category.type,
    );
    _categories.add(newCat);
    return newCat;
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) _categories[index] = category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
  }
}

/// In-memory implementation of [PaymentMethodRepository] using dummy data.
class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final List<PaymentMethodModel> _methods = List.from(DummyData.paymentMethods);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    return List<PaymentMethodModel>.from(_methods);
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel method) async {
    final newMethod = PaymentMethodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: method.name,
    );
    _methods.add(newMethod);
    return newMethod;
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    _methods.removeWhere((m) => m.id == id);
  }
}

/// In-memory implementation of [WishlistRepository] using dummy data.
class WishlistRepositoryImpl implements WishlistRepository {
  final List<WishlistItemModel> _items = List.from(DummyData.wishlistItems);

  @override
  Future<List<WishlistItemModel>> getWishlistItems() async {
    return List<WishlistItemModel>.from(_items)
      ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
  }

  @override
  Future<WishlistItemModel> addWishlistItem(WishlistItemModel item) async {
    final newItem = WishlistItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: item.name,
      price: item.price,
      status: item.status,
      imagePath: item.imagePath,
    );
    _items.add(newItem);
    return newItem;
  }

  @override
  Future<void> updateWishlistItem(WishlistItemModel item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) _items[index] = item;
  }

  @override
  Future<void> deleteWishlistItem(String id) async {
    _items.removeWhere((i) => i.id == id);
  }

  @override
  Future<void> markAsCompleted(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final item = _items[index];
      _items[index] = WishlistItemModel(
        id: item.id,
        name: item.name,
        price: item.price,
        status: 'completed',
        imagePath: item.imagePath,
        createdAt: item.createdAt,
      );
    }
  }
}

/// In-memory implementation of [ProfileRepository] using dummy data.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileModel _profile = DummyData.profile;

  @override
  Future<ProfileModel> getProfile() async => _profile;

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    _profile = profile;
  }

  @override
  Future<String> uploadAvatar(dynamic file, String fileName) async {
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_profile.name)}&background=random';
  }
}
