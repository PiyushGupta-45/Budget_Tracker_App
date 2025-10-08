import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/expense_notifier.dart';
import 'expense_list.dart'; // AddEditExpenseModal is imported from here

class ControlsSection extends StatefulWidget {
  const ControlsSection({super.key});

  @override
  State<ControlsSection> createState() => _ControlsSectionState();
}

class _ControlsSectionState extends State<ControlsSection> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final notifier = context.read<ExpenseNotifier>();
    _searchController = TextEditingController(text: notifier.searchTerm);
    _searchController.addListener(() {
      notifier.setSearchTerm(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditForm(BuildContext context, Expense? expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddEditExpenseModal(
          categories:
              categories, // Make sure this comes from a global or imported file
          expenseToEdit: expense,
        ),
      ),
    );
  }

  void _exportData(BuildContext context) {
    final expenses = context.read<ExpenseNotifier>().expenses;
    final dataStr = const JsonEncoder.withIndent(
      '  ',
    ).convert(expenses.map((e) => e.toJson()).toList());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data exported to console.')));

    debugPrint(dataStr);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<ExpenseNotifier>();

    final viewMode = context.select((ExpenseNotifier n) => n.viewMode);
    final filterCategory = context.select(
      (ExpenseNotifier n) => n.filterCategory,
    );
    final dateRange = context.select((ExpenseNotifier n) => n.dateRange);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Action Buttons ---
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddEditForm(context, null),
                icon: const Icon(Icons.add_circle, size: 20),
                label: const Text('Add Expense'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _exportData(context),
                icon: const Icon(Icons.download, size: 20),
                label: const Text('Export Data'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green.shade500,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewModeButton(context, Icons.list, 'list', viewMode),
                    _buildViewModeButton(
                      context,
                      Icons.pie_chart,
                      'chart',
                      viewMode,
                    ),
                    _buildViewModeButton(
                      context,
                      Icons.bar_chart,
                      'analytics',
                      viewMode,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 30),

          // --- Filters & Search ---
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.end,
            children: [
              // --- Search Field ---
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search expenses...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),

              // --- Category Filter ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: filterCategory,
                    onChanged: (String? newValue) {
                      if (newValue != null)
                        notifier.setFilterCategory(newValue);
                    },
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('All Categories'),
                      ),
                      ...categories.map((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              // --- Date Range Filter ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dateRange,
                    onChanged: (String? newValue) {
                      if (newValue != null) notifier.setDateRange(newValue);
                    },
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Time')),
                      DropdownMenuItem(value: 'today', child: Text('Today')),
                      DropdownMenuItem(value: 'week', child: Text('Last Week')),
                      DropdownMenuItem(
                        value: 'month',
                        child: Text('Last Month'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(
    BuildContext context,
    IconData icon,
    String mode,
    String viewMode,
  ) {
    final notifier = context.read<ExpenseNotifier>();
    return Material(
      color: viewMode == mode ? Colors.blue.shade500 : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => notifier.setViewMode(mode),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: viewMode == mode ? Colors.white : Colors.grey.shade600,
            size: 20,
          ),
        ),
      ),
    );
  }
}
