import 'package:material_ui/material_ui.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.emoji,
    required this.color,
    this.tag,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final int price;
  final String emoji;
  final Color color;
  final String? tag;
}
