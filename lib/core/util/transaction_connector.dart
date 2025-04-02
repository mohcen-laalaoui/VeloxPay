import 'package:flutter/material.dart';
import 'package:VeloxPay/UI/views/transaction.dart';
class TransactionConnector {
  static void initiateTransaction(
    BuildContext context, {
    required String recipientIdentifier,
    required String recipientType,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) {
    // Navigate to the transaction page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TransactionPage(
              recipientIdentifier: recipientIdentifier,
              recipientType: recipientType,
              amount: amount,
              paymentMethod: paymentMethod,
              notes: notes,
            ),
      ),
    );
  }
}
