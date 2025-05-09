import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign In with Email & Password
  Future<String> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "Something went wrong";
    }
  }

  // Sign Up with Email & Password
  Future<String> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "Something went wrong";
    }
  }

  // Sign Out (Optional)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
