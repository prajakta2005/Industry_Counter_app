import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_theme.dart';
import 'setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
 
  final PageController _pageController = PageController();

  int _currentPage = 0;

  static const int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }
  Future<void> _goToSetup() async {
    await _markOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const SetupScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1F),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: const [
              _Slide1(),
              _Slide2(),
              _Slide3(),
              _Slide4(),
            ],
          ),

          
          if (_currentPage < 3)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: GestureDetector(
                onTap: _goToSetup,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMD,
                    vertical: AppTheme.spaceXS + 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: AppTheme.borderRadiusFull,
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

          
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: AppTheme.screenPadding,
            right: AppTheme.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                _DotIndicator(
                  total: _totalPages,
                  current: _currentPage,
                ),
                const SizedBox(height: AppTheme.spaceLG),

                
                _currentPage < 3
                    ? _NextButton(onTap: _nextPage)
                    : _GetStartedButton(onTap: _goToSetup),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _DotIndicator extends StatelessWidget {
  final int total;
  final int current;

  const _DotIndicator({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accent
                : Colors.white.withOpacity(0.2),
            borderRadius: AppTheme.borderRadiusFull,
          ),
        );
      }),
    );
  }
}


class _NextButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NextButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
          borderRadius: AppTheme.borderRadiusMD,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Next',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppTheme.accent,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GetStartedButton({required this.onTap});

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
        child: const Text(
          "Let's set me up  →",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0A0E1F),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scaleXY(begin: 0.95, end: 1, curve: Curves.easeOut);
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _Glow({
    required this.color,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        
      ),
    );
  }
}


class _SlideBase extends StatelessWidget {
  final Widget child;
  const _SlideBase({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.screenPadding,
          60, // top — space for skip button
          AppTheme.screenPadding,
          120, // bottom — space for dots + button
        ),
        child: child,
      ),
    );
  }
}


class _Slide1 extends StatelessWidget {
  const _Slide1();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background glows
        _Glow(
          color: AppTheme.accent.withOpacity(0.12),
          size: 200,
          top: -40,
          right: -40,
        ),
        _Glow(
          color: const Color(0xFF3B82F6).withOpacity(0.08),
          size: 150,
          bottom: 100,
          left: -40,
        ),

        _SlideBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.12),
                  borderRadius: AppTheme.borderRadiusMD,
                  border: Border.all(
                    color: AppTheme.accent.withOpacity(0.25),
                  ),
                ),
                child: const Icon(
                  Icons.radar_rounded,
                  color: AppTheme.accent,
                  size: 28,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scaleXY(begin: 0.8, end: 1, curve: Curves.easeOut),

              const Spacer(),

              // Slide number
              Text(
                '01 / 04',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: AppTheme.spaceSM),

              // Title
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  children: [
                    TextSpan(text: 'Count smarter,\nnot '),
                    TextSpan(
                      text: 'harder.',
                      style: TextStyle(color: AppTheme.accent),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

              const SizedBox(height: AppTheme.spaceMD),

              // Subtitle
              Text(
                'Built for solar plant field workers\nwho deal with hardware in the lakhs.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                  height: 1.6,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 350.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

              const SizedBox(height: AppTheme.spaceXL),
            ],
          ),
        ),
      ],
    );
  }
}

class _Slide2 extends StatelessWidget {
  const _Slide2();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Glow(
          color: const Color(0xFFEF4444).withOpacity(0.08),
          size: 180,
          top: 0,
          left: -40,
        ),
        _Glow(
          color: AppTheme.accent.withOpacity(0.1),
          size: 160,
          bottom: 80,
          right: -30,
        ),

        _SlideBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '02 / 04',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spaceSM),

              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(text: 'The '),
                    TextSpan(
                      text: 'problem\n',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                    TextSpan(text: 'we solve.'),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

              const SizedBox(height: AppTheme.spaceXL),

              // Problem card
              _InfoCard(
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBg: const Color(0xFFEF4444),
                text:
                    'Manually counting lakhs of nuts, bolts and washers is impossible and error-prone.',
                delay: 200.ms,
              ),

              const SizedBox(height: AppTheme.spaceMD),

              // Solution card
              _InfoCard(
                icon: Icons.check_circle_rounded,
                iconColor: AppTheme.accent,
                iconBg: AppTheme.accent,
                text:
                    'Point your camera. Get an accurate count in seconds. Log it instantly.',
                isAccent: true,
                delay: 350.ms,
              ),

              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}


class _Slide3 extends StatelessWidget {
  const _Slide3();

  static const _steps = [
    _Step(
      number: '1',
      title: 'Point camera',
      subtitle: 'At any pile of hardware items',
      color: AppTheme.accent,
    ),
    _Step(
      number: '2',
      title: 'AI counts instantly',
      subtitle: 'On-device — works offline',
      color: Color(0xFF60A5FA),
    ),
    _Step(
      number: '3',
      title: 'Log the details',
      subtitle: 'Lot no · material · issued to',
      color: Color(0xFFC084FC),
    ),
    _Step(
      number: '4',
      title: 'Export as Excel',
      subtitle: 'Share report with your manager',
      color: Color(0xFFFCD34D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Glow(
          color: AppTheme.accent.withOpacity(0.1),
          size: 200,
          top: -40,
          right: -40,
        ),

        _SlideBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '03 / 04',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spaceSM),

              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(text: 'How it\n'),
                    TextSpan(
                      text: 'works.',
                      style: TextStyle(color: AppTheme.accent),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

              const SizedBox(height: AppTheme.spaceXL),

              // Flow steps
              ...List.generate(_steps.length, (i) {
                return Column(
                  children: [
                    _FlowStep(step: _steps[i], delay: (200 + i * 100).ms),
                    if (i < _steps.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          width: 1,
                          height: 16,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                  ],
                );
              }),

              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Slide4 extends StatelessWidget {
  const _Slide4();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Glow(
          color: AppTheme.accent.withOpacity(0.15),
          size: 250,
          top: -60,
          right: -60,
        ),
        _Glow(
          color: const Color(0xFF3B82F6).withOpacity(0.1),
          size: 180,
          bottom: 80,
          left: -50,
        ),

        _SlideBase(
          child: Column(
            children: [
              const Spacer(),

              // Shield icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.accent.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppTheme.accent,
                  size: 40,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scaleXY(begin: 0.7, end: 1, curve: Curves.elasticOut),

              const SizedBox(height: AppTheme.spaceLG),

              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMD,
                  vertical: AppTheme.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  border: Border.all(
                    color: AppTheme.accent.withOpacity(0.2),
                  ),
                  borderRadius: AppTheme.borderRadiusFull,
                ),
                child: const Text(
                  "YOU'RE ALL SET",
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: AppTheme.spaceMD),

              // Title
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(text: 'Ready to start\n'),
                    TextSpan(
                      text: 'counting?',
                      style: TextStyle(color: AppTheme.accent),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

              const SizedBox(height: AppTheme.spaceMD),

              Text(
                'Takes 30 seconds to set up.\nWorks offline. Always.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                  height: 1.6,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms),

              const Spacer(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}


// Info card used in slide 2
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String text;
  final bool isAccent;
  final Duration delay;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.text,
    this.isAccent = false,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: isAccent
            ? AppTheme.accent.withOpacity(0.07)
            : Colors.white.withOpacity(0.04),
        border: Border.all(
          color: isAccent
              ? AppTheme.accent.withOpacity(0.2)
              : Colors.white.withOpacity(0.08),
        ),
        borderRadius: AppTheme.borderRadiusMD,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.12),
              borderRadius: AppTheme.borderRadiusSM,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(isAccent ? 0.8 : 0.55),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: delay)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}

// Step data model for slide 3
class _Step {
  final String number;
  final String title;
  final String subtitle;
  final Color color;
  const _Step({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

// Flow step widget for slide 3
class _FlowStep extends StatelessWidget {
  final _Step step;
  final Duration delay;

  const _FlowStep({required this.step, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: step.color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.number,
              style: TextStyle(
                color: step.color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceMD),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              step.subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}