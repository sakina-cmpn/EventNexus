import 'package:flutter/material.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  late AnimationController _controller;
  late Animation<double> _borderAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _borderAnim = Tween<double>(begin: 1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        setState(() => _isFocused = focused);
        if (focused) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _borderAnim,
        builder: (_, __) {
          return TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  color: _isFocused
                      ? const Color(0xFF2563EB)
                      : Colors.grey[400],
                  size: 20,
                ),
              ),
              suffixIcon: widget.suffixIcon,
              labelStyle: TextStyle(
                color: _isFocused
                    ? const Color(0xFF2563EB)
                    : Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
              filled: true,
              fillColor: _isFocused
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFF8F9FA),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFD32F2F),
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFD32F2F),
                  width: 2.0,
                ),
              ),
              errorStyle: const TextStyle(fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}