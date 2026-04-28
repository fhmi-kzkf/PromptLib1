import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/brutalist_widgets.dart';
import '../../services/api_service.dart';
import '../../services/user_session.dart';
import '../main_shell.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('EMAIL AND PASSWORD REQUIRED');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService().login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      
      // Save user session
      UserSession().setUser(res['data']);
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainShell()),
      );
    } catch (e) {
      _showError('LOGIN_FAILED: ${e.toString().toUpperCase()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
        ),
        backgroundColor: BrutalistColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: Border.all(color: BrutalistColors.black, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrutalistColors.background,
      body: Stack(
        children: [
          // Background Texture simulation
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _PatternPainter()),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Auth Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BrutalistTheme.getNakedDecoration(
                          color: BrutalistColors.surfaceVariant,
                          bWidth: 2,
                        ),
                        child: Text(
                          'AUTH / SIGN IN',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Welcome Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BrutalistTheme.getShadowDecoration(
                          color: BrutalistColors.primaryContainer,
                        ),
                        child: Text(
                          'WELCOME TO\nPROMPTLIB',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w900,
                            fontSize: 40,
                            height: 0.9,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form Box
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BrutalistTheme.getShadowDecoration(color: Colors.white),
                        child: Column(
                          children: [
                            IndustrialInput(
                              label: 'EMAIL',
                              hint: 'USER@PROMPTLIB.IO',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 32),
                            IndustrialInput(
                              label: 'PASSWORD',
                              hint: '••••••••',
                              isPassword: true,
                              controller: _passwordController,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: _isLoading
                                ? Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BrutalistTheme.getNakedDecoration(color: BrutalistColors.primaryContainer),
                                      child: const CircularProgressIndicator(color: BrutalistColors.black, strokeWidth: 4),
                                    ),
                                  )
                                : ActionBlockButton(
                                    text: 'LOGIN',
                                    icon: Icons.arrow_forward,
                                    isLarge: true,
                                    onPressed: _handleLogin,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'FORGOT PASSWORD?',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: BrutalistColors.black,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                    );
                                  },
                                  child: Text(
                                    'NEW HERE? REGISTER',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: BrutalistColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Footer Boxes
                      Row(
                        children: [
                          Expanded(
                            child: _TechnicalInfoBox(
                              icon: Icons.terminal,
                              title: 'TECHNICAL\nCORE V2.4',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _TechnicalInfoBox(
                              icon: Icons.security,
                              title: 'ENCRYPTED\nSTORAGE',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicalInfoBox extends StatelessWidget {
  final IconData icon;
  final String title;

  const _TechnicalInfoBox({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BrutalistTheme.getNakedDecoration(
        color: BrutalistColors.surfaceVariant,
        bWidth: 2,
      ),
      child: Row(
        children: [
          Icon(icon, color: BrutalistColors.secondary, size: 24),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w900,
              fontSize: 10,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
