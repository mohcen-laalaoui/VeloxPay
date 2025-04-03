class SendTransactionModel {
  final String recipientId;
  final String recipientInfo;
  final String recipientType;
  final double amount;
  final String paymentMethod;

  SendTransactionModel({
    required this.recipientId,
    required this.recipientInfo,
    required this.recipientType,
    required this.amount,
    required this.paymentMethod,
  });
}

class UserModel {
  final String id;
  final double balance;
  final List<QuickContactModel> recentContacts;

  UserModel({
    required this.id,
    required this.balance,
    this.recentContacts = const [],
  });
}

class QuickContactModel {
  final String name;
  final String avatar;
  final String color;

  QuickContactModel({
    required this.name,
    required this.avatar,
    required this.color,
  });
}
