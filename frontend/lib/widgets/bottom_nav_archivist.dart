import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/brutalist_theme.dart';

class BottomNavArchivist extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavArchivist({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: BrutalistColors.black, width: 3),
        ),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'DASHBOARD',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.edit_note_rounded,
            label: 'EDITOR',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.emoji_events_rounded,
            label: 'BATTLE',
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.inventory_2_rounded,
            label: 'ARCHIVE',
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'SETTINGS',
            isActive: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? BrutalistColors.primaryContainer : Colors.transparent,
            border: Border(
              right: const BorderSide(color: BrutalistColors.black, width: 1.5),
              bottom: BorderSide(
                color: isActive ? BrutalistColors.black : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: BrutalistColors.black,
                size: isActive ? 32 : 24,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    color: BrutalistColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
