import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'dashboard_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _siteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _siteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = UserModel(
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        site: _siteController.text.trim(),
      );
      await AuthService().saveUser(user);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.screenPadding,
              vertical: AppTheme.spaceLG,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spaceLG),

                  _TopBadge()
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: AppTheme.spaceXL),

                  Text(
                    'Hello,',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          height: 1.1,
                        ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            height: 1.1,
                          ),
                      children: const [
                        TextSpan(text: "let's get "),
                        TextSpan(
                          text: 'counting.',
                          style: TextStyle(color: AppTheme.accent),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: AppTheme.spaceSM),

                  Text(
  'Tell us who you are before\nwe head to the site.',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.textPrimary.withOpacity(0.85),
      ),
)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: AppTheme.spaceXXL),

                  _AnimatedField(
                    controller: _nameController,
                    label: 'YOUR NAME',
                    hint: 'e.g. Prajakta Joshi',
                    delay: 400.ms,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppTheme.spaceMD),

                  _AnimatedField(
                    controller: _roleController,
                    label: 'ROLE',
                    hint: 'e.g. Store Keeper',
                    delay: 500.ms,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your role';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppTheme.spaceMD),

                  _AnimatedField(
                    controller: _siteController,
                    label: 'SITE NAME',
                    hint: 'e.g. Pune Solar Plant 2',
                    delay: 600.ms,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSubmit(),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter the site name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppTheme.spaceXL),

                  _SubmitButton(
                    isLoading: _isLoading,
                    onTap: _handleSubmit,
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 700.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: AppTheme.spaceLG),

                  Center(
                    child: Text(
                      'Your info is saved only on this device',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceXS + 2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.12),
        borderRadius: AppTheme.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'NEXCOUNT HARDWARE COUNTER',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.accentDark,
                  letterSpacing: 0.8,
                ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Duration delay;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const _AnimatedField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.delay,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppTheme.spaceXS),
        TextFormField(
          controller: controller,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,

          // WHY: black text so it's readable on the white box
          style: const TextStyle(
            color: Color(0xFF1A1F36),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFB0B7C3),
              fontSize: 16,
            ),

            // WHY white fill: the input box should be white
            filled: true,
            fillColor: Colors.white,

            // WHY no underline — use OutlineInputBorder instead
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              borderSide: const BorderSide(
                color: Color(0xFFE2E4ED),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              borderSide: const BorderSide(
                color: Color(0xFFE2E4ED),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              borderSide: const BorderSide(
                color: AppTheme.accent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              borderSide: const BorderSide(
                color: AppTheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              borderSide: const BorderSide(
                color: AppTheme.error,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMD,
              vertical: AppTheme.spaceMD,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: delay)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Let's go",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(width: AppTheme.spaceSM),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}