class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int displayOrder;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.displayOrder = 0,
    this.isActive = true,
  });
}
