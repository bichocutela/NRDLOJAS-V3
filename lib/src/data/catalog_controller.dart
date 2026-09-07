import 'package:flutter/foundation.dart';

import 'firebase_product_service.dart';
import 'local_product_state.dart';
import 'product.dart';
import 'product_repository.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({
    FirebaseProductService? remote,
    LocalProductState? local,
  })  : _remote = remote ?? FirebaseProductService(),
        _local = local ?? LocalProductState();

  final FirebaseProductService _remote;
  final LocalProductState _local;

  List<Product> _all = const [];
  List<Product> _favorites = const [];
  List<Product> _history = const [];
  bool _loading = false;
  String? _error;

  List<Product> get all => _all;
  List<Product> get favorites => _favorites;
  List<Product> get history => _history;
  List<Product> get latestAdded => [..._all]..sort((a, b) => b.id.compareTo(a.id));
  List<Product> get mostUsed {
    final list = [..._all]..sort((a, b) {
      final byCount = b.searchCount.compareTo(a.searchCount);
      if (byCount != 0) return byCount;
      return a.name.compareTo(b.name);
    });
    return list.where((p) => p.searchCount > 0).take(10).toList(growable: false);
  }

  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _all = await _remote.fetchAllProducts();
      await _refreshLocalViews();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<Product> search(String query) => rankProductsByRelevance(_all, query);

  Future<void> registerView(Product product) async {
    final index = _all.indexWhere((p) => p.code == product.code);
    if (index >= 0) {
      final current = _all[index];
      _all = [..._all];
      _all[index] = current.copyWith(
        searchCount: current.searchCount + 1,
        lastSearchedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }
    await _local.registerView(product.code);
    await _refreshLocalViews();
    notifyListeners();
    try {
      await _remote.registerGlobalView(product.code);
    } catch (_) {
      // A consulta local continua válida mesmo quando o contador remoto falha.
    }
  }

  Future<void> toggleFavorite(Product product) async {
    await _local.toggleFavorite(product.code);
    await _refreshLocalViews();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _local.clearHistory();
    _history = const [];
    notifyListeners();
  }

  Future<void> _refreshLocalViews() async {
    final favorites = await _local.favoriteCodes();
    final historyEntries = await _local.history();
    final byCode = {for (final product in _all) product.code: product};

    _favorites = _all
        .where((product) => favorites.contains(product.code))
        .map((product) => product.copyWith(isFavorite: true))
        .toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));

    _history = historyEntries
        .map((entry) => byCode[entry.code])
        .whereType<Product>()
        .toList(growable: false);
  }
}
