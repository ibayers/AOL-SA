class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String type; // 'income' | 'expense'
  final String? categoryId;
  final String? paymentMethodId;
  final String? note;
  final DateTime date;
  final String? feeling; // 'happy' | 'neutral' | 'regret'
  final DateTime? createdAt;

  final String? categoryName;
  final String? categoryIcon;
  final String? paymentMethodName;

  const TransactionModel({
    required this.id,
    this.userId = '',
    required this.amount,
    required this.type,
    this.categoryId,
    this.paymentMethodId,
    this.note,
    required this.date,
    this.feeling,
    this.createdAt,
    this.categoryName,
    this.categoryIcon,
    this.paymentMethodName,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Extract joined category/payment_method names
    final categoryData = json['categories'] as Map<String, dynamic>?;
    final paymentData = json['payment_methods'] as Map<String, dynamic>?;

    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      categoryId: json['category_id'] as String?,
      paymentMethodId: json['payment_method_id'] as String?,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      feeling: json['feeling'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      categoryName: categoryData?['name'] as String?,
      categoryIcon: categoryData?['icon'] as String?,
      paymentMethodName: paymentData?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'payment_method_id': paymentMethodId,
      'note': note,
      'date': date.toIso8601String(),
      'feeling': feeling,
    };
  }
}

class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String? icon;
  final String? type; // 'income' | 'expense'
  final DateTime? createdAt;

  const CategoryModel({
    required this.id,
    this.userId = '',
    required this.name,
    this.icon,
    this.type,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'icon': icon, 'type': type};
  }
}

class PaymentMethodModel {
  final String id;
  final String userId;
  final String name;
  final DateTime? createdAt;

  const PaymentMethodModel({
    required this.id,
    this.userId = '',
    required this.name,
    this.createdAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class WishlistItemModel {
  final String id;
  final String userId;
  final String name;
  final double price;
  final String status;
  final String? imagePath;
  final DateTime? createdAt;

  const WishlistItemModel({
    required this.id,
    this.userId = '',
    required this.name,
    required this.price,
    required this.status,
    this.imagePath,
    this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  double get progress => isCompleted ? 1.0 : 0.0;

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'status': status};
  }
}

class ProfileModel {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final double weeklyBudget;
  final DateTime? createdAt;

  const ProfileModel({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.weeklyBudget = 0,
    this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      weeklyBudget: (json['weekly_budget'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'weekly_budget': weeklyBudget,
    };
  }
}
