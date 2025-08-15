import 'package:flutter/material.dart';

class PulsingStatusChip extends StatefulWidget {
  final String label;
  final Color baseColor;

  const PulsingStatusChip({
    super.key,
    required this.label,
    required this.baseColor,
  });

  @override
  State<PulsingStatusChip> createState() => _PulsingStatusChipState();
}

class _PulsingStatusChipState extends State<PulsingStatusChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Chip(
          label: Text(
            widget.label.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: widget.baseColor.withValues(
            alpha: _pulseAnimation.value,
          ),
        );
      },
    );
  }
}
