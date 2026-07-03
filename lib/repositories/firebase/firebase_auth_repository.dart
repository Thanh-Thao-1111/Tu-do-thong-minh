import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../auth_repository.dart';

/// Cài đặt xác thực bằng Firebase Auth (email + mật khẩu).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final fb.FirebaseAuth _auth;

  AppUser? _map(fb.User? u) => u == null
      ? null
      : AppUser(uid: u.uid, email: u.email, displayName: u.displayName);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() => _auth.authStateChanges().map(_map);

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    return _map(cred.user)!;
  }

  @override
  Future<AppUser> signUpWithEmail(String email, String password,
      {String? displayName}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    if (displayName != null && displayName.trim().isNotEmpty) {
      await cred.user!.updateDisplayName(displayName.trim());
      await cred.user!.reload();
    }
    return _map(_auth.currentUser)!;
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> signOut() => _auth.signOut();
}
