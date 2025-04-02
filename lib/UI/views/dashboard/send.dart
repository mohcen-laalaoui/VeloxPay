import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedRecipientType = 'Phone';
  String _selectedPaymentMethod = 'Bank Transfer';
  int _step = 1;
  bool _isProcessing = false;

  final List<String> _recipientTypes = ['Phone', 'Email', 'ID'];
  final List<String> _paymentMethods = [
    'Bank Transfer',
    'Mobile Wallet',
    'Card Payment',
  ];

  late String _currentUserId;
  double _userBalance = 10.0;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadUserBalance();
  }

  Future<void> _getCurrentUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  Future<void> _loadUserBalance() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        setState(() {
          _userBalance =
              (userDoc.data() as Map<String, dynamic>)['balance'] ?? 10.0;
        });
      }
    } catch (e) {
      print('Error loading user balance: $e');
    }
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _step++;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _step--;
    });
  }

  Future<bool> _validateTransaction() async {
    double amount = double.parse(_amountController.text);

    if (amount > _userBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Insufficient balance for this transaction'),
          backgroundColor: Colors.red[600],
        ),
      );
      return false;
    }

    bool recipientExists = await _checkRecipientExists(
      _selectedRecipientType,
      _recipientController.text,
    );

    if (!recipientExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recipient not found with this $_selectedRecipientType',
          ),
          backgroundColor: Colors.red[600],
        ),
      );
      return false;
    }

    return true;
  }

  Future<bool> _checkRecipientExists(String type, String value) async {
    try {
      String fieldName = type.toLowerCase();

      QuerySnapshot query =
          await FirebaseFirestore.instance
              .collection('users')
              .where(fieldName, isEqualTo: value)
              .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking recipient: $e');
      return false;
    }
  }

  Future<String?> _getRecipientId(String type, String value) async {
    try {
      String fieldName = type.toLowerCase();

      QuerySnapshot query =
          await FirebaseFirestore.instance
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

  Future<void> _processTransaction() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      bool isValid = await _validateTransaction();
      if (!isValid) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      double amount = double.parse(_amountController.text);
      String? recipientId = await _getRecipientId(
        _selectedRecipientType,
        _recipientController.text,
      );

      if (recipientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error finding recipient'),
            backgroundColor: Colors.red[600],
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference senderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId);

      batch.update(senderRef, {'balance': FieldValue.increment(-amount)});

      DocumentReference recipientRef = FirebaseFirestore.instance
          .collection('users')
          .doc(recipientId);

      batch.update(recipientRef, {'balance': FieldValue.increment(amount)});

      DocumentReference transactionRef =
          FirebaseFirestore.instance.collection('transactions').doc();

      batch.set(transactionRef, {
        'sender': _currentUserId,
        'recipient': recipientId,
        'amount': amount,
        'method': _selectedPaymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
        'type': 'transfer',
      });

      DocumentReference senderHistoryRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUserId)
              .collection('transaction_history')
              .doc();

      batch.set(senderHistoryRef, {
        'transactionId': transactionRef.id,
        'partnerId': recipientId,
        'partnerInfo': _recipientController.text,
        'amount': -amount,
        'method': _selectedPaymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'sent',
      });

      DocumentReference recipientHistoryRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(recipientId)
              .collection('transaction_history')
              .doc();

      batch.set(recipientHistoryRef, {
        'transactionId': transactionRef.id,
        'partnerId': _currentUserId,
        'partnerInfo': 'User',
        'amount': amount,
        'method': _selectedPaymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'received',
      });

      await batch.commit();

      setState(() {
        _userBalance -= amount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Money sent successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );

      setState(() {
        _step = 1;
        _recipientController.clear();
        _amountController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction failed: ${e.toString()}'),
          backgroundColor: Colors.red[600],
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _confirmTransaction() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Confirm Transaction',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: _buildDetailRow(
                    'Recipient ($_selectedRecipientType)',
                    _recipientController.text,
                  ),
                ),
                Flexible(
                  child: _buildDetailRow(
                    'Amount',
                    '\$${_amountController.text}',
                  ),
                ),
                Flexible(
                  child: _buildDetailRow('Method', _selectedPaymentMethod),
                ),
                const SizedBox(height: 5),
                Flexible(
                  child: Text(
                    'Your balance after this transaction will be \$${(_userBalance - double.parse(_amountController.text)).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _processTransaction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              softWrap: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Send Money',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Balance: \$${_userBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isProcessing
                ? _buildLoadingIndicator()
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProgressIndicator(),
                          const SizedBox(height: 20),

                          if (_step == 1) ...[_buildRecipientStep()],

                          if (_step == 2) ...[_buildAmountStep()],

                          if (_step == 3) ...[_buildReviewStep()],
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue[800]),
          const SizedBox(height: 16),
          Text(
            'Processing your transaction...',
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 30,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: _step > index ? Colors.blue[800] : Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildRecipientStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedRecipientType,
          decoration: _customInputDecoration('Send via'),
          items:
              _recipientTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedRecipientType = value!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _recipientController,
          decoration: _customInputDecoration(
            'Enter $_selectedRecipientType',
            prefixIcon: Icons.person_outline,
          ),
          validator:
              (value) =>
                  value!.isEmpty ? 'Please enter recipient details' : null,
        ),
        const SizedBox(height: 24),
        _buildNextButton(_nextStep),

        _buildQuickSendSection(),
      ],
    );
  }

  Widget _buildAmountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _amountController,
          decoration: _customInputDecoration(
            'Amount',
            prefixIcon: Icons.attach_money_outlined,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter amount';
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount > _userBalance) {
              return 'Insufficient balance';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedPaymentMethod,
          decoration: _customInputDecoration('Payment Method'),
          items:
              _paymentMethods
                  .map(
                    (method) =>
                        DropdownMenuItem(value: method, child: Text(method)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBackButton(_previousStep),
            _buildNextButton(_nextStep),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Review Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Recipient ($_selectedRecipientType)',
                _recipientController.text,
              ),
              Divider(color: Colors.grey[300]),
              _buildDetailRow('Amount', '\$${_amountController.text}'),
              Divider(color: Colors.grey[300]),
              _buildDetailRow('Method', _selectedPaymentMethod),
              Divider(color: Colors.grey[300]),
              _buildDetailRow(
                'Current Balance',
                '\$${_userBalance.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Balance After Transaction',
                '\$${(_userBalance - double.parse(_amountController.text)).toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBackButton(_previousStep),
            _buildConfirmButton(_confirmTransaction),
          ],
        ),
      ],
    );
  }

  InputDecoration _customInputDecoration(
    String labelText, {
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[800]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
      ),
    );
  }

  Widget _buildNextButton(VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[800],
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Next',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBackButton(VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue[800],
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      child: const Text(
        'Back',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildConfirmButton(VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[800],
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Confirm Transaction',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQuickSendSection() {
    final List<Map<String, dynamic>> recentContacts = [
      {'name': 'Moncef Laalaoui ', 'avatar': 'ML', 'color': Colors.blue[200]},
      {'name': 'Dhia Amani', 'avatar': 'DA', 'color': Colors.green[200]},
      {'name': 'Chaker Ketfi', 'avatar': 'CH', 'color': Colors.orange[200]},
      {'name': 'Bachir Bioud', 'avatar': 'BB', 'color': Colors.purple[200]},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Quick Send',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                recentContacts.map((contact) {
                  return GestureDetector(
                    onTap: () {
                      _recipientController.text = contact['name'];
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: contact['color'],
                            radius: 30,
                            child: Text(
                              contact['avatar'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            contact['name'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    super.dispose();
  }
}
