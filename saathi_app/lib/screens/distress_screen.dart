import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/emergency_provider.dart';
import '../widgets/live_location_map.dart';
import '../widgets/responder_role_card.dart';

class DistressScreen extends StatelessWidget {
  const DistressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emergency = context.watch<EmergencyProvider>();
    final current = emergency.currentEmergency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Active'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.emergencyChat),
            child: const Text('Open Chat'),
          ),
        ],
      ),
      body: current == null
          ? const Center(child: Text('No active emergency'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFA7A7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saathi in distress!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text('Danger level ${current.dangerLevel}/5'),
                      Text('Emergency code ${current.id.split('_').last}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LiveLocationMap(emergencyLocation: current.location, responders: emergency.responders),
                const SizedBox(height: 16),
                Text(
                  'Auto coordination timer: ${emergency.remaining.inMinutes.toString().padLeft(2, '0')}:${(emergency.remaining.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...emergency.responders.map(
                  (assignment) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ResponderRoleCard(
                      assignment: assignment,
                      roleText: emergency.roleLabel(assignment.role),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.emergencyChat),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Continue to live chat'),
                ),
              ],
            ),
    );
  }
}
