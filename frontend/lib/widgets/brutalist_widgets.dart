import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/brutalist_theme.dart';

class ActionBlockButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;

  const ActionBlockButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = BrutalistColors.primary,
    this.icon,
  });

  @override
  State<ActionBlockButton> createState() => _ActionBlockButtonState();
}

class _ActionBlockButtonState extends State<ActionBlockButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        transform: Matrix4.translationValues(
          _isPressed ? 2.0 : 0.0,
          _isPressed ? 2.0 : 0.0,
          0.0,
        ),
        decoration: BrutalistTheme.getShadowDecoration(
          color: widget.color,
          offset: _isPressed ? 2.0 : BrutalistTheme.shadowOffset,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: BrutalistColors.black),
              const SizedBox(width: 8),
            ],
            Text(
              (widget.text ?? 'UNNAMED_ACTION').toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: BrutalistColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BentoCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color headerColor;
  final Color backgroundColor;
  final String? tag;
  final Color? tagColor;

  const BentoCard({
    super.key,
    required this.child,
    this.title,
    this.headerColor = BrutalistColors.primary,
    this.backgroundColor = Colors.white,
    this.tag,
    this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BrutalistTheme.getShadowDecoration(color: backgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: headerColor,
                border: const Border(
                  bottom: BorderSide(color: BrutalistColors.black, width: 4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                     child: Text(
                      (title ?? 'UNTITLED').toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: BrutalistColors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (tag != null)
                    IndustrialChip(text: tag ?? 'N/A', color: tagColor ?? Colors.white),
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class IndustrialInput extends StatelessWidget {
  final String label;
  final String? hint;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const IndustrialInput({
    super.key,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: BrutalistColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BrutalistTheme.getNakedDecoration(),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.bold,
              color: BrutalistColors.black,
            ),
            decoration: InputDecoration(
              hintText: hint?.toUpperCase(),
              hintStyle: GoogleFonts.spaceGrotesk(
                color: Colors.black26,
                fontWeight: FontWeight.bold,
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class IndustrialChip extends StatelessWidget {
  final String text;
  final Color color;

  const IndustrialChip({
    super.key,
    required this.text,
    this.color = BrutalistColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: BrutalistColors.black, width: 2),
      ),
      child: Text(
        (text ?? 'N/A').toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          color: BrutalistColors.black,
        ),
      ),
    );
  }
}
