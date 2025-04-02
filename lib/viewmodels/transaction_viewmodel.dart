import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:VeloxPay/core/services/transaction_service.dart';
import 'package:VeloxPay/data/models/transaction_model.dart';

enum TransactionState { initial, processing, success, error }

class TransactionViewModel extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  TransactionState _state = TransactionState.initial;
  Transaction? _transaction;
  String? _errorMessage;

  TransactionState get state => _state;
  Transaction? get transaction => _transaction;
  String? get errorMessage => _errorMessage;
  bool get isProcessing => _state == TransactionState.processing;
  bool get isSuccess => _state == TransactionState.success;
  bool get isError => _state == TransactionState.error;

  Future<void> processTransaction({
    required String recipientIdentifier,
    required String recipientType,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    _state = TransactionState.processing;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _transactionService.processTransaction(
        recipientIdentifier: recipientIdentifier,
        recipientType: recipientType,
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      if (result['success']) {
        _transaction = result['transaction'];
        _state = TransactionState.success;
      } else {
        _errorMessage = result['message'];
        _state = TransactionState.error;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _state = TransactionState.error;
    }

    notifyListeners();
  }

  void reset() {
    _state = TransactionState.initial;
    _transaction = null;
    _errorMessage = null;
    notifyListeners();
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
