class Expense {
  final int id;
  final String description;
  final double amount;
  final String category;
  final String date; // YYYY-MM-DD format
  final String createdAt;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  // Convert an Expense object to a JSON map
  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'amount': amount,
    'category': category,
    'date': date,
    'createdAt': createdAt,
  };

  // Create an Expense object from a JSON map
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      description: json['description'] as String,
      // Ensure conversion to double
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'] as double,
      category: json['category'] as String,
      date: json['date'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}

// Helper functions (kept here as they are tightly coupled to the Expense data)

String formatDate(String dateString) {
  final date = DateTime.tryParse(dateString) ?? DateTime.now();
  return '${date.day}/${date.month}/${date.year}';
}

String formatFullDate(String dateString) {
  final date = DateTime.tryParse(dateString) ?? DateTime.now();
  return date.toLocal().toString().split(' ')[0]; // Basic format YYYY-MM-DD
}
