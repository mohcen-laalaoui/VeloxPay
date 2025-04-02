import 'package:flutter/material.dart';

class BalanceProvider extends ChangeNotifier {
  double _userBalance = 5.0; 

  double get userBalance => _userBalance;

  void updateBalance(double amount) {
    _userBalance += amount; 
    notifyListeners();
  }
}
