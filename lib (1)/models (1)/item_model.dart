// Removed unused import

class ItemModel {
  final String itemId;
  final String bookingId;
  final String name;
  final String category;
  final double weight;
  final String? description;
  final String? image;

  ItemModel({
    required this.itemId,
    required this.bookingId,
    required this.name,
    required this.category,
    required this.weight,
    this.description,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'bookingId': bookingId,
      'name': name,
      'category': category,
      'weight': weight,
      'description': description,
      'image': image,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      itemId: map['itemId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      weight: (map['weight'] as num).toDouble(),
      description: map['description'],
      image: map['image'],
    );
  }
}
