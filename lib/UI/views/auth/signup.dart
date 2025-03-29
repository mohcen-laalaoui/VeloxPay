import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _pageController = PageController();

  final _personalInfoFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();
  final _bankingFormKey = GlobalKey<FormState>();

  int _currentStep = 0;
  final int _totalSteps = 3;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _accountNumberFocusNode = FocusNode();
  final _routingNumberFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _useBiometric = false;
  bool _linkBankAccount = false;
  bool _agreeToTerms = false;

  final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  final _phoneRegex = RegExp(r'^\+?1?\d{10,14}$');

  final List<Map<String, String>> _steps = [
    {'title': 'Personal Information', 'subtitle': 'Tell us about yourself'},
    {'title': 'Security Setup', 'subtitle': 'Secure your account'},
    {
      'title': 'Banking Details',
      'subtitle': 'Optional: Link your bank account',
    },
  ];

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitSignUp() async {
    if (_linkBankAccount && !_bankingFormKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showSnackBar(
        'Please agree to the Terms of Service and Privacy Policy',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      Map<String, dynamic> userData = {
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'useBiometric': _useBiometric,
      };

      if (_linkBankAccount) {
        userData.addAll({
          'linkBankAccount': true,
          'accountNumber': _accountNumberController.text.trim(),
          'routingNumber': _routingNumberController.text.trim(),
        });
      }

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set(userData);

      _showSnackBar('Account created successfully!');

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
      _showSnackBar(errorMessage, isError: true);
    } catch (e) {
      _showSnackBar('An unexpected error occurred.', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && !_personalInfoFormKey.currentState!.validate())
      return;
    if (_currentStep == 1 && !_securityFormKey.currentState!.validate()) return;

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _previousStep,
        ),
        title: Text(
          'Create Account',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _steps[_currentStep]['title']!,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _steps[_currentStep]['subtitle']!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: _totalSteps,
                            effect: ExpandingDotsEffect(
                              activeDotColor: Colors.blue[800]!,
                              dotColor: Colors.grey[300]!,
                              dotHeight: 8,
                              dotWidth: 8,
                              expansionFactor: 4,
                            ),
                            onDotClicked: (index) {},
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentStep = index;
                          });
                        },
                        children: [
                          _buildPersonalInfoStep(),
                          _buildSecuritySetupStep(),
                          _buildBankingDetailsStep(),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _previousStep,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.blue[800]!),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Previous',
                                  style: TextStyle(color: Colors.blue[800]),
                                ),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed:
                                  _currentStep == _totalSteps - 1
                                      ? _submitSignUp
                                      : _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _currentStep == _totalSteps - 1
                                    ? 'Create Account'
                                    : 'Next',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _personalInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.person_outline,
              title: "Personal Details",
              subtitle: "Please provide your basic information",
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: _customInputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icons.person_outline,
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_emailFocusNode);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().split(' ').length < 2) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: _customInputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_phoneFocusNode);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!_emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              decoration: _customInputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!_phoneRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),
            const Text(
              "We'll use this information to send you important account updates.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySetupStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _securityFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.security,
              title: "Account Security",
              subtitle: "Create a strong password for your account",
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: _customInputDecoration(
                labelText: 'Password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                return null;
              },
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'Password must be at least 8 characters',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              decoration: _customInputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 0,
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enhanced Security',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Enable Biometric Authentication',
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Use fingerprint or face recognition for faster login',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _useBiometric,
                      onChanged: (bool value) {
                        setState(() {
                          _useBiometric = value;
                        });
                      },
                      activeColor: Colors.blue[800],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankingDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _bankingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.account_balance_outlined,
              title: "Banking Details",
              subtitle: "Connect your bank account (optional)",
            ),
            const SizedBox(height: 24),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Link Bank Account'),
              subtitle: const Text(
                'Securely connect your bank account for faster transactions',
              ),
              value: _linkBankAccount,
              onChanged: (bool value) {
                setState(() {
                  _linkBankAccount = value;
                });
              },
              activeColor: Colors.blue[800],
            ),

            const SizedBox(height: 16),

            if (_linkBankAccount) ...[
              Card(
                elevation: 0,
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _accountNumberController,
                        focusNode: _accountNumberFocusNode,
                        decoration: _customInputDecoration(
                          labelText: 'Account Number',
                          prefixIcon: Icons.account_balance,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_routingNumberFocusNode);
                        },
                        validator: (value) {
                          if (_linkBankAccount &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Please enter your account number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _routingNumberController,
                        focusNode: _routingNumberFocusNode,
                        decoration: _customInputDecoration(
                          labelText: 'Routing Number',
                          prefixIcon: Icons.numbers,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (_linkBankAccount &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Please enter your routing number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your banking information is encrypted and stored securely.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      size: 48,
                      color: Colors.blue[800],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You can link your bank account later',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Access to your bank account allows for faster transfers and automatic payments',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              value: _agreeToTerms,
              onChanged: (bool? value) {
                setState(() {
                  _agreeToTerms = value ?? false;
                });
              },
              activeColor: Colors.blue[800],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue[800], size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _customInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon, color: Colors.grey),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue[800]!),
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _accountNumberFocusNode.dispose();
    _routingNumberFocusNode.dispose();

    super.dispose();
  }
}
