import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_money/application/providers.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/core/theme/app_text_styles.dart';
import 'package:smart_money/core/utils/formatters.dart';
import 'package:smart_money/domain/models/models.dart';
import 'package:smart_money/domain/utils/period_filters.dart';
import 'package:smart_money/presentation/app_shell.dart';

/// Aggregated spending data per category, used by the home screen summary.
class _CategorySummary {
  final String name;
  final String icon; // emoji from transaction.categoryIcon
  final double totalAmount;
  final int txnCount;

  const _CategorySummary({
    required this.name,
    required this.icon,
    required this.totalAmount,
    required this.txnCount,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedPeriodIndex = 1; // 0=daily, 1=weekly, 2=monthly

  Period get _selectedPeriod => [Period.daily, Period.weekly, Period.monthly][_selectedPeriodIndex];

  String get _periodLabel => ['Daily', 'Weekly', 'Monthly'][_selectedPeriodIndex];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopAppBar(context, profileAsync),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (transactions) {
                  // Filter by selected period
                  final filteredTransactions = filterTransactionsByPeriod(transactions, _selectedPeriod);
                  
                  final totalIncome = filteredTransactions
                      .where((t) => t.isIncome)
                      .fold(0.0, (sum, t) => sum + t.amount);
                  final totalExpense = filteredTransactions
                      .where((t) => t.isExpense)
                      .fold(0.0, (sum, t) => sum + t.amount);
                  final netBalance = totalIncome - totalExpense;

                  // Build category summaries: aggregate amount + count + icon,
                  // then sort descending by total spend so the heaviest
                  // categories appear at the top.
                  final catAmounts = <String, double>{};
                  final catIcons = <String, String>{};
                  final catCounts = <String, int>{};
                  
                  for (final t in filteredTransactions.where((t) => t.isExpense)) {
                    final cat = t.categoryName ?? 'Unknown';
                    catAmounts[cat] = (catAmounts[cat] ?? 0) + t.amount;
                    catIcons[cat] ??= t.categoryIcon ?? '💰';
                    catCounts[cat] = (catCounts[cat] ?? 0) + 1;
                  }
                  
                  final sortedCategories = catAmounts.keys
                      .map((cat) => _CategorySummary(
                            name: cat,
                            icon: catIcons[cat]!,
                            totalAmount: catAmounts[cat]!,
                            txnCount: catCounts[cat]!,
                          ))
                      .toList()
                    ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                    children: [
                      _buildGreeting(profileAsync),
                      const SizedBox(height: 16),
                      _buildPeriodSelector(),
                      const SizedBox(height: 16),
                      _buildHeroCard(netBalance, totalIncome, totalExpense),
                      const SizedBox(height: 40),
                      _buildInsightToast(sortedCategories),
                      const SizedBox(height: 40),
                      _buildSpendingByCategory(sortedCategories, totalExpense),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, AsyncValue<ProfileModel> profileAsync) {
    final fullName = profileAsync.value?.name ?? 'Smart Money';
    final firstName = fullName.split(' ').first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning,' : hour < 17 ? 'Good afternoon,' : 'Good evening,';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  final appShellState = context.findAncestorStateOfType<AppShellState>();
                  appShellState?.switchToTab(3);
                },
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    color: AppColors.surfaceContainerHigh,
                    image: profileAsync.value?.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(profileAsync.value!.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profileAsync.value?.avatarUrl == null
                      ? const Icon(Icons.person, color: AppColors.outline)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting, style: AppTextStyles.labelMedium.copyWith(color: AppColors.outline)),
                  Text(firstName, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                ],
              ),
            ],
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildGreeting(AsyncValue<ProfileModel> profileAsync) {
    final fullName = profileAsync.value?.name ?? 'User';
    final firstName = fullName.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back, $firstName', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Your finances are looking healthy today.', style: AppTextStyles.labelMedium),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        ...['Daily', 'Weekly', 'Monthly'].asMap().entries.map((entry) {
          final i = entry.key;
          final label = entry.value;
          final isSelected = _selectedPeriodIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriodIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ].expand((w) => [w, const SizedBox(width: 8)]).toList()..removeLast(),
    );
  }

  Widget _buildHeroCard(double netBalance, double totalIncome, double totalExpense) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 32, offset: const Offset(0, 16))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_periodLabel.toUpperCase()} SUMMARY', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onPrimaryContainer.withValues(alpha: 0.8), letterSpacing: 1.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(CurrencyFormatter.format(netBalance), style: AppTextStyles.displayLarge.copyWith(color: AppColors.onPrimaryContainer)),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _summaryBox('INCOME', CurrencyFormatter.format(totalIncome), const Color(0xFF8ff6d0), Icons.arrow_upward_rounded)),
              const SizedBox(width: 16),
              Expanded(child: _summaryBox('EXPENSE', CurrencyFormatter.format(totalExpense), const Color(0xFFffb4ac), Icons.arrow_downward_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(String label, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ]),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount, style: AppTextStyles.titleMedium.copyWith(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightToast(List<_CategorySummary> sortedCategories) {
    final topCategory = sortedCategories.isNotEmpty ? sortedCategories.first.name : 'spending';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppColors.secondary, width: 4)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondaryContainer),
            child: const Icon(Icons.stars_rounded, color: AppColors.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart Insight', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                Text('Your top spending category is $topCategory', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingByCategory(List<_CategorySummary> sortedCategories, double totalExpense) {
    final categoryColors = [Colors.orange, Colors.blue, Colors.purple, Colors.teal, Colors.pink, Colors.amber, Colors.red, Colors.indigo];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Spending by Category', style: AppTextStyles.headlineMedium),
            Builder(builder: (context) => GestureDetector(
              onTap: () {
                final shell = context.findAncestorStateOfType<AppShellState>();
                shell?.switchToTab(1);
              },
              child: Text('See All', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
            )),
          ],
        ),
        const SizedBox(height: 24),
        if (sortedCategories.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
            child: Center(child: Text('No expense data yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline))),
          )
        else
          ...sortedCategories.take(5).toList().asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final colorBase = categoryColors[i % categoryColors.length];
            final progress = totalExpense > 0 ? cat.totalAmount / totalExpense : 0.0;

            return _categoryItem(
              emoji: cat.icon,
              title: cat.name,
              subtitle: '${cat.txnCount} Transaction${cat.txnCount != 1 ? 's' : ''}',
              amount: CurrencyFormatter.format(cat.totalAmount),
              progress: progress,
              progressColor: colorBase.shade400,
              iconBg: colorBase.shade100,
            );
          }),
      ],
    );
  }

  Widget _categoryItem({
    required String emoji,
    required String title,
    required String subtitle,
    required String amount,
    required double progress,
    required Color progressColor,
    required Color iconBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
                  ],
                ),
              ]),
              Text(amount, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, backgroundColor: AppColors.surfaceContainerHighest, color: progressColor, minHeight: 8),
          ),
        ],
      ),
    );
  }
}