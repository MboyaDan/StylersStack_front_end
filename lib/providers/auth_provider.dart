import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stylerstack/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserModel? _user;
  bool _isLoading = true;
  bool _isLoggedOut = false;

  bool _alreadyHandlingAuthChange = false;

  AuthProvider() {
    _loadCachedUser().then((_) {
      _auth.authStateChanges().listen((user) {
        if (_alreadyHandlingAuthChange) return;

        _alreadyHandlingAuthChange = true;
        _setUser(user).whenComplete(() {
          Future.delayed(const Duration(seconds: 1), () {
            _alreadyHandlingAuthChange = false;
          });
        });
      });
    });
  }

  // ─────────────────────────────── Getters
  UserModel? get user        => _user;
  bool get isLoading         => _isLoading;
  bool get isLoggedIn        => _user != null;
  bool get isLoggedOut       => _isLoggedOut;
  String get userId          => _user?.uid ?? (throw Exception("User not logged in"));

  // ─────────────────────────────── Cache helpers
  Future<void> _loadCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid   = prefs.getString('uid');
    final email = prefs.getString('email');
    if (uid != null && email != null) {
      _user        = UserModel(uid: uid, email: email);
      _isLoggedOut = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _cacheUser(UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString('uid',   user.uid);
      await prefs.setString('email', user.email);
    } else {
      await prefs.remove('uid');
      await prefs.remove('email');
    }
  }

  // ─────────────────────────────── Handle Firebase changes
  Future<void> _setUser(User? firebaseUser) async {
    print('[AUTH DEBUG] Firebase user set: ${firebaseUser?.uid}');

    if (firebaseUser != null) {
      _user = UserModel(uid: firebaseUser.uid, email: firebaseUser.email ?? '');
      await _cacheUser(_user);
      final token = await refreshToken();
      if (token != null) {
        await _storage.write(key: 'id_token', value: token);
      }
    } else {
      _user = null;
      await _cacheUser(null);
    }

    _isLoggedOut = _user == null;
    _isLoading   = false;
    notifyListeners();
  }

  // ─────────────────────────────── Token helpers
  Future<String?> getValidToken() async {
    String? token = await _storage.read(key: 'id_token');
    if (token == null || JwtDecoder.isExpired(token)) {
      token = await refreshToken();
      if (token != null) {
        await _storage.write(key: 'id_token', value: token);
      }
    }
    return token;
  }

  Future<String?> refreshToken() async =>
      _auth.currentUser?.getIdToken(true);

  // ─────────────────────────────── Auth flows
  String _friendlyMsg(String code) {
    switch (code) {
      case "invalid-credential":   return "Invalid email or password.";
      case "user-not-found":       return "No account found with this email.";
      case "wrong-password":       return "Incorrect password.";
      case "email-already-in-use": return "This email is already in use. Try logging in.";
      case "weak-password":        return "Password should be at least 6 characters.";
      case "network-request-failed": return "Check your internet connection.";
      default: return "An unexpected error occurred. Please try again.";
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      _isLoading = true; notifyListeners();
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _setUser(cred.user);
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false; notifyListeners();
      return _friendlyMsg(e.code);
    } catch (_) {
      _isLoading = false; notifyListeners();
      return "An unexpected error occurred. Please try again.";
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true; notifyListeners();
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _setUser(cred.user);
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false; notifyListeners();
      return _friendlyMsg(e.code);
    } catch (_) {
      _isLoading = false; notifyListeners();
      return "An unexpected error occurred. Please try again.";
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true; notifyListeners();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false; notifyListeners();
        return "Google Sign-In canceled.";
      }

      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:    googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(cred);
      await _setUser(userCred.user);
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false; notifyListeners();
      return _friendlyMsg(e.code);
    } catch (_) {
      _isLoading = false; notifyListeners();
      return "Google Sign-In failed. Please try again.";
    }
  }

  Future<void> signOut() async {
    _isLoading = true; notifyListeners();
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _storage.delete(key: 'id_token');
    await _cacheUser(null);
    // DO NOT call _setUser(null) here — Firebase will trigger it via the auth listener
  }
}
