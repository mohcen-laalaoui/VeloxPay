import 'package:flutter/material.dart';
import 'package:VeloxPay/core/services/anomaly_detection_service.dart';

class AnomalyWarningDialog extends StatelessWidget {
  final AnomalyResult anomalyResult;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const AnomalyWarningDialog({
    super.key,
    required this.anomalyResult,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 10),
          Text('Unusual Transaction Detected'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This transaction appears unusual based on your previous activity.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          if (anomalyResult.reason.isNotEmpty)
            Text(
              'Reason: ${anomalyResult.reason}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 16),
          Text(
            'Risk level: ${_getRiskLevelText(anomalyResult.riskScore)}',
            style: TextStyle(
              color: _getRiskLevelColor(anomalyResult.riskScore),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text('Would you like to continue with this transaction?'),
        ],
      ),
      actions: [
        TextButton(onPressed: onCancel, child: Text('CANCEL')),
        ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: Text('CONTINUE ANYWAY'),
        ),
      ],
    );
  }

  String _getRiskLevelText(double riskScore) {
    if (riskScore < 0.3) return 'Low';
    if (riskScore < 0.7) return 'Medium';
    return 'High';
  }

  Color _getRiskLevelColor(double riskScore) {
    if (riskScore < 0.3) return Colors.green;
    if (riskScore < 0.7) return Colors.orange;
    return Colors.red;
  }
}
