import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:VeloxPay/viewmodels/transaction_viewmodel.dart';

class TransactionPage extends StatefulWidget {
  final String recipientIdentifier;
  final String recipientType;
  final double amount;
  final String paymentMethod;
  final String? notes;

  const TransactionPage({
    super.key,
    required this.recipientIdentifier,
    required this.recipientType,
    required this.amount,
    required this.paymentMethod,
    this.notes,
  });

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late TransactionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TransactionViewModel();
    _processTransaction();
  }

  Future<void> _processTransaction() async {
    await _viewModel.processTransaction(
      recipientIdentifier: widget.recipientIdentifier,
      recipientType: widget.recipientType,
      amount: widget.amount,
      paymentMethod: widget.paymentMethod,
      notes: widget.notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<TransactionViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'Transaction',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: viewModel.isProcessing
                    ? _buildProcessingView()
                    : viewModel.isError
                        ? _buildErrorView(viewModel)
                        : viewModel.isSuccess
                            ? _buildSuccessView(viewModel)
                            : Center(child: CircularProgressIndicator()),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue[800]),
          const SizedBox(height: 20),
          Text(
            'Processing Transaction...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please do not close this screen',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(TransactionViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 70, color: Colors.red[700]),
          const SizedBox(height: 20),
          Text(
            'Transaction Failed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            viewModel.errorMessage ?? 'An unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _processTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[800],
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
            child: const Text(
              'Go Back',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(TransactionViewModel viewModel) {
    final transaction = viewModel.transaction;
    if (transaction == null) {
      return Center(child: Text('No transaction data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 70,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Transaction Successful',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your money has been sent successfully',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _buildTransactionDetailRow(
                  'Transaction ID',
                  transaction.id,
                ),
                const Divider(),
                _buildTransactionDetailRow(
                  'Amount',
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  valueStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const Divider(),
                _buildTransactionDetailRow(
                  'Recipient (${transaction.recipientType})',
                  transaction.recipientIdentifier,
                ),
                const Divider(),
                _buildTransactionDetailRow(
                  'Payment Method',
                  transaction.paymentMethod,
                ),
                const Divider(),
                _buildTransactionDetailRow(
                  'Date & Time',
                  viewModel.formatDateTime(transaction.timestamp),
                ),
                if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                  const Divider(),
                  _buildTransactionDetailRow(
                    'Notes',
                    transaction.notes!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Receipt saved to your transactions'),
                  backgroundColor: Colors.green[600],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.receipt_long, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'View Receipt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[800],
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailRow(
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
