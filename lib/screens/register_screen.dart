import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/animated_text_field.dart';
import '../widgets/gradient_button.dart';
import 'student/main_screen.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _checkController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _headerSlide;
  late Animation<Offset> _formSlide;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _slideController, curve: Curves.easeOutCubic),
        );
    _formSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _slideController, curve: Curves.easeOutCubic),
        );
    _checkScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _checkController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length >= 6) strength += 0.2;
    if (password.length >= 10) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')))
      strength += 0.2;
    return strength;
  }

  Color _strengthColor(double strength) {
    if (strength <= 0.2) return Colors.red;
    if (strength <= 0.4) return Colors.orange;
    if (strength <= 0.6) return Colors.yellow[700]!;
    if (strength <= 0.8) return const Color(0xFF2563EB);
    return const Color(0xFF1a1a2e);
  }

  String _strengthLabel(double strength) {
    if (strength <= 0.2) return 'Weak';
    if (strength <= 0.4) return 'Fair';
    if (strength <= 0.6) return 'Good';
    if (strength <= 0.8) return 'Strong';
    return 'Very Strong';
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showError('Please agree to the Terms & Conditions');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.registerWithEmailAndPassword(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        _showSuccess();
        await Future.delayed(const Duration(milliseconds: 1500));
        if (_authService.isSignedIn) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const MainScreen(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 500),
            ),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => EmailVerificationScreen(
                  email: _emailController.text.trim()),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 450),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
                child:
                    Text(message, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
                child: Text('Account created! Check your email to verify.',
                    style: TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passwordStrength =
        _getPasswordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Background accent
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1a1a2e),
                      Color(0xFF2563EB),
                      Color(0xFF1a1a2e),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),

            // Decorative elements
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header
                    SlideTransition(
                      position: _headerSlide,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Join EventNexus today',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.event_rounded,
                                color: Color(0xFF2563EB),
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Form Card
                    SlideTransition(
                      position: _formSlide,
                      child: Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB)
                                  .withOpacity(0.1),
                              blurRadius: 40,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              AnimatedTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                hint: 'John Doe',
                                icon: Icons.person_outline_rounded,
                                keyboardType: TextInputType.name,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Name is required';
                                  if (v.trim().length < 2)
                                    return 'Enter your full name';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              AnimatedTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                hint: 'you@example.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Email is required';
                                  if (!RegExp(
                                          r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$')
                                      .hasMatch(v))
                                    return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              AnimatedTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                onChanged: (_) => setState(() {}),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() =>
                                      _obscurePassword =
                                          !_obscurePassword),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF2563EB),
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Password is required';
                                  if (v.length < 6)
                                    return 'Minimum 6 characters';
                                  return null;
                                },
                              ),

                              if (_passwordController
                                  .text.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: passwordStrength,
                                          backgroundColor:
                                              Colors.grey[200],
                                          color: _strengthColor(
                                              passwordStrength),
                                          minHeight: 5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _strengthLabel(passwordStrength),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _strengthColor(
                                            passwordStrength),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),

                              AnimatedTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscureConfirm,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() =>
                                      _obscureConfirm = !_obscureConfirm),
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF2563EB),
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Please confirm your password';
                                  if (v != _passwordController.text)
                                    return 'Passwords do not match';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Terms checkbox
                              Row(
                                children: [
                                  AnimatedBuilder(
                                    animation: _checkController,
                                    builder: (_, __) => Transform.scale(
                                      scale: _agreeToTerms
                                          ? _checkScale.value
                                          : 1.0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _agreeToTerms =
                                              !_agreeToTerms);
                                          if (_agreeToTerms) {
                                            _checkController.forward(
                                                from: 0);
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: _agreeToTerms
                                                ? const Color(0xFF2563EB)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: _agreeToTerms
                                                  ? const Color(0xFF2563EB)
                                                  : Colors.grey[400]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: _agreeToTerms
                                              ? const Icon(Icons.check,
                                                  color: Colors.white,
                                                  size: 14)
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                        children: const [
                                          TextSpan(
                                              text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Terms & Conditions',
                                            style: TextStyle(
                                              color: Color(0xFF2563EB),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              color: Color(0xFF2563EB),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26),

                              GradientButton(
                                text: 'Create Account',
                                isLoading: _isLoading,
                                onPressed: _register,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
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
