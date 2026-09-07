import 'product.dart';

class ProductRepository {
  ProductRepository([List<Product> initialProducts = const []]) : _products = [...initialProducts];

  final List<Product> _products;

  List<Product> get allProducts => List.unmodifiable(_products);
  List<Product> get favorites => _products.where((p) => p.isFavorite).toList(growable: false);

  List<Product> mostUsed({int limit = 12}) {
    final items = [..._products]..sort((a, b) {
      final count = b.searchCount.compareTo(a.searchCount);
      if (count != 0) return count;
      return b.lastSearchedAt.compareTo(a.lastSearchedAt);
    });
    return items.take(limit).toList(growable: false);
  }

  List<Product> get history {
    final items = _products.where((p) => p.lastSearchedAt > 0).toList()
      ..sort((a, b) => b.lastSearchedAt.compareTo(a.lastSearchedAt));
    return items;
  }

  List<Product> latestAdded({int limit = 10}) {
    final items = [..._products]..sort((a, b) => b.id.compareTo(a.id));
    return items.take(limit).toList(growable: false);
  }

  List<Product> byCategory(String category) =>
      _products.where((p) => p.category == category).toList(growable: false);

  List<Product> search(String query) => rankProductsByRelevance(_products, query);

  Product? byCode(String code) {
    for (final product in _products) {
      if (product.code == code) return product;
    }
    return null;
  }

  void replaceAll(List<Product> remoteProducts) {
    final localByCode = {for (final product in _products) product.code: product};
    _products
      ..clear()
      ..addAll(remoteProducts.map((remote) {
        final local = localByCode[remote.code];
        if (local == null) return remote;
        return remote.copyWith(
          id: local.id,
          isFavorite: local.isFavorite,
          searchCount: local.searchCount,
          lastSearchedAt: local.lastSearchedAt,
        );
      }));
  }

  void toggleFavorite(String code) {
    final index = _products.indexWhere((p) => p.code == code);
    if (index < 0) return;
    final product = _products[index];
    _products[index] = product.copyWith(isFavorite: !product.isFavorite);
  }

  void registerSearch(String code, {int? timestamp}) {
    final index = _products.indexWhere((p) => p.code == code);
    if (index < 0) return;
    final product = _products[index];
    _products[index] = product.copyWith(
      searchCount: product.searchCount + 1,
      lastSearchedAt: timestamp ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class _SearchMatch {
  const _SearchMatch(this.product, this.relevance, this.normalizedName, this.normalizedCode);
  final Product product;
  final int relevance;
  final String normalizedName;
  final String normalizedCode;
}

List<Product> rankProductsByRelevance(List<Product> products, String query) {
  final normalizedQuery = _normalize(query).trim();
  if (normalizedQuery.isEmpty) return const [];

  if (normalizedQuery.contains('#')) {
    final terms = normalizedQuery
        .split('#')
        .map((term) => term.trim())
        .where((term) => term.isNotEmpty)
        .toSet()
        .toList();
    if (terms.isEmpty) return const [];
    return _rankByIntensiveTerms(products, terms);
  }

  final tokens = normalizedQuery.split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList();
  final matches = <_SearchMatch>[];

  for (final product in products) {
    final normalizedName = _normalize(product.name).trim();
    final normalizedCode = product.code.trim().toLowerCase();
    final nameWords = normalizedName.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();

    int? relevance;
    if (normalizedCode == normalizedQuery) {
      relevance = 0;
    } else if (normalizedCode.startsWith(normalizedQuery)) {
      relevance = 1;
    } else if (normalizedCode.contains(normalizedQuery)) {
      relevance = 2;
    } else if (normalizedName == normalizedQuery) {
      relevance = 3;
    } else if (normalizedName.startsWith(normalizedQuery)) {
      relevance = 4;
    } else if (nameWords.any((word) => word.startsWith(normalizedQuery))) {
      relevance = 5;
    } else if (normalizedName.contains(normalizedQuery)) {
      relevance = 6;
    } else if (tokens.every(normalizedName.contains)) {
      relevance = 7;
    }

    if (relevance != null) {
      matches.add(_SearchMatch(product, relevance, normalizedName, normalizedCode));
    }
  }

  return _sort(matches);
}

List<Product> _rankByIntensiveTerms(List<Product> products, List<String> terms) {
  final matches = <_SearchMatch>[];
  for (final product in products) {
    final normalizedName = _normalize(product.name).trim();
    final normalizedCode = product.code.trim().toLowerCase();
    final matchesEveryParameter = terms.every((term) {
      final tokens = term.split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList();
      return tokens.isNotEmpty && tokens.every((token) => normalizedName.contains(token) || normalizedCode.contains(token));
    });
    if (matchesEveryParameter) {
      matches.add(_SearchMatch(product, 0, normalizedName, normalizedCode));
    }
  }
  return _sort(matches);
}

List<Product> _sort(List<_SearchMatch> matches) {
  matches.sort((a, b) {
    var result = a.relevance.compareTo(b.relevance);
    if (result != 0) return result;
    result = a.normalizedName.compareTo(b.normalizedName);
    if (result != 0) return result;
    result = a.product.name.compareTo(b.product.name);
    if (result != 0) return result;
    result = a.normalizedCode.compareTo(b.normalizedCode);
    if (result != 0) return result;
    return b.product.searchCount.compareTo(a.product.searchCount);
  });
  return matches.map((match) => match.product).toList(growable: false);
}

String _normalize(String value) {
  const accents = {
    'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c',
  };
  final lower = value.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(accents[char] ?? char);
  }
  return buffer.toString();
}
