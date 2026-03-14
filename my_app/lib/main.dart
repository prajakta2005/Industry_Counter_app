import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'utils/app_theme.dart';
import 'screens/login_screen.dart';
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

  runApp(const SolarCounterApp());
}


class SolarCounterApp extends StatelessWidget {
  const SolarCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      
      providers: const [
        
      ],
      child: MaterialApp(
       
        title: 'Solar Hardware Counter',
        debugShowCheckedModeBanner: false,

        theme:      AppTheme.lightTheme,
        darkTheme:  AppTheme.darkTheme,
        themeMode:  ThemeMode.system,


        initialRoute: AppRoutes.login,

        routes: {
          AppRoutes.login:     (_) => LoginScreen(),
          AppRoutes.dashboard: (_) => DashboardScreen(),
          AppRoutes.counter:   (_) => CounterScreen(),
          AppRoutes.logForm:   (_) => LogFormScreen(),
          AppRoutes.reports:   (_) => ReportsScreen(),
        },

        // WHY onUnknownRoute:
        // If somehow the app navigates to a route that doesn't exist,
        // instead of crashing we send the user back to the login screen.
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => LoginScreen(),
        ),
      ),
    );
  }
}
class AppRoutes {
  AppRoutes._(); 

  static const String login     = '/';
  static const String dashboard = '/dashboard';
  static const String counter   = '/counter';
  static const String logForm   = '/log-form';
  static const String reports   = '/reports';
}