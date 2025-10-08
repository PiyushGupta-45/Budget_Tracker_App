import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final String icon; // Emoji icon

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
}

final List<Category> categories = [
  Category(
    id: 'food',
    name: 'Food & Dining',
    color: const Color(0xFFFF6B6B),
    icon: '🍕',
  ),
  Category(
    id: 'transport',
    name: 'Transportation',
    color: const Color(0xFF4ECDC4),
    icon: '🚗',
  ),
  Category(
    id: 'entertainment',
    name: 'Entertainment',
    color: const Color(0xFF45B7D1),
    icon: '🎬',
  ),
  Category(
    id: 'shopping',
    name: 'Shopping',
    color: const Color(0xFF96CEB4),
    icon: '🛍️',
  ),
  Category(
    id: 'bills',
    name: 'Bills & Utilities',
    color: const Color(0xFFFFEAA7),
    icon: '💡',
  ),
  Category(
    id: 'health',
    name: 'Healthcare',
    color: const Color(0xFFDDA0DD),
    icon: '🏥',
  ),
  Category(
    id: 'education',
    name: 'Education',
    color: const Color(0xFF98D8C8),
    icon: '📚',
  ),
  Category(
    id: 'other',
    name: 'Other',
    color: const Color(0xFFF7DC6F),
    icon: '📦',
  ),
];

Category getCategoryInfo(String categoryId) {
  return categories.firstWhere(
    (cat) => cat.id == categoryId,
    orElse: () => categories.last,
  );
}
