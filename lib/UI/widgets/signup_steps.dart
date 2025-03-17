import 'package:flutter/material.dart';

class SignupSteps extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController securityQuestion1Controller;
  final TextEditingController securityAnswer1Controller;
  final TextEditingController securityQuestion2Controller;
  final TextEditingController securityAnswer2Controller;
  final TextEditingController accountNumberController;
  final TextEditingController routingNumberController;
  final TextEditingController idNumberController;
  final bool agreeToTerms;
  final int currentStep;
  final Function(int) onStepChange;
  final Function(bool) onAgreeToTermsChange;

  const SignupSteps({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.securityQuestion1Controller,
    required this.securityAnswer1Controller,
    required this.securityQuestion2Controller,
    required this.securityAnswer2Controller,
    required this.accountNumberController,
    required this.routingNumberController,
    required this.idNumberController,
    required this.agreeToTerms,
    required this.currentStep,
    required this.onStepChange,
    required this.onAgreeToTermsChange,
  });

  @override
  _SignupStepsState createState() => _SignupStepsState();
}

class _SignupStepsState extends State<SignupSteps> {
  @override
  Widget build(BuildContext context) {
    List<Step> stepTiles = [
      Step(
        title: const Text("Account Info"),
        content: Column(
          children: [
            TextFormField(
              controller: widget.nameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextFormField(
              controller: widget.emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextFormField(
              controller: widget.passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextFormField(
              controller: widget.confirmPasswordController,
              decoration: const InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
            ),
          ],
        ),
        isActive: widget.currentStep >= 0,
      ),
      Step(
        title: const Text("Security Questions"),
        content: Column(
          children: [
            TextFormField(
              controller: widget.securityQuestion1Controller,
              decoration: const InputDecoration(
                labelText: "Security Question 1",
              ),
            ),
            TextFormField(
              controller: widget.securityAnswer1Controller,
              decoration: const InputDecoration(labelText: "Answer 1"),
            ),
            TextFormField(
              controller: widget.securityQuestion2Controller,
              decoration: const InputDecoration(
                labelText: "Security Question 2",
              ),
            ),
            TextFormField(
              controller: widget.securityAnswer2Controller,
              decoration: const InputDecoration(labelText: "Answer 2"),
            ),
          ],
        ),
        isActive: widget.currentStep >= 1,
      ),
      Step(
        title: const Text("Financial Info"),
        content: Column(
          children: [
            TextFormField(
              controller: widget.accountNumberController,
              decoration: const InputDecoration(labelText: "Account Number"),
            ),
            TextFormField(
              controller: widget.routingNumberController,
              decoration: const InputDecoration(labelText: "Routing Number"),
            ),
          ],
        ),
        isActive: widget.currentStep >= 2,
      ),
      Step(
        title: const Text("Compliance"),
        content: Column(
          children: [
            TextFormField(
              controller: widget.idNumberController,
              decoration: const InputDecoration(
                labelText: "National ID / Passport Number",
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            CheckboxListTile(
              value: widget.agreeToTerms,
              onChanged: (value) {
                widget.onAgreeToTermsChange(value!);
              },
              title: const Text(
                "I agree to the terms and conditions",
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
        isActive: widget.currentStep >= 3,
      ),
    ];

    return Stepper(
      currentStep: widget.currentStep,
      steps: stepTiles,
      onStepContinue: () {
        if (widget.currentStep < stepTiles.length - 1) {
          widget.onStepChange(widget.currentStep + 1);
        }
      },
      onStepCancel: () {
        if (widget.currentStep > 0) {
          widget.onStepChange(widget.currentStep - 1);
        }
      },
    );
  }
}
