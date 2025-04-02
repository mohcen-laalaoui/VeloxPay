import 'dart:async';
import 'package:VeloxPay/data/models/transaction_model.dart';

class TransactionService {
  final String currentUserID = 'current-user-123';

  final List<Transaction> _transactions = [];

  String _generateTransactionID() {
    return 'txn-${DateTime.now().millisecondsSinceEpoch}-${_transactions.length}';
  }

  Future<Map<String, dynamic>> processTransaction({
    required String recipientIdentifier,
    required String recipientType,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      if (amount <= 0) {
        return {
          'success': false,
          'message': 'Invalid amount. Amount must be greater than zero.',
        };
      }

      if (recipientIdentifier.isEmpty) {
        return {
          'success': false,
          'message': 'Recipient information is required.',
        };
      }

      // In a real app, you would:
      // 1. Check if user has sufficient balance
      // 2. Verify recipient exists
      // 3. Process payment through payment gateway
      // 4. Update account balances
      // 5. Store transaction in database

      await Future.delayed(const Duration(seconds: 1));

      final transaction = Transaction(
        id: _generateTransactionID(),
        senderID: currentUserID,
        recipientIdentifier: recipientIdentifier,
        recipientType: recipientType,
        amount: amount,
        paymentMethod: paymentMethod,
        timestamp: DateTime.now(),
        status: 'Completed',
        notes: notes,
      );

      _transactions.add(transaction);

      return {
        'success': true,
        'message': 'Transaction completed successfully!',
        'transaction': transaction,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to process transaction: ${e.toString()}',
      };
    }
  }

  List<Transaction> getTransactionHistory() {
    return _transactions.where((t) => t.senderID == currentUserID).toList();
  }

  Transaction? getTransactionById(String transactionId) {
    try {
      return _transactions.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      return null;
    }
  }
}
