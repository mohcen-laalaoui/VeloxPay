class Transaction {
  final String id;
  final String senderID;
  final String recipientIdentifier;
  final String recipientType; 
  final double amount;
  final String paymentMethod;
  final DateTime timestamp;
  final String status; 
  final String? notes;

  Transaction({
    required this.id,
    required this.senderID,
    required this.recipientIdentifier,
    required this.recipientType,
    required this.amount,
    required this.paymentMethod,
    required this.timestamp,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderID': senderID,
      'recipientIdentifier': recipientIdentifier,
      'recipientType': recipientType,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status,
      'notes': notes,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      senderID: map['senderID'],
      recipientIdentifier: map['recipientIdentifier'],
      recipientType: map['recipientType'],
      amount: map['amount'],
      paymentMethod: map['paymentMethod'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      status: map['status'],
      notes: map['notes'],
    );
  }
}
