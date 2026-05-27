import 'package:flutter/material.dart';

import '../models/responder.dart';

class ResponderRoleCard extends StatelessWidget {
  const ResponderRoleCard({
    super.key,
    required this.assignment,
    required this.roleText,
  });

  final ResponderAssignment assignment;
  final String roleText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: assignment.isComing ? const Color(0xFF15B67A) : Colors.black12),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: assignment.isComing ? const Color(0xFF15B67A) : const Color(0xFFF3F5F8),
            child: Icon(
              assignment.isComing ? Icons.check : Icons.person,
              color: assignment.isComing ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignment.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(roleText),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${assignment.distanceMeters.round()}m'),
              Text(
                assignment.isComing ? 'On the way' : 'Nearby',
                style: TextStyle(
                  color: assignment.isComing ? const Color(0xFF15B67A) : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
