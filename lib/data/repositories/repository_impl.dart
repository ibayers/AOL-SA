import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../datasources/category_remote_data_source.dart';
import '../datasources/payment_method_remote_data_source.dart';
import '../datasources/wishlist_remote_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _dataSource;
  final CategoryRemoteDataSource _categoryDataSource;
  final PaymentMethodRemoteDataSource _paymentMethodDataSource;
  TransactionRepositoryImpl(
    this._dataSource,
    this._categoryDataSource,
    this._paymentMethodDataSource,
  );

  @override
  Future<List<TransactionModel>> getTransactions({
    DateTime? from,
    DateTime? to,
  }) async {
    final transactions = await _dataSource.getTransactions(from: from, to: to);
    final categories = await _categoryDataSource.getCategories();
    final paymentMethods = await _paymentMethodDataSource.getPaymentMethods();

    final categoryMap = {for (final c in categories) c.id: c};
    final paymentMap = {for (final p in paymentMethods) p.id: p};

    return transactions.map((t) => TransactionModel(
      id: t.id,
      userId: t.userId,
      amount: t.amount,
      type: t.type,
      categoryId: t.categoryId,
      paymentMethodId: t.paymentMethodId,
      note: t.note,
      date: t.date,
      feeling: t.feeling,
      createdAt: t.createdAt,
      categoryName: t.categoryId != null
          ? categoryMap[t.categoryId]?.name
          : (t.isIncome ? 'Income' : 'Expense'),
      categoryIcon: t.categoryId != null
          ? categoryMap[t.categoryId]?.icon
          : null,
      paymentMethodName: t.paymentMethodId != null
          ? paymentMap[t.paymentMethodId]?.name
          : null,
    )).toList();
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel txn) {
    return _dataSource.addTransaction(txn);
  }

  @override
  Future<void> updateTransaction(TransactionModel txn) {
    return _dataSource.updateTransaction(txn).then((_) {});
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _dataSource.deleteTransaction(id);
  }
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _dataSource;
  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<CategoryModel>> getCategories() {
    return _dataSource.getCategories();
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) {
    return _dataSource.addCategory(category);
  }

  @override
  Future<void> updateCategory(CategoryModel category) {
    return _dataSource.updateCategory(category).then((_) {});
  }

  @override
  Future<void> deleteCategory(String id) {
    return _dataSource.deleteCategory(id);
  }
}

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final PaymentMethodRemoteDataSource _dataSource;
  PaymentMethodRepositoryImpl(this._dataSource);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() {
    return _dataSource.getPaymentMethods();
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel method) {
    return _dataSource.addPaymentMethod(method);
  }

  @override
  Future<void> deletePaymentMethod(String id) {
    return _dataSource.deletePaymentMethod(id);
  }
}

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource _dataSource;
  WishlistRepositoryImpl(this._dataSource);

  @override
  Future<List<WishlistItemModel>> getWishlistItems() {
    return _dataSource.getWishlistItems();
  }

  @override
  Future<WishlistItemModel> addWishlistItem(WishlistItemModel item) {
    return _dataSource.addWishlistItem(item);
  }

  @override
  Future<void> updateWishlistItem(WishlistItemModel item) {
    return _dataSource.updateWishlistItem(item).then((_) {});
  }

  @override
  Future<void> deleteWishlistItem(String id) {
    return _dataSource.deleteWishlistItem(id);
  }

  @override
  Future<void> markAsCompleted(String id) {
    return _dataSource.markCompleted(id).then((_) {});
  }
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;
  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<ProfileModel> getProfile() {
    return _dataSource.getProfile();
  }

  @override
  Future<void> updateProfile(ProfileModel profile) {
    return _dataSource.updateProfile(profile).then((_) {});
  }

  @override
  Future<String> uploadAvatar(dynamic file, String fileName) async {
    return 'https://ui-avatars.com/api/?name=User&background=random';
  }
}
