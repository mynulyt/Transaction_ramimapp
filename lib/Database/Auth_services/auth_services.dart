import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to start the phone number verification
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String) codeSent,
    required Function(String, int?) verificationCompleted,
    required Function(FirebaseAuthException) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          if (userCredential.user != null) {
            verificationCompleted(userCredential.user!.uid, null);
          }
        } catch (e) {
          // Handle unexpected error during verification completion
          onError(FirebaseAuthException(
              message: "Verification failed.", code: "ERROR_UNKNOWN"));
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure (wrong phone number format, etc.)
        onError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        // Once the code is sent, trigger the callback with the verification ID
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle auto retrieval timeout
        // Optionally, you can trigger the user to re-enter the OTP
        print("Auto retrieval timeout reached.");
      },
    );
  }

  // Function to sign in with OTP
  Future<UserCredential> signInWithOtp(
      String verificationId, String otp) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow; // Optionally catch and handle any errors here
    }
  }

  // Function to sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if the user is already logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}
