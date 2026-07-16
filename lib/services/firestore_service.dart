import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add or update a document
  static Future<void> setDocument({
    required String path, 
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    await _db.doc(path).set(data, SetOptions(merge: merge));
  }

  // Delete a document
  static Future<void> deleteDocument({required String path}) async {
    await _db.doc(path).delete();
  }

  // Stream a single document
  static Stream<Map<String, dynamic>?> streamDocument({required String path}) {
    return _db.doc(path).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  // Stream a collection
  static Stream<List<Map<String, dynamic>>> streamCollection({
    required String path,
    String? orderBy,
    bool descending = false,
  }) {
    Query query = _db.collection(path);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList()
    );
  }

  // Get a collection once
  static Future<List<Map<String, dynamic>>> getCollection({
    required String path,
    String? orderBy,
    bool descending = false,
  }) async {
    Query query = _db.collection(path);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Get a single document once
  static Future<Map<String, dynamic>?> getDocument({required String path}) async {
    final snapshot = await _db.doc(path).get();
    return snapshot.exists ? snapshot.data() : null;
  }
}
