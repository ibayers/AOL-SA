import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/repository_impl.dart';
import '../domain/models/models.dart';
import '../domain/repositories/repositories.dart';

final quickAmountsProvider = NotifierProvider<QuickAmountsNotifier, List<int>>(
  QuickAmountsNotifier.new,
);

class QuickAmountsNotifier extends Notifier<List<int>> {
  static const _key = 'quick_amounts';

  @override
  List<int> build() {
    _load();
    return [10000, 20000, 50000, 100000];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key);
    if (items != null) {
      state = items.map(int.parse).toList();
    } else {
      state = [10000, 20000, 50000, 100000];
    }
  }

  Future<void> addAmount(int amount) async {
    if (!state.contains(amount)) {
      final newState = [...state, amount]..sort();
      state = newState;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        newState.map((e) => e.toString()).toList(),
      );
    }
  }

  Future<void> removeAmount(int amount) async {
    final newState = state.where((e) => e != amount).toList();
    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newState.map((e) => e.toString()).toList());
  }
}

final lastUsedPaymentMethodProvider =
    NotifierProvider<LastUsedPaymentMethodNotifier, PaymentMethodModel?>(
      LastUsedPaymentMethodNotifier.new,
    );

class LastUsedPaymentMethodNotifier extends Notifier<PaymentMethodModel?> {
  @override
  PaymentMethodModel? build() => null;

  void set(PaymentMethodModel? method) => state = method;
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl();
});

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((
  ref,
) {
  return PaymentMethodRepositoryImpl();
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

final isLoggedInProvider = NotifierProvider<IsLoggedInNotifier, bool>(
  IsLoggedInNotifier.new,
);

class IsLoggedInNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void login() => state = true;
  void logout() => state = false;
}

final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<TransactionModel>>(
      TransactionListNotifier.new,
    );

class TransactionListNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.getTransactions();
  }

  Future<void> add(TransactionModel txn) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.addTransaction(txn);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.deleteTransaction(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateTransaction(TransactionModel txn) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.updateTransaction(txn);
    ref.invalidateSelf();
    await future;
  }
}

final categoryListProvider =
    AsyncNotifierProvider<CategoryListNotifier, List<CategoryModel>>(
      CategoryListNotifier.new,
    );

class CategoryListNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() async {
    ref.keepAlive();
    final repo = ref.watch(categoryRepositoryProvider);
    return repo.getCategories();
  }

  Future<void> add(CategoryModel category) async {
    final repo = ref.read(categoryRepositoryProvider);
    await repo.addCategory(category);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    final repo = ref.read(categoryRepositoryProvider);
    await repo.deleteCategory(id);
    ref.invalidateSelf();
    await future;
  }
}

final paymentMethodListProvider =
    AsyncNotifierProvider<PaymentMethodListNotifier, List<PaymentMethodModel>>(
      PaymentMethodListNotifier.new,
    );

class PaymentMethodListNotifier
    extends AsyncNotifier<List<PaymentMethodModel>> {
  @override
  Future<List<PaymentMethodModel>> build() async {
    ref.keepAlive();
    final repo = ref.watch(paymentMethodRepositoryProvider);
    return repo.getPaymentMethods();
  }

  Future<void> add(PaymentMethodModel method) async {
    final repo = ref.read(paymentMethodRepositoryProvider);
    await repo.addPaymentMethod(method);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    final repo = ref.read(paymentMethodRepositoryProvider);
    await repo.deletePaymentMethod(id);
    ref.invalidateSelf();
    await future;
  }
}

final wishlistProvider =
    AsyncNotifierProvider<WishlistNotifier, List<WishlistItemModel>>(
      WishlistNotifier.new,
    );

class WishlistNotifier extends AsyncNotifier<List<WishlistItemModel>> {
  @override
  Future<List<WishlistItemModel>> build() async {
    final repo = ref.watch(wishlistRepositoryProvider);
    return repo.getWishlistItems();
  }

  Future<void> add(WishlistItemModel item) async {
    final repo = ref.read(wishlistRepositoryProvider);
    await repo.addWishlistItem(item);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    final repo = ref.read(wishlistRepositoryProvider);
    await repo.deleteWishlistItem(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> markAsCompleted(String id) async {
    final repo = ref.read(wishlistRepositoryProvider);
    await repo.markAsCompleted(id);
    ref.invalidateSelf();
    await future;
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileModel>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<ProfileModel> {
  @override
  Future<ProfileModel> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    return repo.getProfile();
  }

  Future<void> updateProfile(ProfileModel profile) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.updateProfile(profile);
    ref.invalidateSelf();
    await future;
  }

  Future<void> uploadAvatar(dynamic file, String fileName) async {
    final repo = ref.read(profileRepositoryProvider);
    final avatarUrl = await repo.uploadAvatar(file, fileName);

    final currentProfile = await future;
    final updatedProfile = ProfileModel(
      id: currentProfile.id,
      name: currentProfile.name,
      email: currentProfile.email,
      avatarUrl: avatarUrl,
      weeklyBudget: currentProfile.weeklyBudget,
      createdAt: currentProfile.createdAt,
    );
    await updateProfile(updatedProfile);
  }
}
