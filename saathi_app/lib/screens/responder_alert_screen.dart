import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/emergency_provider.dart';
import '../widgets/live_location_map.dart';

class ResponderAlertScreen extends StatelessWidget {
  const ResponderAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emergency = context.watch<EmergencyProvider>();
    final current = emergency.currentEmergency;

    return Scaffold(
      appBar: AppBar(title: const Text('Responder Alert')),
      body: current == null
          ? const Center(child: Text('No emergency to respond to'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Saathi in Distress!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text('You are ${current.location.latitude.toStringAsFixed(4)}, ${current.location.longitude.toStringAsFixed(4)}'),
                const SizedBox(height: 16),
                LiveLocationMap(emergencyLocation: current.location, responders: emergency.responders),
                const SizedBox(height: 16),
                ...emergency.responders.map(
                  (assignment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(assignment.name),
                      subtitle: Text('${assignment.distanceMeters.round()}m away'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15B67A), foregroundColor: Colors.white),
                  onPressed: emergency.responders.isEmpty
                      ? null
                      : () async {
                          await context.read<EmergencyProvider>().assignResponder(emergency.responders.first.userId);
                          if (!context.mounted) return;
                          Navigator.of(context).pushReplacementNamed(AppRoutes.emergencyChat);
                        },
                  child: const Text("I'm Coming"),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dialing Nepal Police 100...')));
                  },
                  child: const Text('Call 100'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
    );
  }
}
