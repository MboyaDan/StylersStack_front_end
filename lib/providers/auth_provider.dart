import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserModel? _user;
  bool _isLoading = true;
  bool _isLoggedOut = false;

  AuthProvider() {
    _auth.authStateChanges().listen(_setUser);
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedOut => _isLoggedOut;
  String get userId => _user?.uid ?? (throw Exception("User not logged in"));

  void _setUser(User? firebaseUser) async {
    if (firebaseUser != null) {
      _user = UserModel(uid: firebaseUser.uid, email: firebaseUser.email ?? '');
      final token = await refreshToken();
      if (token != null) {
        await _storage.write(key: 'id_token', value: token);
      }
    } else {
      _user = null;
    }

    _isLoggedOut = _user == null;
    _isLoading = false;
    notifyListeners();
  }

  /// Get valid token (cached or refreshed)
  Future<String?> getValidToken() async {
    String? token = await _storage.read(key: 'id_token');
    if (token == null || JwtDecoder.isExpired(token)) {
      print('No token or expired. Refreshing token...');
      token = await refreshToken();
      if (token != null) {
        await _storage.write(key: 'id_token', value: token);
      }
    }
    return token;
  }

  /// Force refresh token from Firebase
  Future<String?> refreshToken() async {
    final firebaseUser = _auth.currentUser;
    return await firebaseUser?.getIdToken(true);
  }

  /// Friendly error messages
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

  /// Sign up with email & password
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

  /// Sign in with email & password
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

  /// Google Sign-In
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

  /// Sign out and clear token
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _auth.signOut();
    await _googleSignIn.signOut();
    await _storage.delete(key: 'id_token');

    _setUser(null);
  }
}
