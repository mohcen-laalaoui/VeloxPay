import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:VeloxPay/repositories/send_repository.dart';
import 'package:VeloxPay/viewmodels/send_viewmodel.dart';

class SendPage extends StatelessWidget {
  final VoidCallback? onTransactionComplete;

  const SendPage({super.key, this.onTransactionComplete});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SendViewModel(SendRepository()),
      child: _SendPageContent(onTransactionComplete: onTransactionComplete),
    );
  }
}

class _SendPageContent extends StatefulWidget {
  final VoidCallback? onTransactionComplete;

  const _SendPageContent({this.onTransactionComplete});

  @override
  _SendPageContentState createState() => _SendPageContentState();
}

class _SendPageContentState extends State<_SendPageContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<SendViewModel>(context, listen: false);
    viewModel.transactionResult.listen((success) {
      if (success && widget.onTransactionComplete != null) {
        widget.onTransactionComplete!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SendViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Send Money',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: [_buildBalanceDisplay(viewModel)],
      ),
      body: SafeArea(
        child:
            viewModel.isProcessing
                ? _buildLoadingIndicator()
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProgressIndicator(viewModel),
                          const SizedBox(height: 20),

                          if (viewModel.currentStep == 1) ...[
                            _buildRecipientStep(viewModel),
                          ],
                          if (viewModel.currentStep == 2) ...[
                            _buildAmountStep(viewModel),
                          ],
                          if (viewModel.currentStep == 3) ...[
                            _buildReviewStep(viewModel),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildBalanceDisplay(SendViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: Text(
          'Balance: \$${viewModel.userBalance.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
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

  Widget _buildProgressIndicator(SendViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 30,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color:
                viewModel.currentStep > index
                    ? Colors.blue[800]
                    : Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildRecipientStep(SendViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: viewModel.selectedRecipientType,
          decoration: _customInputDecoration('Send via'),
          items:
              viewModel.recipientTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: (value) => viewModel.updateRecipientType(value!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: viewModel.recipientController,
          decoration: _customInputDecoration(
            'Enter ${viewModel.selectedRecipientType}',
            prefixIcon: Icons.person_outline,
          ),
          validator:
              (value) =>
                  value!.isEmpty ? 'Please enter recipient details' : null,
        ),
        const SizedBox(height: 24),
        _buildNextButton(() {
          if (_formKey.currentState!.validate()) {
            viewModel.nextStep();
          }
        }),

        _buildQuickSendSection(viewModel),
      ],
    );
  }

  Widget _buildAmountStep(SendViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: viewModel.amountController,
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
            if (amount > viewModel.userBalance) {
              return 'Insufficient balance';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: viewModel.selectedPaymentMethod,
          decoration: _customInputDecoration('Payment Method'),
          items:
              viewModel.paymentMethods
                  .map(
                    (method) =>
                        DropdownMenuItem(value: method, child: Text(method)),
                  )
                  .toList(),
          onChanged: (value) => viewModel.updatePaymentMethod(value!),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBackButton(() => viewModel.previousStep()),
            _buildNextButton(() {
              if (_formKey.currentState!.validate()) {
                viewModel.nextStep();
              }
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewStep(SendViewModel viewModel) {
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
                'Recipient (${viewModel.selectedRecipientType})',
                viewModel.recipientController.text,
              ),
              Divider(color: Colors.grey[300]),
              _buildDetailRow('Amount', '\$${viewModel.amountController.text}'),
              Divider(color: Colors.grey[300]),
              _buildDetailRow('Method', viewModel.selectedPaymentMethod),
              Divider(color: Colors.grey[300]),
              _buildDetailRow(
                'Current Balance',
                '\$${viewModel.userBalance.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Balance After Transaction',
                '\$${viewModel.getBalanceAfterTransaction().toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBackButton(() => viewModel.previousStep()),
            _buildConfirmButton(() => _confirmTransaction(viewModel)),
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

  Widget _buildQuickSendSection(SendViewModel viewModel) {
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
                viewModel.recentContacts.map((contact) {
                  return GestureDetector(
                    onTap: () {
                      viewModel.selectQuickContact(contact.name);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: _getColorFromHex(contact.color),
                            radius: 30,
                            child: Text(
                              contact.avatar,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            contact.name,
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

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  void _confirmTransaction(SendViewModel viewModel) {
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
                    'Recipient (${viewModel.selectedRecipientType})',
                    viewModel.recipientController.text,
                  ),
                ),
                Flexible(
                  child: _buildDetailRow(
                    'Amount',
                    '\$${viewModel.amountController.text}',
                  ),
                ),
                Flexible(
                  child: _buildDetailRow(
                    'Method',
                    viewModel.selectedPaymentMethod,
                  ),
                ),
                const SizedBox(height: 5),
                Flexible(
                  child: Text(
                    'Your balance after this transaction will be \$${viewModel.getBalanceAfterTransaction().toStringAsFixed(2)}',
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
                  _processTransaction(viewModel);
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

  Future<void> _processTransaction(SendViewModel viewModel) async {
    bool success = await viewModel.processTransaction();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Money sent successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaction failed. Please try again.'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
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
}
