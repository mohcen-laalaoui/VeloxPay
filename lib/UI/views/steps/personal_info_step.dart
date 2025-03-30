import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:VeloxPay/UI/widgets/custom_input_decoration.dart';
import 'package:VeloxPay/UI/widgets/section_header.dart';
import 'package:VeloxPay/core/util/validators.dart';
import 'package:VeloxPay/viewmodels/signup_viewmodel.dart';

class PersonalInfoStep extends StatelessWidget {
  final SignUpViewModel viewModel;

  const PersonalInfoStep({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: viewModel.personalInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Icons.person_outline,
              title: "Personal Details",
              subtitle: "Please provide your basic information",
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: viewModel.nameController,
              decoration: CustomInputDecoration.getDecoration(
                labelText: 'Full Name',
                prefixIcon: Icons.person_outline,
              ),
              textInputAction: TextInputAction.next,
              validator: Validators.validateName,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: viewModel.emailController,
              decoration: CustomInputDecoration.getDecoration(
                labelText: 'Email Address',
                prefixIcon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.validateEmail,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: viewModel.phoneController,
              decoration: CustomInputDecoration.getDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: Validators.validatePhone,
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
}
