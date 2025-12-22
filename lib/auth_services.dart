import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // SIGNUP
  static Future<String?> signup({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // ✅ SUCCESS
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email already exists';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      } else {
        return e.message;
      }
    } catch (e) {
      return 'Something went wrong';
    }
  }

  // LOGIN
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password';
      } else {
        return e.message;
      }
    } catch (e) {
      return 'Something went wrong';
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}

