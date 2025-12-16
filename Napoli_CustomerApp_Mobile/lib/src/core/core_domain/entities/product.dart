class Product {
  final String id;
  final String name;
  final String category;
  final int price;
  final String image;
  final String description;
  final List<ProductExtra> availableExtras;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    this.description = '',
    this.availableExtras = const [],
  });
}

class ProductExtra {
  final String id;
  final String name;
  final int price;

  const ProductExtra({
    required this.id,
    required this.name,
    required this.price,
  });
}
