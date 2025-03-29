// ignore: file_names
import 'package:VeloxPay/UI/views/auth/signin.dart';
import 'package:VeloxPay/UI/views/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: controller,
          onPageChanged: (index) {
            setState(() => isLastPage = index == 2);
          },
          children: [
            OnboardingPage(
              color: Colors.white,
              urlImage: 'assets/fast.png',
              title: 'Fast & Secure Payments',
              subtitle:
                  'Send money instantly to anyone, anywhere with bank-level security',
              imageSize: 150.0,
            ),

            OnboardingPage(
              color: Colors.white,
              urlImage: 'assets/smart.png',
              title: 'Smart Money Management',
              subtitle:
                  'Track expenses, set budgets, and get personalized financial insights',
              imageSize: 150.0,
            ),
            OnboardingPage(
              color: Colors.white,
              urlImage: 'assets/global.png',
              title: 'Global Transactions',
              subtitle:
                  'Pay in any currency with the best exchange rates and lowest fees',
              imageSize: 150.0,
            ),
          ],
        ),
      ),
      bottomSheet:
          isLastPage
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text('SKIP'),
                      onPressed:
                          () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const AuthOptionsScreen(),
                            ),
                          ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(120, 40),
                      ),
                      child: const Text(
                        'GET STARTED',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed:
                          () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const AuthOptionsScreen(),
                            ),
                          ),
                    ),
                  ],
                ),
              )
              : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text('SKIP'),
                      onPressed:
                          () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const AuthOptionsScreen(),
                            ),
                          ),
                    ),
                    Center(
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: 3,
                        effect: const WormEffect(
                          dotHeight: 10,
                          dotWidth: 10,
                          activeDotColor: Color(0xFF2E5BFF),
                          dotColor: Colors.black26,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed:
                          () => controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final Color color;
  final String urlImage;
  final String title;
  final String subtitle;
  final double imageSize;

  const OnboardingPage({
    super.key,
    required this.color,
    required this.urlImage,
    required this.title,
    required this.subtitle,
    this.imageSize = 150.0,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            urlImage,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E5BFF),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class AuthOptionsScreen extends StatelessWidget {
  const AuthOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(child: Image.asset('assets/veloxpay.png', height: 200)),
              const Text(
                'Welcome to VeloxPay',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E5BFF),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose how you want to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: Text(
                  'Sign Up with Email',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF2E5BFF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhoneSignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Sign Up with Phone Number',
                  style: TextStyle(fontSize: 16, color: Color(0xFF2E5BFF)),
                ),
              ),
              const SizedBox(height: 30),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    icon: Icons.g_mobiledata_rounded,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 24),
                  _buildSocialButton(icon: Icons.facebook, color: Colors.blue),
                  const SizedBox(width: 24),
                  _buildSocialButton(icon: Icons.apple, color: Colors.black),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Implement guest mode
                },
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: Colors.black54,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFF2E5BFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const SocialLoginButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(icon, height: 28, width: 28),
      ),
    );
  }
}

Widget _buildSocialButton({required IconData icon, required Color color}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 30),
  );
}

class PhoneSignUpScreen extends StatelessWidget {
  const PhoneSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sign Up with Phone',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            const Text(
              'We will send a verification code to this number',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5BFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Show OTP verification screen
              },
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
