import 'package:flutter/material.dart';

class SaathiBadge extends StatelessWidget {
  const SaathiBadge({
    super.key,
    required this.isVerified,
    required this.label,
    this.subLabel,
  });

  final bool isVerified;
  final String label;
  final String? subLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFE8F8F1) : const Color(0xFFF3F5F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isVerified ? const Color(0xFF15B67A) : Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.shield_outlined,
            color: isVerified ? const Color(0xFF15B67A) : Colors.black45,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (subLabel != null)
                Text(
                  subLabel!,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
