import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/brutalist_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrutalistColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              const Icon(Icons.terminal_rounded, size: 64, color: BrutalistColors.black),
              const SizedBox(height: 8),
              Text(
                'PROMPTLIB',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                  letterSpacing: -2,
                  color: BrutalistColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: BrutalistColors.secondary,
                  border: Border.all(color: BrutalistColors.black, width: 2),
                ),
                child: Text(
                  'SYSTEM IDENTITY VERIFIED: V.4.0.2_INDUSTRIAL',
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: BrutalistColors.black,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Auth Card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative background block
                  Positioned(
                    top: 10,
                    left: 10,
                    right: -10,
                    bottom: -10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: BrutalistColors.secondary,
                        border: Border.all(color: BrutalistColors.black, width: 4),
                      ),
                    ),
                  ),
                  // Main card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BrutalistTheme.getShadowDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INITIALIZE SESSION',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: BrutalistColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 6,
                          color: BrutalistColors.primary,
                        ),
                        const SizedBox(height: 32),
                        IndustrialInput(
                          label: 'ARCHIVE_ID (EMAIL)',
                          hint: 'OPERATOR@PROMPTLIB.IO',
                          controller: _emailController,
                        ),
                        const SizedBox(height: 24),
                        IndustrialInput(
                          label: 'ACCESS_KEY (PASSWORD)',
                          hint: '••••••••••••',
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ActionBlockButton(
                            text: 'SIGN IN',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () {
                              // Auth logic will go here
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Container(height: 2, color: BrutalistColors.black)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'MANUAL OVERRIDE',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: BrutalistColors.black.withOpacity(0.6),
                                ),
                              ),
                            ),
                            Expanded(child: Container(height: 2, color: BrutalistColors.black)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _AuthSmallButton(
                                text: 'HELP',
                                icon: Icons.help_outline_rounded,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _AuthSmallButton(
                                text: 'REGISTER',
                                icon: Icons.person_add_outlined,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetadataColumn(
                    lines: const [
                      '[STATUS: PENDING_AUTH]',
                      '[ENC: AES_256_GCM]',
                      '[LOC: NODE_882_ALPHA]',
                    ],
                  ),
                  _MetadataColumn(
                    alignRight: true,
                    lines: const [
                      'INDUSTRIAL ARCHIVE V4.0',
                      'AUTHORIZED ACCESS ONLY',
                      '© 2024 PROMPTLIB',
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthSmallButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _AuthSmallButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: BrutalistColors.background,
          border: Border.all(color: BrutalistColors.black, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: BrutalistColors.black),
            const SizedBox(width: 8),
            Text(
              text.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: BrutalistColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataColumn extends StatelessWidget {
  final List<String> lines;
  final bool alignRight;

  const _MetadataColumn({required this.lines, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: lines.map((line) => Text(
        line,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: BrutalistColors.black.withOpacity(0.4),
        ),
      )).toList(),
    );
  }
}
