import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/brutalist_widgets.dart';
import '../../services/api_service.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrutalistColors.surface,
      body: Stack(
        children: [
          // Sidebar Decoration (Blueprint aesthetic)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 8,
            child: Opacity(
              opacity: 0.2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Container(decoration: const BoxDecoration(border: Border(left: BorderSide(color: BrutalistColors.black, width: 2))))),
                  Container(height: 48, width: 16, decoration: BoxDecoration(border: Border.all(color: BrutalistColors.black, width: 2))),
                  Expanded(child: Container(decoration: const BoxDecoration(border: Border(left: BorderSide(color: BrutalistColors.black, width: 2))))),
                ],
              ),
            ),
          ),
          
          // Technical Horizontal Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: BrutalistColors.surface,
                border: Border(bottom: BorderSide(color: BrutalistColors.black, width: 4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.terminal, color: BrutalistColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'PROMPT_CORE',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          letterSpacing: -1,
                          color: BrutalistColors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: BrutalistColors.primaryContainer,
                      border: Border.all(color: BrutalistColors.black, width: 2),
                    ),
                    child: Text(
                      'AUTH / REGISTER',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Join PromptLib Title
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BrutalistTheme.getShadowDecoration(
                          color: BrutalistColors.black,
                          offset: 8,
                        ),
                        child: Text(
                          'JOIN\nPROMPTLIB',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w900,
                            fontSize: 48,
                            height: 0.9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Registration Form Card
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BrutalistTheme.getShadowDecoration(color: Colors.white),
                            child: Column(
                              children: [
                                IndustrialInput(
                                  label: 'USERNAME',
                                  hint: 'CMD_USER_NAME',
                                  controller: _usernameController,
                                ),
                                const SizedBox(height: 32),
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
                                const SizedBox(height: 40),
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
                                        text: 'SIGN UP',
                                        isLarge: true,
                                        onPressed: _handleSignUp,
                                      ),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(top: 24),
                                  decoration: const BoxDecoration(
                                    border: Border(top: BorderSide(color: BrutalistColors.surfaceVariant, width: 2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ALREADY HAVE AN ACCOUNT?',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: BrutalistColors.outline,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ActionBlockButton(
                                        text: 'LOG IN',
                                        isCompact: true,
                                        color: BrutalistColors.surfaceVariant,
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (context) => const SignInScreen()),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Stable version tag
                          Positioned(
                            top: -16,
                            right: -16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: BrutalistColors.secondary,
                                border: Border.all(color: BrutalistColors.black, width: 2),
                              ),
                              child: Text(
                                'v2.0.4_STABLE',
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Technical Metadata Footer
                      Row(
                        children: [
                          Expanded(
                            child: _MetadataBox(label: 'ENCRYPTION', value: 'AES-256_ACTIVE'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _MetadataBox(label: 'REGION', value: 'US_NORTH_BLUE'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Side technical label
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: RotatedBox(
                quarterTurns: 1,
                child: Opacity(
                  opacity: 0.2,
                  child: Text(
                    'SYSTEM_INIT_PROCEDURE // AUTH_MODULE_REGISTER // 0x459F2',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('ALL FIELDS REQUIRED');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await ApiService().register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      _showError('REGISTRATION_FAILED: ${e.toString().toUpperCase()}');
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: BrutalistColors.surface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: BrutalistColors.black, width: 4),
        ),
        title: Text(
          'REGISTRATION_COMPLETE',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: BrutalistColors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: BrutalistColors.primary, size: 64),
            const SizedBox(height: 24),
            Text(
              'YOUR ACCOUNT HAS BEEN SUCCESSFULLY INITIALIZED IN THE CORE DATABASE.',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ActionBlockButton(
              text: 'PROCEED TO LOGIN',
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BrutalistTheme.getNakedDecoration(
        color: BrutalistColors.surfaceVariant.withOpacity(0.5),
        bWidth: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: BrutalistColors.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: BrutalistColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
