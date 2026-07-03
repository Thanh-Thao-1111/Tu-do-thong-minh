import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_profile.dart';
import '../profile_repository.dart';

/// Hồ sơ cá nhân lưu trên Firestore tại tài liệu users/{uid}.
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> get _doc {
    final uid = _auth.currentUser?.uid ?? 'anonymous';
    return _db.collection('users').doc(uid);
  }

  @override
  Future<UserProfile> fetch() async {
    final uid = _auth.currentUser?.uid ?? 'me';
    final snap = await _doc.get();
    final data = snap.data();
    // Bỏ qua các trường con (items/diary là subcollection, không nằm ở đây).
    if (data == null || data['displayName'] == null) {
      final name = _auth.currentUser?.displayName;
      final initial = (name != null && name.trim().isNotEmpty)
          ? UserProfile.initial().copyWith(displayName: name.trim())
          : UserProfile.initial();
      await save(initial);
      return UserProfile.fromMap(uid, initial.toMap());
    }
    return UserProfile.fromMap(uid, data);
  }

  @override
  Future<void> save(UserProfile profile) =>
      _doc.set(profile.toMap(), SetOptions(merge: true));
}
