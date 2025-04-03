import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:VeloxPay/data/models/send_model.dart';

class SendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getCurrentUserId() async {
    final User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<double> getUserBalance(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      return (userDoc.data() as Map<String, dynamic>)['balance'] ?? 0.0;
    } catch (e) {
      print('Error loading user balance: $e');
      return 0.0;
    }
  }

  Future<bool> checkRecipientExists(String type, String value) async {
    try {
      String fieldName = type.toLowerCase();
      QuerySnapshot query =
          await _firestore
              .collection('users')
              .where(fieldName, isEqualTo: value)
              .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking recipient: $e');
      return false;
    }
  }

  Future<String?> getRecipientId(String type, String value) async {
    try {
      String fieldName = type.toLowerCase();
      QuerySnapshot query =
          await _firestore
              .collection('users')
              .where(fieldName, isEqualTo: value)
              .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error getting recipient ID: $e');
      return null;
    }
  }

  Future<bool> processTransaction(
    SendTransactionModel transaction,
    String senderId,
  ) async {
    try {
      WriteBatch batch = _firestore.batch();

      double amount = transaction.amount;
      String recipientId = transaction.recipientId;

      DocumentReference senderRef = _firestore
          .collection('users')
          .doc(senderId);
      batch.update(senderRef, {'balance': FieldValue.increment(-amount)});

      DocumentReference recipientRef = _firestore
          .collection('users')
          .doc(recipientId);
      batch.update(recipientRef, {'balance': FieldValue.increment(amount)});

      DocumentReference transactionRef =
          _firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'sender': senderId,
        'recipient': recipientId,
        'amount': amount,
        'method': transaction.paymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
        'type': 'transfer',
      });

      DocumentReference senderHistoryRef =
          _firestore
              .collection('users')
              .doc(senderId)
              .collection('transaction_history')
              .doc();
      batch.set(senderHistoryRef, {
        'transactionId': transactionRef.id,
        'partnerId': recipientId,
        'partnerInfo': transaction.recipientInfo,
        'amount': -amount,
        'method': transaction.paymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'sent',
      });

      DocumentReference recipientHistoryRef =
          _firestore
              .collection('users')
              .doc(recipientId)
              .collection('transaction_history')
              .doc();
      batch.set(recipientHistoryRef, {
        'transactionId': transactionRef.id,
        'partnerId': senderId,
        'partnerInfo': 'User',
        'amount': amount,
        'method': transaction.paymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'received',
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Transaction failed: $e');
      return false;
    }
  }

  List<QuickContactModel> getRecentContacts() {
    return [
      QuickContactModel(
        name: 'Moncef Laalaoui',
        avatar: 'ML',
        color: '#BBDEFB',
      ),
      QuickContactModel(name: 'Dhia Amani', avatar: 'DA', color: '#C8E6C9'),
      QuickContactModel(name: 'Chaker Ketfi', avatar: 'CH', color: '#FFE0B2'),
      QuickContactModel(name: 'Bachir Bioud', avatar: 'BB', color: '#E1BEE7'),
    ];
  }
}
