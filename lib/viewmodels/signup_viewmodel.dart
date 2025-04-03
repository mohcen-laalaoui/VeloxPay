import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:VeloxPay/data/models/user_model.dart';
import 'package:VeloxPay/core/services/auth_services.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final accountNumberController = TextEditingController();
  final routingNumberController = TextEditingController();

  final personalInfoFormKey = GlobalKey<FormState>();
  final securityFormKey = GlobalKey<FormState>();
  final bankingFormKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool useBiometric = false;
  bool linkBankAccount = false;
  bool agreeToTerms = false;

  int currentStep = 0;
  final int totalSteps = 3;

  final List<Map<String, String>> steps = [
    {'title': 'Personal Information', 'subtitle': 'Tell us about yourself'},
    {'title': 'Security Setup', 'subtitle': 'Secure your account'},
    {
      'title': 'Banking Details',
      'subtitle': 'Optional: Link your bank account',
    },
  ];

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void toggleUseBiometric(bool value) {
    useBiometric = value;
    notifyListeners();
  }

  void toggleLinkBankAccount(bool value) {
    linkBankAccount = value;
    notifyListeners();
  }

  void toggleAgreeToTerms(bool value) {
    agreeToTerms = value;
    notifyListeners();
  }

  void setCurrentStep(int step) {
    currentStep = step;
    notifyListeners();
  }

  bool validatePersonalInfoStep() {
    return personalInfoFormKey.currentState?.validate() ?? false;
  }

  bool validateSecurityStep() {
    return securityFormKey.currentState?.validate() ?? false;
  }

  bool validateBankingStep() {
    if (!linkBankAccount) return true;
    return bankingFormKey.currentState?.validate() ?? false;
  }

  Future<Map<String, dynamic>> submitSignUp() async {
    if (!validateBankingStep()) {
      return {
        'success': false,
        'message': 'Please check your banking information',
      };
    }

    if (!agreeToTerms) {
      return {
        'success': false,
        'message': 'Please agree to the Terms of Service and Privacy Policy',
      };
    }

    isLoading = true;
    notifyListeners();

    try {
      final user = UserModel(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        useBiometric: useBiometric,
        linkBankAccount: linkBankAccount,
        accountNumber:
            linkBankAccount ? accountNumberController.text.trim() : null,
        routingNumber:
            linkBankAccount ? routingNumberController.text.trim() : null,
        uid: '',
      );

      UserCredential userCredential = await _authService.signUp(
        emailController.text.trim(),
        passwordController.text,
        user,
      );

      await _authService.createUserBalance(userCredential.user!.uid);

      return {'success': true, 'message': 'Account created successfully!'};
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        default:
          errorMessage = 'Registration failed. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    accountNumberController.dispose();
    routingNumberController.dispose();
  }
}
