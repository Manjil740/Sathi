import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/constants.dart';
import 'config/firebase_options.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/emergency_provider.dart';
import 'providers/location_provider.dart';
import 'screens/distress_screen.dart';
import 'screens/emergency_chat_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/responder_alert_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/service_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // Demo mode works without Firebase project configuration.
  }
  final registry = ServiceRegistry();
  runApp(SaathiApp(registry: registry));
}

class SaathiApp extends StatelessWidget {
  const SaathiApp({super.key, required this.registry});

  final ServiceRegistry registry;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(registry.authService)),
        ChangeNotifierProvider(create: (_) => LocationProvider(registry.locationService)),
        ChangeNotifierProvider(create: (_) => EmergencyProvider(registry.emergencyService, registry.chatService)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.deepNavy,
            primary: AppConstants.deepNavy,
            secondary: AppConstants.accent,
            error: AppConstants.emergencyRed,
          ),
          scaffoldBackgroundColor: AppConstants.surface,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.distress: (_) => const DistressScreen(),
          AppRoutes.responderAlert: (_) => const ResponderAlertScreen(),
          AppRoutes.emergencyChat: (_) => const EmergencyChatScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
          AppRoutes.settings: (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
