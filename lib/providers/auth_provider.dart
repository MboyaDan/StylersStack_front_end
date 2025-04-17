import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _user;
  bool _isLoading = true;

  AuthProvider() {
    // Listen for authentication state changes
    _auth.authStateChanges().listen((User? user) {
      _setUser(user);
    });
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  String get userId {
    if (_user == null) throw Exception("User not logged in");
    return _user!.uid;
  }

  void _setUser(User? user) {
    _user = user != null ? UserModel(uid: user.uid, email: user.email ?? '') : null;
    _isLoading = false; // Set loading to false once we get the auth state
    notifyListeners();
  }

  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case "invalid-credential":
        return "Invalid email or password.";
      case "user-not-found":
        return "No account found with this email.";
      case "wrong-password":
        return "Incorrect password.";
      case "email-already-in-use":
        return "This email is already in use. Try logging in.";
      case "weak-password":
        return "Password should be at least 6 characters.";
      case "network-request-failed":
        return "Check your internet connection.";
      default:
        return "An unexpected error occurred. Please try again.";
    }
  }

  // Sign Up with Email & Password
  Future<String?> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setUser(credential.user);
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getFriendlyErrorMessage(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Sign In with Email & Password
  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setUser(credential.user);
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getFriendlyErrorMessage(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return "Google Sign-In canceled.";
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      _setUser(userCredential.user);
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getFriendlyErrorMessage(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Google Sign-In failed. Please try again.";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _auth.signOut();
    await _googleSignIn.signOut();

    _setUser(null);
  }
}
