import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

final TextEditingController _bankAccountController = TextEditingController();
final TextEditingController _ifscCodeController = TextEditingController();
final TextEditingController _cardNumberController = TextEditingController();
final TextEditingController _idNumberController = TextEditingController();
bool _agreeToTerms = false;


final List<String> _stepTitles = [
  "Personal Information",
  "Security Setup",
  "Financial Details",
  "Compliance & Terms",
];

final List<String> _stepDescriptions = [
  "Enter your personal details to get started.",
  "Set up security questions to protect your account.",
  "Provide financial information to link your bank account.",
  "Agree to our terms and conditions before proceeding.",
];

class _SignUpPageState extends State<SignUpPage> {
  int _currentStep = 0;
  bool _useBiometric = false;
  bool _linkBankAccount = false;
  bool _uploadHistory = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _phoneController = TextEditingController();
  final _securityQuestion1Controller = TextEditingController();
  final _securityAnswer1Controller = TextEditingController();
  final _securityQuestion2Controller = TextEditingController();
  final _securityAnswer2Controller = TextEditingController();

  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();

  void displayMessageToUser(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _completeSignUp() async {
    if (!_formKey.currentState!.validate()) {
      displayMessageToUser("Please correct the errors in the form");
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      displayMessageToUser("Passwords don't match");
      return;
    }

    if (!_agreeTerms || !_agreePrivacy) {
      displayMessageToUser("You must agree to the terms and privacy policy");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
      
      // Create user document in Firestore
      await _createUserDocument(userCredential);
      
      setState(() {
        _isLoading = false;
      });
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Account Created Successfully'),
            content: const Text(
              'Your account has been created. Please check your email for verification.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to login page or home page
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      
      setState(() {
        _isLoading = false;
      });
      
      displayMessageToUser(errorMessage);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      displayMessageToUser('An unexpected error occurred: $e');
    }
  }

  Future<void> _createUserDocument(UserCredential userCredential) async {
    if (userCredential.user == null) {
      throw Exception("User creation failed - user is null");
    }

    try {
      // Create a map of user data
      Map<String, dynamic> userData = {
        'email': userCredential.user!.email,
        'username': _nameController.text,
        'phone': _phoneController.text,
        'security_question_1': _securityQuestion1Controller.text,
        'security_answer_1': _securityAnswer1Controller.text,
        'security_question_2': _securityQuestion2Controller.text,
        'security_answer_2': _securityAnswer2Controller.text,
        'use_biometric': _useBiometric,
        'created_at': FieldValue.serverTimestamp(),
      };
      
      // Only add financial details if user has opted in
      if (_linkBankAccount) {
        userData['account_number'] = _accountNumberController.text;
        userData['routing_number'] = _routingNumberController.text;
      }
      
      userData['link_bank_account'] = _linkBankAccount;
      userData['upload_history'] = _uploadHistory;
      userData['agree_terms'] = _agreeTerms;
      userData['agree_privacy'] = _agreePrivacy;

      // Add to Firestore with user UID as document ID (more secure than email)
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set(userData);
      
    } catch (e) {
      print("Error creating user document: $e");
      throw Exception("Failed to save user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
        : Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stepTitles[_currentStep],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _stepDescriptions[_currentStep],
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / _stepTitles.length,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF1E3A8A),
                  ),
                  const SizedBox(height: 8),
                  // Step counter
                  Text(
                    'Step ${_currentStep + 1} of ${_stepTitles.length}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(key: _formKey, child: _buildCurrentStepContent()),
              ),
            ),

            // Bottom navigation buttons
            _buildBottomNavigation(),
          ],
        ),
    );
  }

 Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildSecurityStep();
      case 2:
        return _buildFinancialInfoStep(); 
      case 3:
        return _buildComplianceStep();
      default:
        return Container();
    }
  }


  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            } else if (!RegExp(
              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
            ).hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: const Icon(Icons.visibility_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            helperText:
                'Password must contain at least 8 characters, including uppercase, lowercase, and numbers',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            } else if (value.length < 8) {
              return 'Password must be at least 8 characters long';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: const Icon(Icons.visibility_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            } else if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSecurityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.security, color: Color(0xFF3B82F6)),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Two-factor authentication adds an extra layer of security to your account',
                  style: TextStyle(color: Color(0xFF1E40AF)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '2FA (Two-Factor Authentication)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number for SMS Verification',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Security Questions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Set up security questions for account recovery',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _securityQuestion1Controller,
          decoration: InputDecoration(
            labelText: 'Security Question 1',
            prefixIcon: const Icon(Icons.question_answer_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'e.g. What was your first pet\'s name?',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a security question';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _securityAnswer1Controller,
          decoration: InputDecoration(
            labelText: 'Answer to Question 1',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an answer';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _securityQuestion2Controller,
          decoration: InputDecoration(
            labelText: 'Security Question 2',
            prefixIcon: const Icon(Icons.question_answer_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'e.g. In what city were you born?',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a security question';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _securityAnswer2Controller,
          decoration: InputDecoration(
            labelText: 'Answer to Question 2',
            prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an answer';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text('Back', style: TextStyle(color: Colors.black87)),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  if (_currentStep < _stepTitles.length - 1) {
                    _currentStep++;
                  } else {
                    _submitForm();
                  }
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                _currentStep < _stepTitles.length - 1 ? 'Next' : 'Submit',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildFinancialInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _bankAccountController,
          decoration: InputDecoration(
            labelText: 'Bank Account Number',
            prefixIcon: const Icon(Icons.account_balance),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your bank account number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ifscCodeController,
          decoration: InputDecoration(
            labelText: 'Bank IFSC Code',
            prefixIcon: const Icon(Icons.code),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the IFSC code';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your card number';
            } else if (value.length < 16) {
              return 'Card number must be 16 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

Widget _buildComplianceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identity Verification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _idNumberController,
          decoration: InputDecoration(
            labelText: 'National ID / Passport Number',
            prefixIcon: const Icon(Icons.perm_identity),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your ID or passport number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value!;
            });
          },
          title: const Text(
            'I agree to the terms and conditions',
            style: TextStyle(fontSize: 14),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }


  void _submitForm() {
    setState(() {
      _isLoading = true;
    });

    // Simulate form submission process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      Navigator.pop(context);
    });
  }
}
