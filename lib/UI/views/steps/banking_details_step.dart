import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:VeloxPay/UI/widgets/custom_input_decoration.dart';
import 'package:VeloxPay/UI/widgets/section_header.dart';
import 'package:VeloxPay/core/util/validators.dart';
import 'package:VeloxPay/viewmodels/signup_viewmodel.dart';

class BankingDetailsStep extends StatelessWidget {
  final SignUpViewModel viewModel;

  const BankingDetailsStep({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: viewModel.bankingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
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
              value: viewModel.linkBankAccount,
              onChanged: viewModel.toggleLinkBankAccount,
              activeColor: Colors.blue[800],
            ),

            const SizedBox(height: 16),

            if (viewModel.linkBankAccount) ...[
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
                        controller: viewModel.accountNumberController,
                        decoration: CustomInputDecoration.getDecoration(
                          labelText: 'Account Number',
                          prefixIcon: Icons.account_balance,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator:
                            (value) => Validators.validateBankField(
                              value,
                              viewModel.linkBankAccount,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: viewModel.routingNumberController,
                        decoration: CustomInputDecoration.getDecoration(
                          labelText: 'Routing Number',
                          prefixIcon: Icons.numbers,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator:
                            (value) => Validators.validateBankField(
                              value,
                              viewModel.linkBankAccount,
                            ),
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
              value: viewModel.agreeToTerms,
              onChanged:
                  (bool? value) => viewModel.toggleAgreeToTerms(value ?? false),
              activeColor: Colors.blue[800],
            ),
          ],
        ),
      ),
    );
  }
}
