import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      Navigator.of(context).pushReplacementNamed(
        authProvider.isAuthenticated ? AppRoutes.home : AppRoutes.login,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF09121F), Color(0xFF102A43), Color(0xFF15B67A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield, color: Colors.white, size: 68),
              SizedBox(height: 16),
              Text(
                'Saathi',
                style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'When you can\'t speak, your location speaks for you',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
