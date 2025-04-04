import 'dart:async';
import 'package:flutter/material.dart';
import 'package:VeloxPay/data/models/send_model.dart';
import 'package:VeloxPay/repositories/send_repository.dart';
import 'package:VeloxPay/core/services/anomaly_detection_service.dart';

class SendViewModel extends ChangeNotifier {
  final SendRepository _repository;
  final AnomalyDetectionService _anomalyService;

  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String selectedRecipientType = 'Phone';
  String selectedPaymentMethod = 'Bank Transfer';
  int currentStep = 1;
  bool isProcessing = false;

  String? currentUserId;
  double userBalance = 0.0;
  List<QuickContactModel> recentContacts = [];

  final List<String> recipientTypes = ['Phone', 'Email', 'ID'];
  final List<String> paymentMethods = [
    'Bank Transfer',
    'Mobile Wallet',
    'Card Payment',
  ];

  SendViewModel(this._repository, {AnomalyDetectionService? anomalyService})
    : _anomalyService = anomalyService ?? AnomalyDetectionService() {
    _init();
  }

  final _transactionResultController = StreamController<bool>.broadcast();
  Stream<bool> get transactionResult => _transactionResultController.stream;

  final _anomalyDetectedController =
      StreamController<AnomalyResult>.broadcast();
  Stream<AnomalyResult> get anomalyDetected =>
      _anomalyDetectedController.stream;

  Future<void> _init() async {
    await _loadCurrentUser();
    await _loadUserBalance();
    _loadRecentContacts();
  }

  Future<void> _loadCurrentUser() async {
    currentUserId = await _repository.getCurrentUserId();
    notifyListeners();
  }

  Future<void> _loadUserBalance() async {
    if (currentUserId != null) {
      userBalance = await _repository.getUserBalance(currentUserId!);
      notifyListeners();
    }
  }

  void _loadRecentContacts() {
    recentContacts = _repository.getRecentContacts();
    notifyListeners();
  }

  void nextStep() {
    currentStep++;
    notifyListeners();
  }

  void previousStep() {
    currentStep--;
    notifyListeners();
  }

  void updateRecipientType(String type) {
    selectedRecipientType = type;
    notifyListeners();
  }

  void updatePaymentMethod(String method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  void selectQuickContact(String name) {
    recipientController.text = name;
    notifyListeners();
  }

  Future<bool> validateTransaction() async {
    if (amountController.text.isEmpty) return false;

    double amount = double.parse(amountController.text);

    if (amount > userBalance) {
      return false;
    }

    bool recipientExists = await _repository.checkRecipientExists(
      selectedRecipientType,
      recipientController.text,
    );

    return recipientExists;
  }

  Future<bool> processTransaction({bool bypassAnomalyCheck = false}) async {
    isProcessing = true;
    notifyListeners();

    try {
      bool isValid = await validateTransaction();
      if (!isValid) {
        isProcessing = false;
        notifyListeners();
        return false;
      }

      String? recipientId = await _repository.getRecipientId(
        selectedRecipientType,
        recipientController.text,
      );

      if (recipientId == null) {
        isProcessing = false;
        notifyListeners();
        return false;
      }

      final amount = double.parse(amountController.text);

      // Check for anomalies if not bypassed
      if (!bypassAnomalyCheck && currentUserId != null) {
        final anomalyResult = await _anomalyService.checkTransaction(
          userId: currentUserId!,
          recipientId: recipientId,
          amount: amount,
          paymentMethod: selectedPaymentMethod,
          recipientType: selectedRecipientType,
        );

        if (anomalyResult.isAnomaly) {
          isProcessing = false;
          notifyListeners();
          _anomalyDetectedController.add(anomalyResult);
          return false;
        }
      }

      final transaction = SendTransactionModel(
        recipientId: recipientId,
        recipientInfo: recipientController.text,
        recipientType: selectedRecipientType,
        amount: amount,
        paymentMethod: selectedPaymentMethod,
      );

      bool success = await _repository.processTransaction(
        transaction,
        currentUserId!,
      );

      if (success) {
        userBalance -= transaction.amount;
        await _loadUserBalance();
        resetForm();
      }

      isProcessing = false;
      notifyListeners();
      _transactionResultController.add(success);

      return success;
    } catch (e) {
      isProcessing = false;
      notifyListeners();
      _transactionResultController.add(false);
      return false;
    }
  }

  void resetForm() {
    currentStep = 1;
    recipientController.clear();
    amountController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    recipientController.dispose();
    amountController.dispose();
    _transactionResultController.close();
    _anomalyDetectedController.close();
    super.dispose();
  }

  double getBalanceAfterTransaction() {
    if (amountController.text.isEmpty) return userBalance;
    double amount = double.parse(amountController.text);
    return userBalance - amount;
  }
}
