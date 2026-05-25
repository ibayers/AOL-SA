import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_money/application/providers.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/core/theme/app_text_styles.dart';
import 'package:smart_money/core/utils/formatters.dart';
import 'package:smart_money/domain/models/models.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  int _currentTab = 0; // 0 = Summary, 1 = History
  int _timeFilter = 1; // 0 = Week, 1 = Month, 2 = Year
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedFeelingFilter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime get _filterStart {
    final now = DateTime.now();
    switch (_timeFilter) {
      case 0:
        return now.subtract(const Duration(days: 7));
      case 2:
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  String get _filterLabel =>
      ['This Week', 'This Month', 'This Year'][_timeFilter];
  int get _filterDays => _timeFilter == 0
      ? 7
      : _timeFilter == 2
      ? 365
      : 30;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (allTransactions) {
                  final transactions = allTransactions
                      .where((t) => t.date.isAfter(_filterStart))
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                    children: [
                      _buildSegmentedControl(),
                      const SizedBox(height: 24),
                      if (_currentTab == 0) _buildSummaryTab(transactions),
                      if (_currentTab == 1) _buildHistoryTab(transactions),
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

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Smart Money',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [_segmentTab(0, 'Summary'), _segmentTab(1, 'History')],
      ),
    );
  }

  Widget _segmentTab(int index, String title) {
    final isActive = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: isActive
              ? BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilter() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(ctx).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Select Time Range', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 16),
                _timeFilterOption(
                  ctx,
                  0,
                  'This Week',
                  Icons.calendar_view_week_rounded,
                ),
                _timeFilterOption(
                  ctx,
                  1,
                  'This Month',
                  Icons.calendar_month_rounded,
                ),
                _timeFilterOption(
                  ctx,
                  2,
                  'This Year',
                  Icons.calendar_today_rounded,
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Text(
              _filterLabel,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _timeFilterOption(
    BuildContext ctx,
    int index,
    String label,
    IconData icon,
  ) {
    final isSelected = _timeFilter == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.outline,
      ),
      title: Text(
        label,
        style: AppTextStyles.titleSmall.copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.onSurface,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() => _timeFilter = index);
        Navigator.pop(ctx);
      },
    );
  }

  Widget _buildSummaryTab(List<TransactionModel> transactions) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);

    final catMap = <String, double>{};
    for (final t in expenses) {
      final cat = t.categoryName ?? 'Unknown';
      catMap[cat] = (catMap[cat] ?? 0) + t.amount;
    }
    final sorted = catMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final chartColors = [
      AppColors.primary,
      AppColors.primaryContainer,
      AppColors.tertiary,
      AppColors.outlineVariant,
      AppColors.secondary,
    ];
    final sections = sorted.asMap().entries.map((e) {
      final pct = totalExpense > 0 ? (e.value.value / totalExpense * 100) : 0.0;
      return PieChartSectionData(
        color: chartColors[e.key % chartColors.length],
        value: pct,
        radius: 16,
        showTitle: false,
      );
    }).toList();

    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          color: AppColors.outlineVariant,
          value: 100,
          radius: 16,
          showTitle: false,
        ),
      );
    }

    final topCat = sorted.isNotEmpty ? sorted.first.key : '-';
    final topPct = sorted.isNotEmpty && totalExpense > 0
        ? (sorted.first.value / totalExpense * 100).round()
        : 0;
    final avgDaily = totalExpense > 0 ? totalExpense / _filterDays : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Expense Report',
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
            ),
            _buildTimeFilter(),
          ],
        ),
        const SizedBox(height: 24),
        // Donut Chart
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 84,
                        sectionsSpace: 4,
                        startDegreeOffset: -90,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Spent',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatCompact(totalExpense),
                            style: AppTextStyles.headlineLarge.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: sorted
                    .take(4)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => _legendItem(
                        chartColors[e.key % chartColors.length],
                        e.value.key,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Insights Bento
        Row(
          children: [
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HIGHEST SPENDING',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topCat,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$topPct% of total budget',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVERAGE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatCompact(avgDaily),
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Daily Outflow',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.trending_down_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Transactions',
                            style: AppTextStyles.headlineMedium.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${transactions.length} transactions recorded',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: AppColors.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filter by search query
    var filtered = transactions;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                (t.categoryName ?? '').toLowerCase().contains(_searchQuery) ||
                (t.note ?? '').toLowerCase().contains(_searchQuery) ||
                (t.paymentMethodName ?? '').toLowerCase().contains(
                  _searchQuery,
                ),
          )
          .toList();
    }
    if (_selectedFeelingFilter != null) {
      filtered = filtered
          .where((t) => t.feeling?.toLowerCase() == _selectedFeelingFilter)
          .toList();
    }

    // Group by day
    final grouped = <String, List<TransactionModel>>{};
    for (final t in filtered) {
      final dayKey = DateFormatter.formatRelativeDay(t.date);
      grouped.putIfAbsent(dayKey, () => []).add(t);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.outline,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyles.bodyMedium,
                        decoration: const InputDecoration(
                          hintText: 'Search transactions...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                // Open Time Filter picker
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (ctx) => Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      20 + MediaQuery.of(ctx).padding.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Select Time Range',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        _timeFilterOption(
                          ctx,
                          0,
                          'This Week',
                          Icons.calendar_view_week_rounded,
                        ),
                        _timeFilterOption(
                          ctx,
                          1,
                          'This Month',
                          Icons.calendar_month_rounded,
                        ),
                        _timeFilterOption(
                          ctx,
                          2,
                          'This Year',
                          Icons.calendar_today_rounded,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFeelingFilterChip(null, 'All', '🌟'),
              const SizedBox(width: 8),
              _buildFeelingFilterChip('happy', 'Happy', '😊'),
              const SizedBox(width: 8),
              _buildFeelingFilterChip('neutral', 'Neutral', '😐'),
              const SizedBox(width: 8),
              _buildFeelingFilterChip('regret', 'Regret', '😢'),
            ],
          ),
        ),
        const SizedBox(height: 32),

        ...grouped.entries.map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTransactionGroup(entry.key, entry.value),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeelingFilterChip(String? value, String label, String emoji) {
    final isSelected = _selectedFeelingFilter == value;
    return ChoiceChip(
      showCheckmark: false,
      label: Text(
        '$emoji  $label',
        style: AppTextStyles.labelMedium.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFeelingFilter = value);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerHigh,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildTransactionGroup(String title, List<TransactionModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (idx > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        height: 1,
                        color: AppColors.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                  _historyItem(item),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _historyItem(TransactionModel txn) {
    final isExpense = txn.isExpense;
    final amountStr = isExpense
        ? '-${CurrencyFormatter.format(txn.amount)}'
        : '+${CurrencyFormatter.format(txn.amount)}';
    final category = txn.categoryName ?? 'Unknown';
    final method = txn.paymentMethodName ?? 'Cash';
    final note = txn.note ?? '';
    final feelingStr = txn.feeling?.toLowerCase();
    final feelingEmoji = feelingStr == 'happy'
        ? ' 😊'
        : feelingStr == 'neutral'
        ? ' 😐'
        : feelingStr == 'regret'
        ? ' 😢'
        : '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isExpense
                  ? AppColors.secondaryContainer
                  : const Color(0xFF93f2f2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isExpense ? Icons.shopping_bag_rounded : Icons.payments_rounded,
              color: isExpense ? AppColors.secondary : const Color(0xFF002020),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$category$feelingEmoji',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      amountStr,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isExpense
                            ? AppColors.tertiary
                            : AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        method,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.outline,
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
