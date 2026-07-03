import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/diary_entry.dart';
import '../diary_repository.dart';

/// Kho nhật ký lưu trên Firestore: users/{uid}/diary/{dayKey}.
/// Dùng dayKey làm id tài liệu để mỗi ngày chỉ có một mục (ghi đè).
class FirestoreDiaryRepository implements DiaryRepository {
  FirestoreDiaryRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col {
    final uid = _auth.currentUser?.uid ?? 'anonymous';
    return _db.collection('users').doc(uid).collection('diary');
  }

  @override
  Future<List<DiaryEntry>> fetchAll() async {
    final snap = await _col.orderBy('date', descending: true).get();
    return snap.docs.map((d) => DiaryEntry.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<DiaryEntry?> getByDay(DateTime day) async {
    final key = DiaryEntry(id: '', date: day, itemIds: const []).dayKey;
    final doc = await _col.doc(key).get();
    final data = doc.data();
    return data == null ? null : DiaryEntry.fromMap(doc.id, data);
  }

  @override
  Future<void> save(DiaryEntry entry) =>
      // Khóa theo id riêng -> cho phép nhiều bộ trong cùng một ngày.
      _col.doc(entry.id).set(entry.toMap());

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}
