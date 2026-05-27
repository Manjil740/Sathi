import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/constants.dart';

class DistressButton extends StatefulWidget {
  const DistressButton({
    super.key,
    required this.onPressed,
    required this.onLongPress,
  });

  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  @override
  State<DistressButton> createState() => _DistressButtonState();
}

class _DistressButtonState extends State<DistressButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      onLongPress: () {
        HapticFeedback.lightImpact();
        widget.onLongPress();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 + (_controller.value * 0.08);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          width: AppConstants.distressButtonSize,
          height: AppConstants.distressButtonSize,
          decoration: BoxDecoration(
            color: AppConstants.emergencyRed,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppConstants.emergencyRed.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sos, color: Colors.white, size: 42),
              SizedBox(height: 4),
              Text(
                'SOS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
