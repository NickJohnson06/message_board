import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final appUser = AppUser(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      role: role,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(uid).set({
      ...appUser.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
