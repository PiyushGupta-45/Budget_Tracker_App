import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/expense_notifier.dart';

// --- Stats Cards (Fixed to rebuild only when analytics change) ---
class StatsCards extends StatelessWidget {
  const StatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Only watch analytics data
    final analytics = context.select((ExpenseNotifier n) => n.analytics);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          title: 'Total Spent',
          value: '₹${analytics.total.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.blue,
          iconBgColor: Colors.blue.shade100,
        ),
        _buildStatCard(
          context,
          title: 'Total Expenses',
          value: '${analytics.expenses.length}',
          icon: Icons.trending_up,
          color: Colors.green,
          iconBgColor: Colors.green.shade100,
        ),
        _buildStatCard(
          context,
          title: 'Daily Average',
          value: '₹${analytics.monthlyAverage.toStringAsFixed(2)}',
          icon: Icons.calendar_today,
          color: Colors.purple,
          iconBgColor: Colors.purple.shade100,
        ),
        // 🎯 UPDATED CARD: Total Days Tracked
        _buildStatCard(
          context,
          title: 'Total Days Tracked',
          value:
              '${analytics.dailySpending.keys.length}', // Uses the count of unique expense dates
          icon: Icons.access_time_filled, // Icon for time/days
          color: Colors.orange,
          iconBgColor: Colors.orange.shade100,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Expense Distribution View (Chart) ---
class ExpenseDistributionView extends StatelessWidget {
  const ExpenseDistributionView({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.select((ExpenseNotifier n) => n.analytics);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Distribution',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          if (analytics.categoryTotals.isEmpty)
            _buildEmptyState()
          else
            ...analytics.categoryTotals.map((item) {
              final Category category = item['category'] as Category;
              final double total = item['total'] as double;
              final double percentage = item['percentage'] as double;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              category.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(category.color),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Text('📊', style: TextStyle(fontSize: 48)),
          SizedBox(height: 10),
          Text(
            'No data to display',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 5),
          Text('Add some expenses to see your spending distribution!'),
        ],
      ),
    );
  }
}

// --- Advanced Analytics View ---
class AdvancedAnalyticsView extends StatelessWidget {
  const AdvancedAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.select((ExpenseNotifier n) => n.analytics);
    final filteredExpenses = context.select(
      (ExpenseNotifier n) => n.filteredExpenses,
    );

    final sortedCategoryTotals =
        analytics.categoryTotals
            .where((item) => (item['total'] as double) > 0)
            .toList()
          ..sort(
            (a, b) => (b['total'] as double).compareTo(a['total'] as double),
          );

    return Column(
      children: [
        DailySpendingTrends(analytics: analytics),
        const SizedBox(height: 16),

        TopSpendingCategories(
          analytics: analytics,
          sortedCategoryTotals: sortedCategoryTotals,
        ),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: QuickStats(analytics: analytics)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SpendingInsights(
                      analytics: analytics,
                      filteredExpenses: filteredExpenses,
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  QuickStats(analytics: analytics),
                  const SizedBox(height: 16),
                  SpendingInsights(
                    analytics: analytics,
                    filteredExpenses: filteredExpenses,
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}

class DailySpendingTrends extends StatelessWidget {
  final Analytics analytics;
  const DailySpendingTrends({required this.analytics, super.key});

  @override
  Widget build(BuildContext context) {
    final sortedDailySpending = analytics.dailySpending.entries.toList()
      ..sort((a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key)));

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Spending Trends',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          if (sortedDailySpending.isEmpty)
            _buildEmptyState()
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: sortedDailySpending.length,
                itemBuilder: (context, index) {
                  final entry = sortedDailySpending[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.purple.shade50],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDate(entry.key),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '₹${entry.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Text('📈', style: TextStyle(fontSize: 48)),
          SizedBox(height: 10),
          Text(
            'No spending data available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 5),
          Text('Start adding expenses to see your daily trends!'),
        ],
      ),
    );
  }
}

class TopSpendingCategories extends StatelessWidget {
  final Analytics analytics;
  final List<Map<String, dynamic>> sortedCategoryTotals;
  const TopSpendingCategories({
    required this.analytics,
    required this.sortedCategoryTotals,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Spending Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: min(6, sortedCategoryTotals.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final item = sortedCategoryTotals[index];
              final Category category = item['category'] as Category;
              final double total = item['total'] as double;
              final double percentage = item['percentage'] as double;
              return Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: category.color, width: 3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category.icon,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                '₹${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: category.color,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade500,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class QuickStats extends StatelessWidget {
  final Analytics analytics;
  // Removed filteredExpenses from constructor as it's not strictly needed for this widget's output
  const QuickStats({required this.analytics, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          _buildStatRow(
            'Highest Single Expense',
            '₹${analytics.highestExpense.toStringAsFixed(2)}',
            Colors.blue.shade50,
            Colors.blue.shade600,
          ),
          _buildStatRow(
            'Lowest Single Expense',
            '₹${analytics.lowestExpense.toStringAsFixed(2)}',
            Colors.green.shade50,
            Colors.green.shade600,
          ),
          _buildStatRow(
            'Most Used Category',
            analytics.mostUsedCategory?.name ?? 'None',
            Colors.purple.shade50,
            Colors.purple.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class SpendingInsights extends StatelessWidget {
  final Analytics analytics;
  final List<Expense> filteredExpenses;
  const SpendingInsights({
    required this.analytics,
    required this.filteredExpenses,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mostUsedCategoryName = analytics.mostUsedCategory?.name ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Insights',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          _buildInsightCard(
            'Budget Tip:',
            'Your top category is $mostUsedCategoryName. Consider setting a monthly limit!',
            Colors.yellow.shade100,
            Colors.yellow.shade600,
          ),
          _buildInsightCard(
            'Frequency:',
            "You've made ${filteredExpenses.length} expense${filteredExpenses.length != 1 ? 's' : ''} in the selected period.",
            Colors.blue.shade100,
            Colors.blue.shade600,
          ),
          _buildInsightCard(
            'Diversity:',
            "You're tracking ${analytics.categoryTotals.length} different spending categories.",
            Colors.green.shade100,
            Colors.green.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String content,
    Color bgColor,
    Color borderColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              TextSpan(text: ' $content', style: const TextStyle(fontSize: 13)),
            ],
          ),
          style: const TextStyle(color: Color(0xFF475569)),
        ),
      ),
    );
  }
}
