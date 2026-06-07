import '../models/models.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions({
    DateTime? from,
    DateTime? to,
  });
  Future<TransactionModel> addTransaction(TransactionModel txn);
  Future<void> updateTransaction(TransactionModel txn);
  Future<void> deleteTransaction(String id);
}

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

abstract class PaymentMethodRepository {
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel method);
  Future<void> deletePaymentMethod(String id);
}

abstract class WishlistRepository {
  Future<List<WishlistItemModel>> getWishlistItems();
  Future<WishlistItemModel> addWishlistItem(WishlistItemModel item);
  Future<void> updateWishlistItem(WishlistItemModel item);
  Future<void> deleteWishlistItem(String id);
  Future<void> markAsCompleted(String id);
  Future<void> invest(String id, double amount);
}

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile(ProfileModel profile);
  Future<String> uploadAvatar(dynamic file, String fileName);
}
