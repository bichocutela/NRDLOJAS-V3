class Product {
  const Product({
    this.id = 0,
    required this.code,
    required this.name,
    required this.searchName,
    required this.category,
    this.isFavorite = false,
    this.searchCount = 0,
    this.lastSearchedAt = 0,
    this.unit = 'un',
    this.imageUrl,
  });

  final int id;
  final String code;
  final String name;
  final String searchName;
  final String category;
  final bool isFavorite;
  final int searchCount;
  final int lastSearchedAt;
  final String unit;
  final String? imageUrl;

  Product copyWith({
    int? id,
    String? code,
    String? name,
    String? searchName,
    String? category,
    bool? isFavorite,
    int? searchCount,
    int? lastSearchedAt,
    String? unit,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      searchName: searchName ?? this.searchName,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      searchCount: searchCount ?? this.searchCount,
      lastSearchedAt: lastSearchedAt ?? this.lastSearchedAt,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num?)?.toInt() ?? 0,
      code: '${map['code'] ?? ''}',
      name: '${map['name'] ?? ''}',
      searchName: '${map['searchName'] ?? map['search_name'] ?? map['name'] ?? ''}',
      category: '${map['category'] ?? ''}',
      isFavorite: map['isFavorite'] == true || map['is_favorite'] == true,
      searchCount: (map['searchCount'] as num?)?.toInt() ??
          (map['search_count'] as num?)?.toInt() ??
          0,
      lastSearchedAt: (map['lastSearchedAt'] as num?)?.toInt() ??
          (map['last_searched_at'] as num?)?.toInt() ??
          0,
      unit: '${map['unit'] ?? 'un'}',
      imageUrl: map['imageUrl'] as String? ?? map['image_url'] as String?,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product.fromMap(json);

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'name': name,
        'searchName': searchName,
        'category': category,
        'isFavorite': isFavorite,
        'searchCount': searchCount,
        'lastSearchedAt': lastSearchedAt,
        'unit': unit,
        'imageUrl': imageUrl,
      };

  Map<String, dynamic> toJson() => toMap();
}
