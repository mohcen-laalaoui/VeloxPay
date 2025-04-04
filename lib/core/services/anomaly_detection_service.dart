import 'dart:convert';
import 'package:http/http.dart' as http;

class AnomalyResult {
  final bool isAnomaly;
  final double riskScore;
  final String reason;

  AnomalyResult({
    required this.isAnomaly,
    required this.riskScore,
    required this.reason,
  });

  factory AnomalyResult.fromJson(Map<String, dynamic> json) {
    return AnomalyResult(
      isAnomaly: json['is_anomaly'] ?? false,
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] ?? '',
    );
  }
}

class AnomalyDetectionService {
  final String _baseUrl;

 AnomalyDetectionService({String? baseUrl})
    : _baseUrl = baseUrl ?? 'http://127.0.0.1:5000';


  Future<AnomalyResult> checkTransaction({
    required String userId,
    required String recipientId,
    required double amount,
    required String paymentMethod,
    required String recipientType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/detect_anomaly'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'recipient_id': recipientId,
          'amount': amount,
          'payment_method': paymentMethod,
          'recipient_type': recipientType,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AnomalyResult.fromJson(data);
      } else {
        print('Error checking anomaly: ${response.statusCode}');
        return AnomalyResult(isAnomaly: false, riskScore: 0.0, reason: '');
      }
    } catch (e) {
      print('Exception in anomaly detection: $e');
      return AnomalyResult(isAnomaly: false, riskScore: 0.0, reason: '');
    }
  }
}
