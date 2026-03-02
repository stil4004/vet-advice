class Product {
  final int id;
  final String name;
  final String description;
  final String imagePath;
  final String animalType; // 'cat', 'dog', 'both'
  final int? minAge;
  final int? maxAge;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.animalType,
    this.minAge,
    this.maxAge,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      imagePath: json['image_path'] as String? ?? '',
      animalType: json['animal_type'] as String,
      minAge: json['min_age'] as int?,
      maxAge: json['max_age'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image_path': imagePath,
    'animal_type': animalType,
    'min_age': minAge,
    'max_age': maxAge,
  };

  bool get isForCats => animalType == 'cat' || animalType == 'both';
  bool get isForDogs => animalType == 'dog' || animalType == 'both';

  @override
  String toString() => 'Product(id: $id, name: $name)';
}