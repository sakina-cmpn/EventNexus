import 'dart:async';
import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final FutureOr<void> Function() onPressed;

  const GradientButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runOnPressed() async {
    if (widget.isLoading || _isExecuting) return;
    setState(() => _isExecuting = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _isExecuting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = widget.isLoading || _isExecuting;
    return GestureDetector(
      onTapDown: (_) {
        if (!isBusy) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) async {
        setState(() => _isPressed = false);
        _controller.reverse();
        await _runOnPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, __) => Transform.scale(
          scale: _scaleAnim.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: isBusy
                    ? [const Color(0xFFD1C4E9), const Color(0xFFB39DDB)]
                    : [const Color(0xFF2D136F), const Color(0xFF4A148C)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isPressed || isBusy
                  ? []
                  : [
                BoxShadow(
                  color: const Color(0xFF311B92).withOpacity(0.40),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: isBusy
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
