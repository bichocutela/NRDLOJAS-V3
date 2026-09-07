import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalProductState {
  static const _favoritesKey = 'nrd.favorite_codes';
  static const _historyKey = 'nrd.history';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<Set<String>> favoriteCodes() async {
    final values = await _prefs.getStringList(_favoritesKey) ?? const <String>[];
    return values.toSet();
  }

  Future<bool> toggleFavorite(String code) async {
    final normalized = code.trim();
    if (normalized.isEmpty) return false;

    final favorites = await favoriteCodes();
    final isFavorite;
    if (favorites.contains(normalized)) {
      favorites.remove(normalized);
      isFavorite = false;
    } else {
      favorites.add(normalized);
      isFavorite = true;
    }
    final sorted = favorites.toList()..sort();
    await _prefs.setStringList(_favoritesKey, sorted);
    return isFavorite;
  }

  Future<List<ProductHistoryEntry>> history() async {
    final raw = await _prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => ProductHistoryEntry.fromMap(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> registerView(String code) async {
    final normalized = code.trim();
    if (normalized.isEmpty) return;

    final current = (await history()).where((item) => item.code != normalized).toList();
    current.insert(
      0,
      ProductHistoryEntry(code: normalized, viewedAt: DateTime.now().millisecondsSinceEpoch),
    );
    if (current.length > 10) current.removeRange(10, current.length);
    await _prefs.setString(
      _historyKey,
      jsonEncode(current.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> clearHistory() => _prefs.remove(_historyKey);
}

class ProductHistoryEntry {
  const ProductHistoryEntry({required this.code, required this.viewedAt});

  final String code;
  final int viewedAt;

  Map<String, dynamic> toMap() => {'code': code, 'viewedAt': viewedAt};

  factory ProductHistoryEntry.fromMap(Map<String, dynamic> map) {
    return ProductHistoryEntry(
      code: map['code']?.toString() ?? '',
      viewedAt: (map['viewedAt'] as num?)?.toInt() ?? 0,
    );
  }
}
