import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/prompt_model.dart';
import '../services/api_service.dart';
import '../widgets/brutalist_widgets.dart';
import '../theme/brutalist_theme.dart';
import 'prompt_editor_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Prompt>> _promptsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPrompts();
  }

  void _refreshPrompts() {
    setState(() {
      _promptsFuture = ApiService().getPrompts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header (Terminal Style)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IndustrialChip(
                      text: 'SYSTEM STATUS: OPERATIONAL',
                      color: BrutalistColors.secondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ARCHIVE',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 64,
                        letterSpacing: -4,
                        height: 0.9,
                        color: BrutalistColors.black,
                      ),
                    ),
                    Text(
                      'TERMINAL',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 64,
                        letterSpacing: -4,
                        height: 0.9,
                        color: BrutalistColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BrutalistTheme.getShadowDecoration(color: Colors.white),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.search, size: 32),
              ),
            ],
          ),
        ),

        // Prompts Content
        Expanded(
          child: FutureBuilder<List<Prompt>>(
            future: _promptsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final prompts = snapshot.data ?? [];
              if (prompts.isEmpty) {
                return _buildEmptyState();
              }

              return MasonryGridView.count(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                itemCount: prompts.length,
                itemBuilder: (context, index) {
                  final prompt = prompts[index];
                  // Make the first card large if it's the latest
                  bool isLarge = index == 0;
                  
                  return GestureDetector(
                    onTap: () => _navigateToEditor(prompt: prompt),
                    child: BentoCard(
                      title: prompt.title,
                      headerColor: _getHeaderColor(index),
                      tag: prompt.category,
                      tagColor: Colors.white,
                      backgroundColor: isLarge ? Colors.white : BrutalistColors.background,
                      child: Container(
                        height: isLarge ? 200 : 120,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                prompt.content,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                                maxLines: isLarge ? 8 : 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IndustrialChip(
                                  text: prompt.aiModel.replaceAll('gemini-', ''),
                                  color: BrutalistColors.concrete,
                                ),
                                const Icon(Icons.copy, size: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getHeaderColor(int index) {
    final colors = [
      BrutalistColors.primary,
      BrutalistColors.secondary,
      BrutalistColors.tertiary,
    ];
    return colors[index % colors.length];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Opacity(opacity: 0.1, child: Icon(Icons.inventory_2_outlined, size: 100)),
          const SizedBox(height: 24),
          Text(
            'NO RECORDS FOUND',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 12),
          ActionBlockButton(
            text: 'INITIALIZE FIRST RECORD',
            onPressed: () => _navigateToEditor(),
          ),
        ],
      ),
    );
  }

  void _navigateToEditor({Prompt? prompt}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PromptEditorScreen(prompt: prompt),
      ),
    );
    if (result == true) {
      _refreshPrompts();
    }
  }
}
