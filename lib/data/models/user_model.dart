class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final bool useBiometric;
  final bool linkBankAccount;
  final String? accountNumber;
  final String? routingNumber;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.useBiometric,
    this.linkBankAccount = false,
    this.accountNumber,
    this.routingNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'useBiometric': useBiometric,
    };

    if (linkBankAccount) {
      data.addAll({
        'linkBankAccount': true,
        'accountNumber': accountNumber ?? '',
        'routingNumber': routingNumber ?? '',
      });
    }

    return data;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      useBiometric:
          json['useBiometric'] as bool? ?? false, // Ensures type safety
      linkBankAccount: json['linkBankAccount'] as bool? ?? false,
      accountNumber: json['accountNumber'] as String?,
      routingNumber: json['routingNumber'] as String?,
    );
  }
}
