import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final List<String> _recipientTypes = ['Phone', 'Email', 'ID'];
  final List<String> _paymentMethods = [
    'Bank Transfer',
    'Mobile Wallet',
    'Card Payment',
  ];

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
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Recipient ($_selectedRecipientType)',
                    _recipientController.text,
                  ),
                  _buildDetailRow('Amount', '\$${_amountController.text}'),
                  _buildDetailRow('Method', _selectedPaymentMethod),
                ],
              ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Money sent successfully!'),
                      backgroundColor: Colors.green[600],
                    ),
                  );
                  setState(() => _step = 1);
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue[800],
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
        title: Text(
          'Send Money',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Indicator
                _buildProgressIndicator(),
                const SizedBox(height: 20),

                // Dynamic Content Based on Step
                if (_step == 1) ...[_buildRecipientStep()],

                if (_step == 2) ...[_buildAmountStep()],

                if (_step == 3) ...[_buildReviewStep()],
              ],
            ),
          ),
        ),
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
