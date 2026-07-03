import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/outfit.dart';
import '../outfit_repository.dart';

/// Kho outfit lưu trên Cloud Firestore: users/{uid}/outfits/{outfitId}.
///
/// Mỗi document lưu: itemIds, occasion, score, scoreBreakdown, createdAt.
/// Dữ liệu WardrobeItem đầy đủ không lưu lại (tránh dư thừa) — chỉ lưu id
/// để join khi cần hiển thị chi tiết.
class FirestoreOutfitRepository implements OutfitRepository {
  FirestoreOutfitRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col {
    final uid = _auth.currentUser?.uid ?? 'anonymous';
    return _db.collection('users').doc(uid).collection('outfits');
  }

  @override
  Future<List<Outfit>> fetchAll() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((d) => Outfit.fromMap(d.id, d.data()))
        .toList();
  }

  @override
  Future<void> save(Outfit outfit) =>
      _col.doc(outfit.id).set(outfit.toMap());

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}
