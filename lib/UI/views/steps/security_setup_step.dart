import 'package:flutter/material.dart';
import 'package:VeloxPay/UI/widgets/custom_input_decoration.dart';
import 'package:VeloxPay/UI/widgets/section_header.dart';
import 'package:VeloxPay/core/util/validators.dart';
import 'package:VeloxPay/viewmodels/signup_viewmodel.dart';

class SecuritySetupStep extends StatelessWidget {
  final SignUpViewModel viewModel;

  const SecuritySetupStep({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: viewModel.securityFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Icons.security,
              title: "Account Security",
              subtitle: "Create a strong password for your account",
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: viewModel.passwordController,
              decoration: CustomInputDecoration.getDecoration(
                labelText: 'Password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: viewModel.toggleObscurePassword,
                ),
              ),
              obscureText: viewModel.obscurePassword,
              textInputAction: TextInputAction.next,
              validator: Validators.validatePassword,
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
              controller: viewModel.confirmPasswordController,
              decoration: CustomInputDecoration.getDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: viewModel.toggleObscureConfirmPassword,
                ),
              ),
              obscureText: viewModel.obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              validator:
                  (value) => Validators.validateConfirmPassword(
                    value,
                    viewModel.passwordController.text,
                  ),
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
                      value: viewModel.useBiometric,
                      onChanged: viewModel.toggleUseBiometric,
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
}
