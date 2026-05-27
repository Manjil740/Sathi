import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/saathi_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: user == null
            ? const Center(child: Text('No profile loaded'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SaathiBadge(
                    isVerified: user.isVerified,
                    label: user.name,
                    subLabel: user.phoneNumber,
                  ),
                  const SizedBox(height: 24),
                  _statCard('Rating', '${user.rating.toStringAsFixed(1)}/5'),
                  const SizedBox(height: 12),
                  _statCard('People helped', '${user.helpedCount}'),
                  const SizedBox(height: 12),
                  _statCard('Badge', user.isVerified ? 'Verified Saathi' : 'Pending verification'),
                ],
              ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
