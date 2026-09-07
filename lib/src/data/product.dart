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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: '${json['code'] ?? ''}',
      name: '${json['name'] ?? ''}',
      searchName: '${json['searchName'] ?? json['search_name'] ?? json['name'] ?? ''}',
      category: '${json['category'] ?? ''}',
      isFavorite: json['isFavorite'] == true || json['is_favorite'] == true,
      searchCount: (json['searchCount'] as num?)?.toInt() ?? (json['search_count'] as num?)?.toInt() ?? 0,
      lastSearchedAt: (json['lastSearchedAt'] as num?)?.toInt() ?? (json['last_searched_at'] as num?)?.toInt() ?? 0,
      unit: '${json['unit'] ?? 'un'}',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
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
}
