import 'package:cloud_firestore/cloud_firestore.dart';

import 'product.dart';

class FirebaseProductService {
  FirebaseProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  Future<List<Product>> fetchAllProducts() async {
    final snapshot = await _products.get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.data()))
        .where((product) => product.code.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> registerGlobalView(String productCode) async {
    final code = productCode.trim();
    if (code.isEmpty) return;

    await _products.doc(code).update({
      'searchCount': FieldValue.increment(1),
      'lastViewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveProduct(Product product) async {
    await _products.doc(product.code).set(
      {
        ...product.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteProduct(String code) async {
    if (code.trim().isEmpty) return;
    await _products.doc(code.trim()).delete();
  }
}
