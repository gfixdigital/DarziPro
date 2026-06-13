import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';

/// Login Screen — matches Stitch "Login / Signup" design
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _phoneController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: kError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // Dynamic Abstract Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kPrimaryDark, kPrimary],
                ),
              ),
              child: Stack(
                children: [
                  // Abstract circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Form Content floating over
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Header
                    Image.network(
                      'https://ik.imagekit.io/vveiuli91/Pictures/GFix%20digital%20Logo%20wth%20rectangle%20shape.png',
                      height: 80,
                      fit: BoxFit.contain,
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.content_cut, color: kPrimary, size: 40),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.headlineLgMobile.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.appTagline,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Floating Glass Card for Form
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              'Sign In',
                              style: AppTextStyles.headlineMd.copyWith(
                                color: kTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Phone field
                            AppInput(
                              label: AppStrings.phonePlaceholder,
                              hint: '3XX XXXXXXX',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              prefix: Text(
                                AppStrings.phonePrefix,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: kTextSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Phone number is required';
                                }
                                if (value.trim().length < 10) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password field
                            AppInput(
                              label: AppStrings.passwordPlaceholder,
                              hint: 'Enter your password',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: kTextSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Login button
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return AppButton(
                                  text: AppStrings.loginButton,
                                  onPressed: _handleLogin,
                                  isLoading: auth.isLoading,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Footer
                    Text(
                      AppStrings.appFooter,
                      style: AppTextStyles.labelSm.copyWith(
                        color: kTextSecondary.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Designed & Developed by GFix Digital',
                      style: AppTextStyles.labelSm.copyWith(
                        color: kPrimary.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
