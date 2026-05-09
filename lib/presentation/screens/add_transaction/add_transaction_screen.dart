import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_money/application/providers.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/core/theme/app_text_styles.dart';
import 'package:smart_money/core/utils/formatters.dart';
import 'package:smart_money/domain/models/models.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  bool _isIncome = false;
  int _selectedFeeling = 1; // 0=Good, 1=Neutral, 2=Regret
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  CategoryModel? _selectedCategory;
  PaymentMethodModel? _selectedMethod;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Restore last-used payment method
    _selectedMethod = ref.read(lastUsedPaymentMethodProvider);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _feelingValue {
    switch (_selectedFeeling) {
      case 0: return 'happy';
      case 2: return 'regret';
      default: return 'neutral';
    }
  }

  Future<void> _saveTransaction() async {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please enter a valid amount'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // For income, find or use the "Salary" category automatically
      String? categoryId = _selectedCategory?.id;
      if (_isIncome && categoryId == null) {
        final categories = ref.read(categoryListProvider).value ?? [];
        final salaryCategory = categories.where((c) => c.name.toLowerCase() == 'salary' || c.type == 'income').firstOrNull;
        categoryId = salaryCategory?.id;
      }

      final txn = TransactionModel(
        id: '',
        amount: amount,
        type: _isIncome ? 'income' : 'expense',
        categoryId: categoryId,
        paymentMethodId: _selectedMethod?.id,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        date: _selectedDate,
        feeling: _isIncome ? null : _feelingValue,
      );
      await ref.read(transactionListProvider.notifier).add(txn);

      // Remember last-used payment method
      if (_selectedMethod != null) {
        ref.read(lastUsedPaymentMethodProvider.notifier).set(_selectedMethod);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final methodsAsync = ref.watch(paymentMethodListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Background
          Positioned(top: -50, right: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.05)))),
          Positioned(top: MediaQuery.of(context).size.height * 0.4, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tertiary.withValues(alpha: 0.05)))),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                    children: [
                      _buildSegmentedControl(),
                      const SizedBox(height: 32),
                      _buildAmountInput(),
                      if (!_isIncome) ...[
                        const SizedBox(height: 16),
                        _buildQuickAmounts(),
                      ],
                      const SizedBox(height: 32),
                      // For income, hide category picker (auto-salary)
                      if (_isIncome)
                        _buildMethodOnly(methodsAsync)
                      else
                        _buildCategoryMethodGrid(categoriesAsync, methodsAsync),
                      const SizedBox(height: 16),
                      _buildDateSelection(),
                      const SizedBox(height: 16),
                      _buildNoteField(),
                      const SizedBox(height: 24),
                      if (!_isIncome) _buildFeelingPicker(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Save Button
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom == 0 ? 32 : MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [AppColors.surface, AppColors.surface.withValues(alpha: 0.8), AppColors.surface.withValues(alpha: 0.0)]),
              ),
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveTransaction,
                icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_rounded),
                label: Text(_isSaving ? 'Saving...' : 'Save Transaction'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  textStyle: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 8,
                  shadowColor: AppColors.primaryContainer.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant)),
          Text('Add Transaction', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary, fontSize: 20)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          Expanded(child: _segmentButton('Expense', !_isIncome, AppColors.tertiary, AppColors.onTertiary, () => setState(() => _isIncome = false))),
          Expanded(child: _segmentButton('Income', _isIncome, AppColors.secondary, AppColors.onSecondary, () => setState(() => _isIncome = true))),
        ],
      ),
    );
  }

  Widget _segmentButton(String label, bool isActive, Color activeColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: isActive
            ? BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(100), boxShadow: [BoxShadow(color: activeColor.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))])
            : BoxDecoration(borderRadius: BorderRadius.circular(100)),
        child: Center(child: Text(label, style: AppTextStyles.headlineSmall.copyWith(fontSize: 14, color: isActive ? textColor : AppColors.onSurfaceVariant))),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        Text('SET AMOUNT', style: AppTextStyles.labelMedium.copyWith(color: AppColors.outline, fontWeight: FontWeight.w700, letterSpacing: 1, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('Rp', style: AppTextStyles.headlineLarge.copyWith(color: _isIncome ? AppColors.secondary : AppColors.tertiary)),
            const SizedBox(width: 8),
            IntrinsicWidth(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: AppTextStyles.displayLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.onSurface),
                decoration: const InputDecoration(hintText: '0', border: InputBorder.none, contentPadding: EdgeInsets.zero),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAmounts() {
    final quickAmounts = ref.watch(quickAmountsProvider);
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: quickAmounts.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, idx) {
          if (idx == quickAmounts.length) {
            return ActionChip(
              label: const Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
              backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.3),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              onPressed: () {
                final newAmountCtrl = TextEditingController();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Add quick amount'),
                    content: TextField(
                      controller: newAmountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g. 150000', prefixText: 'Rp '),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () {
                          final val = int.tryParse(newAmountCtrl.text);
                          if (val != null && val > 0) {
                            ref.read(quickAmountsProvider.notifier).addAmount(val);
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          final amount = quickAmounts[idx];
          return GestureDetector(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Remove quick amount?'),
                  content: Text('Remove Rp ${CurrencyFormatter.format(amount.toDouble())} from quick amounts?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        ref.read(quickAmountsProvider.notifier).removeAmount(amount);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Remove', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: ActionChip(
              label: Text(CurrencyFormatter.format(amount.toDouble()), style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              backgroundColor: AppColors.surfaceContainerHigh,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              onPressed: () {
                setState(() {
                  _amountController.text = amount.toString();
                });
              },
            ),
          );
        },
      ),
    );
  }

  /// Income mode: only shows payment method (no category — auto-salary)
  Widget _buildMethodOnly(AsyncValue<List<PaymentMethodModel>> methodsAsync) {
    return GestureDetector(
      onTap: () => _showMethodPicker(methodsAsync),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 30, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PAYMENT METHOD', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline, fontWeight: FontWeight.bold, fontSize: 10)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Text('💳', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_selectedMethod?.name ?? 'Select', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                  ]),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }

  /// Expense mode: category + payment method side by side
  Widget _buildCategoryMethodGrid(AsyncValue<List<CategoryModel>> categoriesAsync, AsyncValue<List<PaymentMethodModel>> methodsAsync) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showCategoryPicker(categoriesAsync),
            child: _selectionCard('CATEGORY', _selectedCategory?.icon ?? '📂', _selectedCategory?.name ?? 'Select'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => _showMethodPicker(methodsAsync),
            child: _selectionCard('METHOD', '💳', _selectedMethod?.name ?? 'Select'),
          ),
        ),
      ],
    );
  }

  Widget _selectionCard(String label, String emoji, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 30, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline, fontWeight: FontWeight.bold, fontSize: 10)),
          const SizedBox(height: 8),
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Text(value, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          ]),
        ],
      ),
    );
  }

  void _showCategoryPicker(AsyncValue<List<CategoryModel>> categoriesAsync) {
    final categories = categoriesAsync.value ?? [];
    // Only show expense categories
    final expenseCategories = categories.where((c) => c.type == 'expense' || c.type == null).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Select Category', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: expenseCategories.isEmpty
                    ? [Padding(padding: const EdgeInsets.all(16), child: Text('No categories yet. Add them from Profile → Manage Categories.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline)))]
                    : expenseCategories.map((cat) => ListTile(
                        leading: Text(cat.icon ?? '📂', style: const TextStyle(fontSize: 24)),
                        title: Text(cat.name),
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          Navigator.pop(ctx);
                        },
                      )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMethodPicker(AsyncValue<List<PaymentMethodModel>> methodsAsync) {
    final methods = methodsAsync.value ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Select Payment Method', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: methods.isEmpty
                    ? [Padding(padding: const EdgeInsets.all(16), child: Text('No payment methods yet. Add them from Profile → Manage Payment Methods.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline)))]
                    : methods.map((m) => ListTile(
                        leading: const Icon(Icons.payment_rounded, color: AppColors.primary),
                        title: Text(m.name),
                        onTap: () {
                          setState(() => _selectedMethod = m);
                          Navigator.pop(ctx);
                        },
                      )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 30, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TRANSACTION DATE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline, fontWeight: FontWeight.bold, fontSize: 10)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text('${DateFormatter.formatRelativeDay(_selectedDate)}, ${DateFormatter.formatDate(_selectedDate)}', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                ]),
                const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ADD NOTE (OPTIONAL)', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline, fontWeight: FontWeight.bold, fontSize: 10)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.outline, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(controller: _noteController, style: AppTextStyles.bodyMedium, decoration: const InputDecoration(hintText: 'What was this for?', border: InputBorder.none, contentPadding: EdgeInsets.zero)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildFeelingPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('HOW DO YOU FEEL ABOUT THIS EXPENSE?', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline, fontWeight: FontWeight.bold, fontSize: 10)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
          child: Row(children: [_feelingItem(0, '😊', 'Good'), _feelingItem(1, '😐', 'Neutral'), _feelingItem(2, '😢', 'Regret')]),
        ),
      ],
    );
  }

  Widget _feelingItem(int index, String emoji, String label) {
    final isSelected = _selectedFeeling == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFeeling = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isSelected
              ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))])
              : BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(label, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 10, color: isSelected ? AppColors.onSurface : AppColors.outline)),
            ],
          ),
        ),
      ),
    );
  }
}
