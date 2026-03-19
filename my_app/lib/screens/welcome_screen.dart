import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'dashboard_screen.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
 
  late final Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();
   
    _userFuture = AuthService().getUser();
  }

  void _goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const DashboardScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1F),
      body: FutureBuilder<UserModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accent,
                strokeWidth: 2,
              ),
            );
          }

          final user = snapshot.data!;

          return Stack(
            children: [
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accent.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: -80,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3B82F6).withOpacity(0.06),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.screenPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 2),

                      // Greeting label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceMD,
                          vertical: AppTheme.spaceXS + 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: AppTheme.borderRadiusFull,
                          border: Border.all(
                            color: AppTheme.accent.withOpacity(0.2),
                          ),
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
                              'WELCOME BACK',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.accent,
                                    letterSpacing: 1,
                                  ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                      const SizedBox(height: AppTheme.spaceXL),

                      // Name
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 150.ms)
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                      const SizedBox(height: AppTheme.spaceSM),

                      // Role + site
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 16,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: user.role),
                            TextSpan(
                              text: '  ·  ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            TextSpan(text: user.site),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 250.ms)
                          .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                      const Spacer(flex: 3),

                      _StatsRow()
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 400.ms)
                          .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                      const SizedBox(height: AppTheme.spaceXXL),

                      // Go to work button
                      _GoButton(onTap: _goToDashboard)
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 550.ms)
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                      const SizedBox(height: AppTheme.spaceMD),

                      // Reset option
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            await AuthService().clearUser();
                            if (!mounted) return;
                            Navigator.of(context).pushReplacementNamed('/setup');
                          },
                          child: Text(
                            'Not you? Reset',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.25),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 700.ms),

                      const SizedBox(height: AppTheme.spaceXL),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: "Today's counts", value: '—'),
        const SizedBox(width: AppTheme.spaceSM),
        _StatCard(label: 'Total logs', value: '—'),
        const SizedBox(width: AppTheme.spaceSM),
        _StatCard(label: 'Status', value: 'Online', isAccent: true),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isAccent;

  const _StatCard({
    required this.label,
    required this.value,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceMD,
          vertical: AppTheme.spaceMD,
        ),
        decoration: BoxDecoration(
          color: isAccent
              ? AppTheme.accent.withOpacity(0.1)
              : Colors.white.withOpacity(0.04),
          borderRadius: AppTheme.borderRadiusMD,
          border: Border.all(
            color: isAccent
                ? AppTheme.accent.withOpacity(0.2)
                : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: isAccent ? AppTheme.accent : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _GoButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: AppTheme.borderRadiusMD,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Let's go to work",
              style: TextStyle(
                color: Color(0xFF0A0E1F),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppTheme.spaceSM),
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF0A0E1F),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.accent,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}