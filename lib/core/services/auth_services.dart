import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:VeloxPay/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signUp(
    String email,
    String password,
    UserModel user,
  ) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'fullName': user.fullName,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'useBiometric': user.useBiometric,
      'linkBankAccount': user.linkBankAccount,
      'accountNumber': user.accountNumber,
      'routingNumber': user.routingNumber,
    });

    return userCredential;
  }

  Future<void> createUserBalance(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'balance': 10.0, 
    });
  }
}

