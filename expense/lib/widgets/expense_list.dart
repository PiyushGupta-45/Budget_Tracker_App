import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../models/category.dart';
import '../services/expense_notifier.dart';

// --- Add/Edit Expense Modal (Code unchanged from previous fix) ---
class AddEditExpenseModal extends StatefulWidget {
  final List<Category> categories;
  final Expense? expenseToEdit;

  const AddEditExpenseModal({
    required this.categories,
    this.expenseToEdit,
    super.key,
  });

  @override
  State<AddEditExpenseModal> createState() => _AddEditExpenseModalState();
}

class _AddEditExpenseModalState extends State<AddEditExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  late String _amount;
  late String _category;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final expense = widget.expenseToEdit;
    _description = expense?.description ?? '';
    _amount = expense?.amount.toString() ?? '';
    _category = expense?.category ?? widget.categories.first.id;
    _selectedDate = DateTime.tryParse(expense?.date ?? '') ?? DateTime.now();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (double.tryParse(_amount) == null || double.parse(_amount) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid positive amount.'),
          ),
        );
        return;
      }

      final newExpense = Expense(
        id: widget.expenseToEdit?.id ?? DateTime.now().millisecondsSinceEpoch,
        description: _description,
        amount: double.parse(_amount),
        category: _category,
        date: formatFullDate(_selectedDate.toIso8601String()),
        createdAt:
            widget.expenseToEdit?.createdAt ?? DateTime.now().toIso8601String(),
      );

      Provider.of<ExpenseNotifier>(
        context,
        listen: false,
      ).addOrUpdateExpense(newExpense);
      Navigator.of(context).pop();
    }
  }

  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24.0 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.expenseToEdit != null ? 'Edit Expense' : 'Add New Expense',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Description Field
                  TextFormField(
                    initialValue: _description,
                    decoration: _inputDecoration(
                      'Description',
                      'Enter expense description',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter a description.'
                        : null,
                    onSaved: (value) => _description = value!,
                  ),
                  const SizedBox(height: 16),
                  // Amount Field
                  TextFormField(
                    initialValue: _amount,
                    decoration: _inputDecoration('Amount', '0.00'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Please enter a valid amount.';
                      }
                      return null;
                    },
                    onSaved: (value) => _amount = value!,
                  ),
                  const SizedBox(height: 16),
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: _inputDecoration('Category', ''),
                    items: widget.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text('${category.icon} ${category.name}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Date Picker
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Date: ${formatDate(_selectedDate.toIso8601String())}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 20),
                        label: const Text('Select Date'),
                        onPressed: _presentDatePicker,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      widget.expenseToEdit != null
                          ? 'Update Expense'
                          : 'Add Expense',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF475569), fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }
}

// --- Expense List View ---
class ExpenseListView extends StatelessWidget {
  const ExpenseListView({super.key});

  // Helper method to show modal (uses context.read for notifier)
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
          categories: categories,
          expenseToEdit: expense,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = context.select(
      (ExpenseNotifier n) => n.filteredExpenses,
    );
    final notifier = context.read<ExpenseNotifier>();

    return Container(
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Expenses',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '${filteredExpenses.length} expenses',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 20),
          if (filteredExpenses.isEmpty)
            _buildEmptyState(context, () => _showAddEditForm(context, null))
          else
            // REVERT: Bring back ConstrainedBox to give the list a fixed height for visual separation
            ConstrainedBox(
              // Set a reasonable height (e.g., 600) to show many items before main screen scroll takes over
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                // FIX: Give the list its own scroll physics to make it scrollable within its 600px container
                physics: const BouncingScrollPhysics(),
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  final expense = filteredExpenses[index];
                  final category = getCategoryInfo(expense.category);
                  return ExpenseListItem(
                    expense: expense,
                    category: category,
                    onEdit: (exp) => _showAddEditForm(context, exp),
                    onDelete: notifier.deleteExpense,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Function onAdd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          const Text('💸', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          const Text(
            'No expenses found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          const Text(
            'Add your first expense to get started with tracking your finances!',
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => onAdd(),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue.shade500,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Add Your First Expense'),
          ),
        ],
      ),
    );
  }
}

// --- Expense List Item ---
class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final Category category;
  final Function(Expense) onEdit;
  final Function(int) onDelete;

  const ExpenseListItem({
    required this.expense,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: category.color.withOpacity(0.2),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(category.icon, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${category.name} • ${formatDate(expense.date)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Amount and Actions
            Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: () => onEdit(expense),
              tooltip: 'Edit expense',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => onDelete(expense.id),
              tooltip: 'Delete expense',
            ),
          ],
        ),
      ),
    );
  }
}
