import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav_archivist.dart';
import 'dashboard_screen.dart';
import 'prompt_editor_screen.dart';
import 'competition_screen.dart';
import 'archive_screen.dart';
import 'settings_screen.dart';
import '../theme/brutalist_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Keys to refresh DashboardScreen when posting
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();

  @override
  void initState() {
    super.initState();
    _loadSavedTab();
  }

  Future<void> _loadSavedTab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentIndex = prefs.getInt('currentTabIndex') ?? 0;
      });
    } catch (e) {
      debugPrint('Failed to load tab index: $e');
    }
  }

  Future<void> _saveTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentTabIndex', index);
  }

  void _switchToDashboard() {
    setState(() {
      _currentIndex = 0;
    });
    _saveTab(0);
    // Refresh dashboard prompts
    _dashboardKey.currentState?.refreshPrompts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrutalistColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardScreen(key: _dashboardKey),
            PromptEditorScreen(onPostSuccess: _switchToDashboard),
            const CompetitionScreen(),
            const ArchiveScreen(),
            const SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavArchivist(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _saveTab(index);
        },
      ),
    );
  }
}
