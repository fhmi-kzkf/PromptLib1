import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_widgets.dart';
import '../services/theme_service.dart';
import '../services/user_session.dart';
import 'auth/sign_in_screen.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              const Icon(Icons.settings_suggest_rounded, size: 40),
              const SizedBox(width: 16),
              Text(
                'SYSTEM_PREFS',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w900,
                  fontSize: 40,
                  letterSpacing: -2,
                  color: BrutalistColors.black,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              // User Profile Section
              BentoCard(
                title: 'OPERATOR_PROFILE',
                headerColor: BrutalistColors.secondary,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BrutalistTheme.getNakedDecoration(color: BrutalistColors.primary),
                        child: const Icon(Icons.person, size: 48),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (UserSession().username ?? 'UNKNOWN_USER').toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            IndustrialChip(
                              text: (UserSession().rank ?? 'JUNIOR ARCHIVIST').toUpperCase(),
                              color: BrutalistColors.primaryContainer,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              UserSession().email ?? 'No Network Identify',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Configuration
              BentoCard(
                title: 'AI_ENGINE_CONFIG',
                headerColor: BrutalistColors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _SettingsToggle(
                        label: 'HIGH_PRECISION_MODE',
                        value: true,
                        onChanged: (v) {},
                      ),
                      const Divider(color: Colors.black, thickness: 2),
                      _SettingsToggle(
                        label: 'AUTO_REFINE_PROMPTS',
                        value: false,
                        onChanged: (v) {},
                      ),
                      const SizedBox(height: 16),
                      const IndustrialInput(
                        label: 'DEFAULT_MODEL',
                        hint: 'GEMINI-2.5-FLASH',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // UI Preferences
              BentoCard(
                title: 'INTERFACE_STYLING',
                headerColor: BrutalistColors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACCENT_COLOR_OVERRIDE',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<Color>(
                        valueListenable: ThemeService().accentColor,
                        builder: (context, currentAccent, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ColorBox(
                                color: BrutalistColors.primary,
                                isActive: currentAccent == BrutalistColors.primary,
                              ),
                              _ColorBox(
                                color: BrutalistColors.secondary,
                                isActive: currentAccent == BrutalistColors.secondary,
                              ),
                              _ColorBox(
                                color: BrutalistColors.primaryContainer,
                                isActive: currentAccent == BrutalistColors.primaryContainer,
                              ),
                              _ColorBox(
                                color: Colors.black,
                                isActive: currentAccent == Colors.black,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ActionBlockButton(
                text: 'TERMINATE_SESSION (LOGOUT)',
                color: BrutalistColors.error,
                onPressed: () async {
                  await UserSession().clear();
                  if (!context.mounted) return;
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: BrutalistColors.black,
          activeTrackColor: BrutalistColors.secondary,
        ),
      ],
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final bool isActive;

  const _ColorBox({required this.color, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ThemeService().updateAccentColor(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: BrutalistColors.black,
            width: isActive ? 4 : 2,
          ),
        ),
        child: isActive ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
      ),
    );
  }
}

