import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/app_theme.dart';
import 'services/auth_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/counter_screen.dart';
import 'screens/log_form_screen.dart';
import 'screens/reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Animate.restartOnHotReload = true;

  // WHY check both flags:
  // onboarding_seen → has user seen the 4 intro slides?
  // isUserSetup     → has user entered their name/role/site?
  // Three possible states:
  //   1. Brand new user    → show Onboarding
  //   2. Saw onboarding    → show Setup (hasn't filled details yet)
  //   3. Fully set up      → show WelcomeBack
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
  final bool isSetup = await AuthService().isUserSetup();

  Widget homeScreen;
  if (!onboardingSeen) {
    homeScreen = const OnboardingScreen();
  } else if (!isSetup) {
    homeScreen = const SetupScreen();
  } else {
    homeScreen = const WelcomeScreen();
  }

  runApp(SolarCounterApp(home: homeScreen));
}

class SolarCounterApp extends StatelessWidget {
  final Widget home;
  const SolarCounterApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar Hardware Counter',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: home,
      routes: {
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.setup:      (_) => const SetupScreen(),
        AppRoutes.welcome:    (_) => const WelcomeScreen(),
        AppRoutes.dashboard:  (_) => const DashboardScreen(),
        AppRoutes.counter:    (_) => const CounterScreen(),
        AppRoutes.logForm:    (_) => const LogFormScreen(),
        AppRoutes.reports:    (_) => const ReportsScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AppRoutes — single source of truth for all
//  named route strings. No duplicates.
// ─────────────────────────────────────────────
class AppRoutes {
  AppRoutes._(); // private constructor — never instantiate this

  static const String onboarding = '/onboarding';
  static const String setup      = '/setup';
  static const String welcome    = '/welcome';
  static const String dashboard  = '/dashboard';
  static const String counter    = '/counter';
  static const String logForm    = '/log-form';
  static const String reports    = '/reports';
}