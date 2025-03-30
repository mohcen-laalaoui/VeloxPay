import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true; 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorMessage = "No account found for this email.";
      } else if (e.code == 'wrong-password') {
        _errorMessage = "Incorrect password. Please try again.";
      } else if (e.code == 'invalid-email') {
        _errorMessage = "Invalid email format.";
      } else {
        _errorMessage = "Login failed. Please try again.";
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
