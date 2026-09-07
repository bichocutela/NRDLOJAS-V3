import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'product.dart';

class FirebaseProductService {
  FirebaseProductService({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  FirebaseFirestore? get _firestore {
    if (_override != null) return _override;
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? get _products =>
      _firestore?.collection('products');

  Future<List<Product>> fetchAllProducts() async {
    final products = _products;
    if (products == null) return const [];
    final snapshot = await products.get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.data()))
        .where((product) => product.code.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> registerGlobalView(String productCode) async {
    final products = _products;
    final code = productCode.trim();
    if (products == null || code.isEmpty) return;

    await products.doc(code).update({
      'searchCount': FieldValue.increment(1),
      'lastViewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveProduct(Product product) async {
    final products = _products;
    if (products == null || product.code.trim().isEmpty) return;
    await products.doc(product.code).set(
      {
        ...product.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteProduct(String code) async {
    final products = _products;
    if (products == null || code.trim().isEmpty) return;
    await products.doc(code.trim()).delete();
  }
}
