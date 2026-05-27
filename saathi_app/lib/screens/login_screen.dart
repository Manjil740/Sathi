import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController(text: 'Aarav Shrestha');
  final _phoneController = TextEditingController(text: '+977 9800000000');
  final _otpController = TextEditingController(text: '1234');
  bool _otpSent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Welcome to Saathi',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text('Sign in to activate silent emergency support.'),
              const SizedBox(height: 28),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              if (_otpSent)
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(labelText: 'OTP', border: OutlineInputBorder()),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        if (!_otpSent) {
                          await authProvider.signIn(
                            phoneNumber: _phoneController.text.trim(),
                            name: _nameController.text.trim(),
                          );
                          setState(() => _otpSent = true);
                        } else {
                          await authProvider.verifyOtp(_otpController.text.trim());
                          if (!context.mounted) return;
                          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                        }
                      },
                child: Text(authProvider.isLoading ? 'Please wait...' : _otpSent ? 'Verify OTP' : 'Send OTP'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
                child: const Text('Skip demo login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
