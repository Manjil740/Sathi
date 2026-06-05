import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_contact_provider.dart';
import '../providers/emergency_provider.dart';
import '../providers/location_provider.dart';
import '../utils/notification_helper.dart';
import '../widgets/distress_button.dart';
import '../widgets/saathi_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _cancelTimer;
  int _countdown = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().refreshLocation();
    });
  }

  @override
  void dispose() {
    _cancelTimer?.cancel();
    super.dispose();
  }

  Future<void> _startEmergency() async {
    final auth = context.read<AuthProvider>();
    final emergencyProvider = context.read<EmergencyProvider>();
    final victim = auth.user;
    if (victim == null) {
      NotificationHelper.showSnackBar(context, 'Sign in to send a distress alert.');
      return;
    }
    await emergencyProvider.startEmergency(dangerLevel: '4', victim: victim);
    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.distress);
  }

  Future<void> _handleSilentPress() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      NotificationHelper.showSnackBar(context, 'Sign in first to use silent help.');
      return;
    }
    await context.read<EmergencyProvider>().registerSilentPress(victim: user);
    if (!mounted) return;
    NotificationHelper.showSnackBar(context, context.read<EmergencyProvider>().panicStatus);
    if (context.read<EmergencyProvider>().hasActiveEmergency) {
      Navigator.of(context).pushNamed(AppRoutes.distress);
    }
  }

  void _showCancelDialog() {
    if (!context.read<EmergencyProvider>().hasActiveEmergency) {
      NotificationHelper.showSnackBar(context, 'No active emergency to cancel.');
      return;
    }

    _countdown = 5;
    var timerStarted = false;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (!timerStarted) {
              timerStarted = true;
              _cancelTimer?.cancel();
              _cancelTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
                if (_countdown == 0) {
                  timer.cancel();
                  await context.read<EmergencyProvider>().cancelEmergency();
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  return;
                }
                setDialogState(() => _countdown -= 1);
              });
            }

            return AlertDialog(
              title: const Text('Cancel emergency?'),
              content: Text('Emergency will be cancelled in $_countdown seconds.'),
              actions: [
                TextButton(
                  onPressed: () {
                    _cancelTimer?.cancel();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Keep active'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _cancelTimer?.cancel();
                    await context.read<EmergencyProvider>().cancelEmergency();
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Cancel now'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final location = context.watch<LocationProvider>();
    final emergency = context.watch<EmergencyProvider>();
    final contacts = context.watch<EmergencyContactProvider>().contacts;
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saathi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SaathiBadge(
                  isVerified: user?.isVerified ?? false,
                  label: user?.name ?? 'Guest user',
                  subLabel: user == null ? 'Demo mode' : 'Verified Saathi',
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(location.currentLocation == null ? 'Locating...' : 'Online'),
                    const SizedBox(height: 4),
                    const Text('Ready to assist', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: DistressButton(
                onPressed: () async {
                  if (emergency.hasActiveEmergency) {
                    _showCancelDialog();
                    return;
                  }
                  await _startEmergency();
                },
                onLongPress: _showCancelDialog,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _handleSilentPress,
                onLongPress: _showCancelDialog,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 360),
                  height: AppConstants.silentTriggerCardHeight,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF09121F), Color(0xFF132B44)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 14))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.power_settings_new, color: Colors.white, size: 40),
                      const SizedBox(height: 14),
                      const Text(
                        'Silent Power Trigger',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap once to arm (vibration).\nThen tap once for police + contacts, twice for ambulance + nearby responders.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.82), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              emergency.hasActiveEmergency
                  ? 'Emergency active'
                  : 'Tap the red button to send distress or use silent power trigger.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF15B67A), size: 12),
                      SizedBox(width: 8),
                      Text('You\'re active in Saathi Network'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Emergency contacts'),
                  const SizedBox(height: 8),
                  if (contacts.isEmpty)
                    const Text('No emergency contacts yet. Add them in Settings.'),
                  ...contacts.map(
                    (contact) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.contact_phone),
                      title: Text(contact['name'] ?? ''),
                      subtitle: Text(contact['phone'] ?? ''),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (emergency.currentEmergency != null)
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text('Emergency #${emergency.currentEmergency!.id.split('_').last}'),
                subtitle: Text('Status: ${emergency.currentEmergency!.status.name}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.distress),
              ),
          ],
        ),
      ),
    );
  }
}
