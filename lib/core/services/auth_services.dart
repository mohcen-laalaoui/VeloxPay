import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:VeloxPay/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp(String email, String password, UserModel user) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception("User creation failed");

      await firebaseUser.updateDisplayName(user.fullName);

      Map<String, dynamic> userData = user.toJson();
      userData['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(firebaseUser.uid).set(userData);

      return firebaseUser;
    } catch (e) {
      rethrow;
    }
  }
}
