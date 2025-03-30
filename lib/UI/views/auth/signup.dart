import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:VeloxPay/UI/views/steps/banking_details_step.dart';
import 'package:VeloxPay/UI/views/steps/personal_info_step.dart';
import 'package:VeloxPay/UI/views/steps/security_setup_step.dart';
import 'package:VeloxPay/viewmodels/signup_viewmodel.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _pageController = PageController();
  late SignUpViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SignUpViewModel();
  }

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

  void _nextStep() {
    if (_viewModel.currentStep == 0 && !_viewModel.validatePersonalInfoStep()) {
      return;
    }
    if (_viewModel.currentStep == 1 && !_viewModel.validateSecurityStep()) {
      return;
    }

    if (_viewModel.currentStep < _viewModel.totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_viewModel.currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSubmit() async {
    final result = await _viewModel.submitSignUp();

    if (result['success']) {
      _showSnackBar(result['message']);
      // Navigate to next screen or handle successful signup
    } else {
      _showSnackBar(result['message'], isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<SignUpViewModel>(
        builder: (context, viewModel, _) {
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
                viewModel.isLoading
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
                                      viewModel.steps[viewModel
                                          .currentStep]['title']!,
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
                                  viewModel.steps[viewModel
                                      .currentStep]['subtitle']!,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 16),
                                SmoothPageIndicator(
                                  controller: _pageController,
                                  count: viewModel.totalSteps,
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
                              onPageChanged: viewModel.setCurrentStep,
                              children: [
                                PersonalInfoStep(viewModel: viewModel),
                                SecuritySetupStep(viewModel: viewModel),
                                BankingDetailsStep(viewModel: viewModel),
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
                                if (viewModel.currentStep > 0)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _previousStep,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.blue[800]!,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Previous',
                                        style: TextStyle(
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (viewModel.currentStep > 0)
                                  const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed:
                                        viewModel.currentStep ==
                                                viewModel.totalSteps - 1
                                            ? _handleSubmit
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
                                      viewModel.currentStep ==
                                              viewModel.totalSteps - 1
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
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
