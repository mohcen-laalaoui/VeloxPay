import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  _DepositPageState createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'Bank Transfer';

  final List<String> _depositMethods = [
    'Bank Transfer',
    'Credit Card',
    'Debit Card',
    'PayPal',
    'Crypto',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deposit Funds',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BalanceCard(),
              const SizedBox(height: 20),
              const Text(
                'Select Deposit Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DepositMethodSelector(
                methods: _depositMethods,
                onMethodSelected: (method) {
                  setState(() {
                    _selectedMethod = method;
                  });
                },
                selectedMethod: _selectedMethod,
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter Deposit Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DepositAmountInput(controller: _amountController),
              const SizedBox(height: 20),
              DepositDetailsCard(selectedMethod: _selectedMethod),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _processDeposit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirm Deposit',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processDeposit() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid deposit amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Deposit Confirmation'),
            content: Text(
              'Deposit of \$${amount.toStringAsFixed(2)} via $_selectedMethod',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

// Balance Card Widget
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            '\$5,420.75',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VeloxPay Account',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Icon(Icons.account_balance_wallet, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class DepositMethodSelector extends StatelessWidget {
  final List<String> methods;
  final Function(String) onMethodSelected;
  final String selectedMethod;

  const DepositMethodSelector({
    super.key,
    required this.methods,
    required this.onMethodSelected,
    required this.selectedMethod,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            methods.map((method) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(method),
                  selected: selectedMethod == method,
                  onSelected: (selected) {
                    if (selected) {
                      onMethodSelected(method);
                    }
                  },
                  selectedColor: Colors.blueAccent.shade100,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color:
                        selectedMethod == method
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class DepositAmountInput extends StatelessWidget {
  final TextEditingController controller;

  const DepositAmountInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(7),
      ],
      decoration: InputDecoration(
        prefixText: '\$ ',
        labelText: 'Amount',
        hintText: 'Enter deposit amount',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}

class DepositDetailsCard extends StatelessWidget {
  final String selectedMethod;

  const DepositDetailsCard({super.key, required this.selectedMethod});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deposit Details: $selectedMethod',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _getMethodDetails(selectedMethod),
        ],
      ),
    );
  }

  Widget _getMethodDetails(String method) {
    switch (method) {
      case 'Bank Transfer':
        return const Text(
          'Instant transfer from your linked bank account. No additional fees.',
          style: TextStyle(color: Colors.black87),
        );
      case 'Credit Card':
        return const Text(
          'Deposit using Visa or Mastercard. 2.9% + \$0.30 transaction fee applies.',
          style: TextStyle(color: Colors.black87),
        );
      case 'Debit Card':
        return const Text(
          'Quick deposit from your debit card. Instant processing with no additional fees.',
          style: TextStyle(color: Colors.black87),
        );
      case 'PayPal':
        return const Text(
          'Deposit directly from your PayPal account. 2.5% transaction fee.',
          style: TextStyle(color: Colors.black87),
        );
      case 'Crypto':
        return const Text(
          'Deposit using Bitcoin, Ethereum, or other supported cryptocurrencies.',
          style: TextStyle(color: Colors.black87),
        );
      default:
        return const Text(
          'Select a deposit method to see details.',
          style: TextStyle(color: Colors.grey),
        );
    }
  }
}
