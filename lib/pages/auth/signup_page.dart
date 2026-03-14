import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_hero_section.dart';
import '../../widgets/animated_background.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _businessCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signUp(
      name: _nameCtrl.text.trim(),
      businessName: _businessCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Signup Success! Please Login."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Signup Failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account"), elevation: 0),
      body: SafeArea(
        child: AnimatedBackground(
          primaryColor: Theme.of(context).colorScheme.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth > 600;
              final EdgeInsets padding = EdgeInsets.symmetric(
                horizontal: wide ? constraints.maxWidth * 0.2 : 16,
                vertical: 16,
              );

              return SingleChildScrollView(
                padding: padding,
                child: Form(
                  key: _formKey,
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final isLoading = authProvider.isLoading;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthHeroSection(
                            title: 'Get Started',
                            subtitle:
                                'Join us to simplify your business management.',
                            type: 'signup',
                          ),
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Full Name',
                            prefixIcon: Icons.person_outline,
                            validator: (v) =>
                                v!.isEmpty ? "Name is required" : null,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _businessCtrl,
                            label: 'Business Name',
                            prefixIcon: Icons.business_outlined,
                            validator: (v) =>
                                v!.isEmpty ? "Business name is required" : null,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                v!.contains('@') ? null : "Enter valid email",
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _passwordCtrl,
                            label: 'Password',
                            obscureText: true,
                            prefixIcon: Icons.lock_outline,
                            validator: (v) =>
                                v!.length < 6 ? "Min 6 characters" : null,
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            label: isLoading
                                ? 'Creating account...'
                                : 'Register',
                            onPressed: isLoading ? null : _handleSignup,
                            icon: isLoading
                                ? Icons.hourglass_bottom
                                : Icons.person_add,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              ),
                              child: const Text(
                                "Already have an account? Login",
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
