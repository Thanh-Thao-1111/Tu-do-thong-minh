import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/wardrobe_item.dart';
import '../wardrobe_repository.dart';

/// Kho tủ đồ lưu trên Cloud Firestore: users/{uid}/items/{itemId}.
class FirestoreWardrobeRepository implements WardrobeRepository {
  FirestoreWardrobeRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col {
    final uid = _auth.currentUser?.uid ?? 'anonymous';
    return _db.collection('users').doc(uid).collection('items');
  }

  @override
  Future<List<WardrobeItem>> fetchAll() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => WardrobeItem.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<WardrobeItem?> getById(String id) async {
    final doc = await _col.doc(id).get();
    final data = doc.data();
    return data == null ? null : WardrobeItem.fromMap(doc.id, data);
  }

  @override
  Future<void> add(WardrobeItem item) => _col.doc(item.id).set(item.toMap());

  @override
  Future<void> update(WardrobeItem item) =>
      _col.doc(item.id).set(item.toMap());

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  @override
  Future<void> markWorn(String id, DateTime when) => _col.doc(id).update({
        'wearCount': FieldValue.increment(1),
        'lastWornAt': when.toIso8601String(),
      });
}
