import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

import '../models/expense.dart';
// FIX: Use 'as' prefix to resolve the name conflict for Category
import '../models/category.dart' as app_models;

/// ===================
/// Analytics Model
/// ===================
class Analytics {
  final List<Expense> expenses;
  // FIX: Use the prefixed type for allCategories
  final List<app_models.Category> allCategories;

  Analytics(this.expenses, this.allCategories);

  double get total =>
      expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  List<Map<String, dynamic>> get categoryTotals {
    final Map<String, double> totalsMap = {};

    for (var expense in expenses) {
      totalsMap[expense.category] =
          (totalsMap[expense.category] ?? 0.0) + expense.amount;
    }

    return allCategories
        .map((category) {
          final total = totalsMap[category.id] ?? 0.0;
          return <String, dynamic>{
            'category': category,
            'total': total,
            'percentage': total > 0 && this.total > 0
                ? (total / this.total) * 100
                : 0.0,
          };
        })
        .where((item) => (item['total'] as double) > 0.0)
        .toList();
  }

  Map<String, double> get dailySpending {
    final Map<String, double> acc = {};
    for (var expense in expenses) {
      acc[expense.date] = (acc[expense.date] ?? 0.0) + expense.amount;
    }
    return acc;
  }

  double get monthlyAverage {
    final days = dailySpending.keys.length;
    return days > 0 ? total / days : 0.0;
  }

  double get highestExpense =>
      expenses.isNotEmpty ? expenses.map((e) => e.amount).reduce(max) : 0.0;

  double get lowestExpense =>
      expenses.isNotEmpty ? expenses.map((e) => e.amount).reduce(min) : 0.0;

  app_models.Category? get mostUsedCategory {
    if (categoryTotals.isEmpty) return null;
    // FIX: Updated return type to prefixed model
    return categoryTotals.reduce((
          Map<String, dynamic> a,
          Map<String, dynamic> b,
        ) {
          return (a['total'] as double) > (b['total'] as double) ? a : b;
        })['category']
        as app_models.Category; // FIX: Cast result to prefixed model
  }
}

/// ===================
/// Expense Notifier
/// ===================
class ExpenseNotifier with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  // --- Filters ---
  String _filterCategory = 'all';
  String _searchTerm = '';
  String _dateRange = 'all';

  // --- UI State ---
  String _viewMode = 'list';

  // --- Getters ---
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String get filterCategory => _filterCategory;
  String get searchTerm => _searchTerm;
  String get dateRange => _dateRange;
  String get viewMode => _viewMode;

  // --- Constructor ---
  ExpenseNotifier() {
    _loadExpenses();
  }

  // ===================
  // Persistence Methods
  // ===================

  Future<void> _loadExpenses() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final prefs = await SharedPreferences.getInstance();
    final String? expensesString = prefs.getString('expenseTracker_expenses');

    if (expensesString != null && expensesString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(expensesString);
        _expenses = jsonList
            .map((e) => Expense.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ Error loading expenses: $e');
        _expenses = [];
      }
    } else {
      _expenses = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveExpenses() async {
    if (_isLoading) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _expenses
          .map((e) => e.toJson())
          .toList();
      await prefs.setString('expenseTracker_expenses', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('⚠️ Error saving expenses: $e');
    }
  }

  // ===================
  // Filtering & Analytics
  // ===================

  List<Expense> get filteredExpenses {
    final now = DateTime.now();

    return _expenses.where((expense) {
      // Category filter
      final matchesCategory =
          _filterCategory == 'all' || expense.category == _filterCategory;

      // Search filter
      final matchesSearch = expense.description.toLowerCase().contains(
        _searchTerm.toLowerCase(),
      );

      // Date filter
      final expenseDate = DateTime.tryParse(expense.date);
      if (expenseDate == null) return false;

      bool matchesDate = true;
      if (_dateRange == 'today') {
        matchesDate =
            expenseDate.year == now.year &&
            expenseDate.month == now.month &&
            expenseDate.day == now.day;
      } else if (_dateRange == 'week') {
        final weekAgo = now.subtract(const Duration(days: 7));
        matchesDate = expenseDate.isAfter(weekAgo);
      } else if (_dateRange == 'month') {
        final monthAgo = now.subtract(const Duration(days: 30));
        matchesDate = expenseDate.isAfter(monthAgo);
      }

      return matchesCategory && matchesSearch && matchesDate;
    }).toList();
  }

  // FIX: Pass the prefixed categories constant to Analytics
  Analytics get analytics => Analytics(filteredExpenses, app_models.categories);

  // ===================
  // Mutator Methods
  // ===================

  void setViewMode(String mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  void setSearchTerm(String term) {
    if (_searchTerm == term) return;
    _searchTerm = term;
    notifyListeners();
  }

  void setFilterCategory(String category) {
    if (_filterCategory == category) return;
    _filterCategory = category;
    notifyListeners();
  }

  void setDateRange(String range) {
    if (_dateRange == range) return;
    _dateRange = range;
    notifyListeners();
  }

  void addOrUpdateExpense(Expense expense) {
    final existingIndex = _expenses.indexWhere((e) => e.id == expense.id);
    if (existingIndex != -1) {
      _expenses[existingIndex] = expense;
    } else {
      _expenses.insert(0, expense);
    }
    _saveExpenses();
    notifyListeners();
  }

  void deleteExpense(int id) {
    _expenses.removeWhere((e) => e.id == id);
    _saveExpenses();
    notifyListeners();
  }
}
