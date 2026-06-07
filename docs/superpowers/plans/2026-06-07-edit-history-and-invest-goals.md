# Edit History & Invest Goals Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add edit capability to the History tab's transaction items and transform the Goals/Wishlist "Buy/Bought" flow into an "Invest" saving-progress flow.

**Architecture:** Two independent features. Feature 1 (Edit History): Refactor `AddTransactionScreen` to accept an optional `TransactionModel` for editing, pre-populate form fields, and call update instead of create. Add tap-to-edit on each history item card. Feature 2 (Invest Goals): Add `savedAmount` field to the wishlist entity/model, replace "Buy/Bought" with "Invest" that adds to `savedAmount` and creates an expense transaction, show progress bar based on `savedAmount/price`.

**Tech Stack:** Flutter (Riverpod, Dio), NestJS (TypeORM, MongoDB), existing codebase patterns

---

## Scope Check

This plan covers two independent features that can be built and tested separately:
- **Part A (Tasks 1-3):** Edit Transaction in History
- **Part B (Tasks 4-8):** Invest in Goals

---

## File Structure

### Part A: Edit History

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/presentation/screens/add_transaction/add_transaction_screen.dart` | Modify | Accept optional transaction for editing, pre-populate fields, call update on save |
| `lib/presentation/screens/report/report_screen.dart` | Modify | Add tap handler on `_historyItem` to open edit screen |

### Part B: Invest Goals

| File | Action | Responsibility |
|------|--------|----------------|
| `backend/src/modules/wishlist/entities/wishlist-item.entity.ts` | Modify | Add `savedAmount` column |
| `backend/src/modules/wishlist/dto/create-wishlist-item.dto.ts` | Modify | Add optional `savedAmount` field |
| `backend/src/modules/wishlist/controllers/wishlist.controller.ts` | Modify | Add `PATCH :id/invest` endpoint, update serialization |
| `backend/src/modules/wishlist/services/wishlist.service.ts` | Modify | Add `invest` method that adds to savedAmount |
| `lib/domain/models/models.dart` | Modify | Add `savedAmount` to `WishlistItemModel` |
| `lib/data/datasources/wishlist_remote_data_source.dart` | Modify | Add `invest` method |
| `lib/domain/repositories/repositories.dart` | Modify | Add `invest` to `WishlistRepository` |
| `lib/data/repositories/repository_impl.dart` | Modify | Implement `invest` in `WishlistRepositoryImpl` |
| `lib/application/providers.dart` | Modify | Add `invest` method to `WishlistNotifier` |
| `lib/presentation/screens/wishlist/wishlist_screen.dart` | Modify | Replace Buy/Bought UI with Invest progress UI |

---

## Part A: Edit Transaction in History

### Task 1: Make AddTransactionScreen support editing

**Files:**
- Modify: `lib/presentation/screens/add_transaction/add_transaction_screen.dart`

- [ ] **Step 1: Add optional TransactionModel parameter**

In `add_transaction_screen.dart`, add an optional `transaction` parameter to the widget:

```dart
class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}
```

- [ ] **Step 2: Pre-populate fields in initState when editing**

In `_AddTransactionScreenState.initState()`, after the existing `_selectedMethod` line, add pre-population:

```dart
@override
void initState() {
  super.initState();
  _selectedMethod = ref.read(lastUsedPaymentMethodProvider);

  final txn = widget.transaction;
  if (txn != null) {
    _isIncome = txn.isIncome;
    _amountController.text = txn.amount.toInt().toString();
    _noteController.text = txn.note ?? '';
    _selectedDate = txn.date;
    _selectedFeeling = txn.feeling == 'happy'
        ? 0
        : txn.feeling == 'regret'
            ? 2
            : 1;
  }
}
```

- [ ] **Step 3: Add didChangeDependencies to set category and method**

Add this override after `initState`:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final txn = widget.transaction;
  if (txn != null && _selectedCategory == null) {
    final categories = ref.read(categoryListProvider).value ?? [];
    final methods = ref.read(paymentMethodListProvider).value ?? [];
    _selectedCategory = categories
        .where((c) => c.id == txn.categoryId)
        .firstOrNull;
    _selectedMethod = methods
        .where((m) => m.id == txn.paymentMethodId)
        .firstOrNull ?? ref.read(lastUsedPaymentMethodProvider);
    setState(() {});
  }
}
```

- [ ] **Step 4: Update _saveTransaction to handle edit mode**

In `_saveTransaction()`, replace the block starting from `setState(() => _isSaving = true);` through the end of the try/catch/finally with:

```dart
setState(() => _isSaving = true);
try {
  String? categoryId = _selectedCategory?.id;
  if (_isIncome && categoryId == null) {
    final categories = ref.read(categoryListProvider).value ?? [];
    final salaryCategory = categories
        .where(
          (c) => c.name.toLowerCase() == 'salary' || c.type == 'income',
        )
        .firstOrNull;
    categoryId = salaryCategory?.id;
  }

  final txn = TransactionModel(
    id: widget.transaction?.id ?? '',
    amount: amount,
    type: _isIncome ? 'income' : 'expense',
    categoryId: categoryId,
    paymentMethodId: _selectedMethod?.id,
    note: _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim(),
    date: _selectedDate,
    feeling: _isIncome ? null : _feelingValue,
  );

  if (widget.transaction != null) {
    await ref.read(transactionListProvider.notifier).updateTransaction(txn);
  } else {
    await ref.read(transactionListProvider.notifier).add(txn);
  }

  if (_selectedMethod != null) {
    ref.read(lastUsedPaymentMethodProvider.notifier).set(_selectedMethod);
  }

  if (mounted) {
    NotificationService.showSuccess(
      widget.transaction != null
          ? 'Transaction updated'
          : 'Transaction saved',
    );
    Navigator.pop(context);
  }
} catch (e) {
  if (mounted) {
    NotificationService.showError('Error: $e');
  }
} finally {
  if (mounted) setState(() => _isSaving = false);
}
```

- [ ] **Step 5: Update the title and button text dynamically**

In the `build` method, find the screen title text and change it to:

```dart
widget.transaction != null ? 'Edit Transaction' : 'Add Transaction'
```

And update the save button text to:

```dart
widget.transaction != null ? 'Update' : 'Save'
```

- [ ] **Step 6: Skip smart alert when editing**

In `_saveTransaction()`, change the smart alert condition from:

```dart
if (!_isIncome && _feelingValue == 'regret') {
```

to:

```dart
if (widget.transaction == null && !_isIncome && _feelingValue == 'regret') {
```

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/screens/add_transaction/add_transaction_screen.dart
git commit -m "feat: support editing existing transactions in AddTransactionScreen"
```

---

### Task 2: Add tap-to-edit on History items

**Files:**
- Modify: `lib/presentation/screens/report/report_screen.dart`

- [ ] **Step 1: Add import for AddTransactionScreen**

At the top of `report_screen.dart`, add:

```dart
import 'package:smart_money/presentation/screens/add_transaction/add_transaction_screen.dart';
```

- [ ] **Step 2: Wrap _historyItem in a tap handler**

In the `_historyItem` method, wrap the return `Padding(...)` widget with an `InkWell`. Replace:

```dart
return Padding(
  padding: const EdgeInsets.all(16),
  child: Row(
```

With:

```dart
return InkWell(
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(transaction: txn),
      ),
    );
    if (mounted) setState(() {});
  },
  borderRadius: BorderRadius.circular(16),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
```

Close with an extra `)` at the end of the return.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/report/report_screen.dart
git commit -m "feat: add tap-to-edit on history transaction items"
```

---

### Task 3: Verify edit flow end-to-end

- [ ] **Step 1: Test editing an expense transaction**

1. Run `flutter run`
2. Go to Report tab -> History sub-tab
3. Tap on an expense transaction
4. Verify: form pre-populates with amount, category, payment method, note, feeling
5. Change amount and category, tap Update
6. Verify: "Transaction updated" notification, updated value in list

- [ ] **Step 2: Test editing an income transaction**

1. Tap on an income transaction
2. Change amount, tap Update
3. Verify: "Transaction updated" notification and updated value

- [ ] **Step 3: Test that new transactions still work**

1. Tap "+" on home screen to add new transaction
2. Fill fields, tap Save
3. Verify: "Transaction saved" notification, new transaction appears

- [ ] **Step 4: Commit fixes if needed**

```bash
git add -A
git commit -m "fix: polish edit transaction flow"
```

---

## Part B: Invest in Goals (Wishlist Saving)

### Task 4: Add savedAmount to backend entity and DTO

**Files:**
- Modify: `backend/src/modules/wishlist/entities/wishlist-item.entity.ts`
- Modify: `backend/src/modules/wishlist/dto/create-wishlist-item.dto.ts`

- [ ] **Step 1: Add savedAmount column to entity**

In `wishlist-item.entity.ts`, add after the `price` column:

```typescript
@Column({ type: 'double precision', default: 0 }) savedAmount: number;
```

Full entity:

```typescript
import { Entity, Column, ObjectIdColumn, CreateDateColumn } from "typeorm";
import { ObjectId } from "mongodb";

@Entity('wishlist_items')
export class WishlistItem {
  @ObjectIdColumn() id: ObjectId;
  @Column() userId: string;
  @Column() name: string;
  @Column({ type: 'double precision' }) price: number;
  @Column({ type: 'double precision', default: 0 }) savedAmount: number;
  @Column({ default: 'pending' }) status: string;
  @Column({ nullable: true }) imagePath: string;
  @CreateDateColumn({ type: Date }) createdAt: Date;
}
```

- [ ] **Step 2: Add savedAmount to DTO**

In `create-wishlist-item.dto.ts`, add after `price`:

```typescript
@IsOptional() @Type(() => Number) @IsNumber() savedAmount?: number;
```

- [ ] **Step 3: Commit**

```bash
git add backend/src/modules/wishlist/entities/wishlist-item.entity.ts backend/src/modules/wishlist/dto/create-wishlist-item.dto.ts
git commit -m "feat: add savedAmount field to wishlist entity and DTO"
```

---

### Task 5: Add invest endpoint to backend

**Files:**
- Modify: `backend/src/modules/wishlist/controllers/wishlist.controller.ts`
- Modify: `backend/src/modules/wishlist/services/wishlist.service.ts`

- [ ] **Step 1: Add invest method to service**

In `wishlist.service.ts`, add after the `markCompleted` method:

```typescript
async invest(id: string, amount: number): Promise<WishlistItem> {
  const item = await this.repository.findById(id);
  if (!item) throw new NotFoundException('Wishlist item not found');
  const newSavedAmount = (item.savedAmount || 0) + amount;
  const updatedItem = await this.repository.update(id, {
    savedAmount: newSavedAmount,
    status: newSavedAmount >= item.price ? 'completed' : 'pending',
  });
  return updatedItem;
}
```

- [ ] **Step 2: Add invest endpoint to controller**

In `wishlist.controller.ts`, add after the `@Patch(':id/complete')` method:

```typescript
@Patch(':id/invest')
async invest(
  @Param('id') id: string,
  @Body() body: { amount: number },
  @CurrentUser('id') userId: string,
) {
  const item = await this.service.invest(id, body.amount);
  return {
    id: (item as any).id.toHexString(),
    name: item.name,
    price: item.price,
    savedAmount: item.savedAmount,
    status: item.status,
  };
}
```

- [ ] **Step 3: Add savedAmount to all controller response objects**

In the controller's `findAll`, `create`, and `update` methods, add `savedAmount: item.savedAmount || 0` to each response object.

- [ ] **Step 4: Commit**

```bash
git add backend/src/modules/wishlist/controllers/wishlist.controller.ts backend/src/modules/wishlist/services/wishlist.service.ts
git commit -m "feat: add invest endpoint and savedAmount to wishlist API"
```

---

### Task 6: Update frontend model and data layer for invest

**Files:**
- Modify: `lib/domain/models/models.dart`
- Modify: `lib/data/datasources/wishlist_remote_data_source.dart`
- Modify: `lib/domain/repositories/repositories.dart`
- Modify: `lib/data/repositories/repository_impl.dart`
- Modify: `lib/application/providers.dart`

- [ ] **Step 1: Add savedAmount to WishlistItemModel**

In `models.dart`, in the `WishlistItemModel` class, add field:

```dart
final double savedAmount;
```

Add to constructor:

```dart
required this.savedAmount,
```

Update `fromJson` to read:

```dart
savedAmount: (json['saved_amount'] ?? 0).toDouble(),
```

Update the `progress` getter:

```dart
double get progress => price > 0 ? (savedAmount / price).clamp(0.0, 1.0) : 0.0;
```

Remove the old `progress` getter that returns `1.0`/`0.0` based on status.

- [ ] **Step 2: Add invest method to data source**

In `wishlist_remote_data_source.dart`, add:

```dart
Future<void> invest(String id, double amount) async {
  await DioClient.instance.patch(
    '${ApiConfig.wishlist}/$id/invest',
    data: {'amount': amount},
  );
}
```

- [ ] **Step 3: Add invest to repository interface**

In `repositories.dart`, add to `WishlistRepository`:

```dart
Future<void> invest(String id, double amount);
```

- [ ] **Step 4: Implement invest in repository**

In `repository_impl.dart`, add to `WishlistRepositoryImpl`:

```dart
@override
Future<void> invest(String id, double amount) async {
  await _dataSource.invest(id, amount);
}
```

- [ ] **Step 5: Add invest to WishlistNotifier**

In `providers.dart`, add to `WishlistNotifier`:

```dart
Future<void> invest(String id, double amount) async {
  try {
    await _repository.invest(id, amount);
    ref.invalidateSelf();
    NotificationService.showSuccess('Investment added to goal!');
  } catch (e) {
    NotificationService.showError('Failed to invest: $e');
  }
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/domain/models/models.dart lib/data/datasources/wishlist_remote_data_source.dart lib/domain/repositories/repositories.dart lib/data/repositories/repository_impl.dart lib/application/providers.dart
git commit -m "feat: add savedAmount model and invest data layer for goals"
```

---

### Task 7: Update Goals screen UI -- Invest instead of Buy/Bought

**Files:**
- Modify: `lib/presentation/screens/wishlist/wishlist_screen.dart`

- [ ] **Step 1: Replace Buy button with Invest button**

In `_wishlistCard`, find the Buy/Bought conditional block and replace it with:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      '${CurrencyFormatter.format(item.savedAmount)} / ${CurrencyFormatter.format(item.price)}',
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    ),
    const SizedBox(height: 4),
    if (item.isPending)
      GestureDetector(
        onTap: () => _showInvestDialog(item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.savings_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'Invest',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    if (item.isCompleted)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 16),
            const SizedBox(width: 4),
            Text(
              'Goal Reached!',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
  ],
),
```

- [ ] **Step 2: Add the invest dialog method**

Add this method to `_WishlistScreenState`:

```dart
void _showInvestDialog(WishlistItemModel item) {
  final controller = TextEditingController();
  final remaining = item.price - item.savedAmount;

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
        24, 24, 24, 24 + MediaQuery.of(ctx).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Invest for ${item.name}',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Remaining: ${CurrencyFormatter.format(remaining)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
              prefixText: 'Rp ',
              prefixStyle: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final amount = double.tryParse(
                  controller.text.replaceAll(RegExp(r'[^0-9.]'), ''),
                );
                if (amount == null || amount <= 0) {
                  NotificationService.showError('Enter a valid amount');
                  return;
                }
                Navigator.pop(ctx);
                ref.read(wishlistProvider.notifier).invest(item.id, amount);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Invest',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 3: Remove the old _handleBuy method**

Delete `_handleBuy` from `_WishlistScreenState` since it is no longer used.

- [ ] **Step 4: Update WishlistItemModel creation in _showAddDialog**

In `_showAddDialog`, add `savedAmount: 0` to the `WishlistItemModel` constructor:

```dart
WishlistItemModel(
  id: '',
  userId: '',
  name: name,
  price: price,
  savedAmount: 0,
  status: 'pending',
  imagePath: localPath,
),
```

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/wishlist/wishlist_screen.dart
git commit -m "feat: replace buy/bought with invest saving flow on goals screen"
```

---

### Task 8: Verify invest flow end-to-end

- [ ] **Step 1: Test creating a new goal**

1. Go to Goals tab
2. Tap "+" to add new item (e.g., "iPhone" -- Rp 15,000,000)
3. Verify: item appears with "Rp 0 / Rp 15.000.000" and an "Invest" button

- [ ] **Step 2: Test investing in a goal**

1. Tap "Invest" on the iPhone goal
2. Enter "2,000,000"
3. Tap "Invest"
4. Verify: "Investment added to goal!" notification
5. Verify: progress updates to "Rp 2.000.000 / Rp 15.000.000"

- [ ] **Step 3: Test completing a goal**

1. Keep investing until savedAmount >= price
2. Verify: status changes to "completed", shows "Goal Reached!" badge

- [ ] **Step 4: Test edit history**

1. Go to Report -> History
2. Tap any transaction, edit amount, save
3. Verify: updated amount appears in history

- [ ] **Step 5: Push to Railway**

```bash
git push
```

Verify Railway redeploy succeeds and test again with deployed backend.

- [ ] **Step 6: Final commit if fixes needed**

```bash
git add -A
git commit -m "fix: polish invest and edit history flows"
```
