import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/brutalist_theme.dart';

class ActionBlockButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final IconData? icon;
   final bool isLarge;
   final bool isCompact;
 
   const ActionBlockButton({
     super.key,
     required this.text,
     required this.onPressed,
     this.color,
     this.icon,
     this.isLarge = false,
     this.isCompact = false,
   });

  @override
  State<ActionBlockButton> createState() => _ActionBlockButtonState();
}

class _ActionBlockButtonState extends State<ActionBlockButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? Theme.of(context).primaryColor;
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
          color: effectiveColor,
          offset: _isPressed ? 2.0 : BrutalistTheme.shadowOffsetSm,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isLarge ? 32 : (widget.isCompact ? 12 : 24),
          vertical: widget.isLarge ? 18 : (widget.isCompact ? 8 : 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: BrutalistColors.black, size: widget.isLarge ? 28 : 20),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                widget.text.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w900,
                  fontSize: widget.isLarge ? 20 : (widget.isCompact ? 12 : 16),
                  color: BrutalistColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
  final Color? headerColor;
  final Color backgroundColor;
  final String? tag;
  final Color? tagColor;
  final String? imageUrl;
  final Widget? footer;
  final EdgeInsets? contentPadding;

  const BentoCard({
    super.key,
    required this.child,
    this.title,
    this.headerColor,
    this.backgroundColor = Colors.white,
    this.tag,
    this.tagColor,
    this.imageUrl,
    this.footer,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeaderColor = headerColor ?? Theme.of(context).primaryColor;
    return Container(
      decoration: BrutalistTheme.getShadowDecoration(color: backgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl != null)
            Container(
              height: 180,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: BrutalistColors.black, width: 3),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: BrutalistColors.surfaceVariant,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.black26, size: 48),
                      ),
                    ),
                  ),
                  if (tag != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: IndustrialChip(text: tag!, color: BrutalistColors.black, textColor: Colors.white),
                    ),
                ],
              ),
            ),
          if (title != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: effectiveHeaderColor,
                border: Border(
                  bottom: BorderSide(
                    color: BrutalistColors.black,
                    width: imageUrl != null ? 0 : 3,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title!.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: BrutalistColors.black,
                        height: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (tag != null && imageUrl == null)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: IndustrialChip(text: tag!, color: Colors.black, textColor: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: contentPadding ?? const EdgeInsets.all(0),
            child: child,
          ),
          if (footer != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: BrutalistColors.black, width: 2),
                ),
              ),
              child: footer!,
            ),
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
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool readOnly;

  const IndustrialInput({
    super.key,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label placed clearly above the input box
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: BrutalistColors.primaryContainer,
              border: Border.all(color: BrutalistColors.black, width: 2),
            ),
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1,
                color: BrutalistColors.black,
              ),
            ),
          ),
        ),
        // Input Box
        Container(
          decoration: BrutalistTheme.getShadowDecoration(
            color: readOnly ? BrutalistColors.background : Colors.white,
            offset: 4.0,
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            onChanged: onChanged,
            maxLines: maxLines,
            readOnly: readOnly,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              color: BrutalistColors.black,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint?.toUpperCase(),
              hintStyle: GoogleFonts.spaceGrotesk(
                color: BrutalistColors.outlineVariant,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              border: InputBorder.none,
              filled: true,
              fillColor: readOnly ? BrutalistColors.background : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class IndustrialChip extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;

  const IndustrialChip({
    super.key,
    required this.text,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor,
        border: Border.all(color: BrutalistColors.black, width: 2),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          color: textColor ?? BrutalistColors.black,
        ),
      ),
    );
  }
}

