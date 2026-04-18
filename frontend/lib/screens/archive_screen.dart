import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/prompt_model.dart';
import '../services/api_service.dart';
import '../widgets/brutalist_widgets.dart';
import '../theme/brutalist_theme.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late Future<List<Prompt>> _archivedPromptsFuture;

  @override
  void initState() {
    super.initState();
    _refreshArchivedPrompts();
  }

  void _refreshArchivedPrompts() {
    setState(() {
      _archivedPromptsFuture = ApiService().getPrompts(archived: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header (Archive Vault Style)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory_2_rounded, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'ARCHIVE_VAULT',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      letterSpacing: -2,
                      fontStyle: FontStyle.italic,
                      color: BrutalistColors.black,
                    ),
                  ),
                ],
              ),
              const CircleAvatar(
                backgroundColor: BrutalistColors.primary,
                child: Icon(Icons.person, color: BrutalistColors.black),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BrutalistTheme.getShadowDecoration(color: Colors.white),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'FILTER_ARCHIVED_PROMPTS...',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  color: BrutalistColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'SEARCH',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Archive Content
        Expanded(
          child: FutureBuilder<List<Prompt>>(
            future: _archivedPromptsFuture,
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
                  return BentoCard(
                    title: prompt.title,
                    backgroundColor: Colors.white,
                    tag: prompt.aiModel.toUpperCase(),
                    tagColor: BrutalistColors.secondary,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ARCHIVED: 2024_APR_18',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  const IndustrialChip(text: '98% EFF', color: BrutalistColors.concrete),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                prompt.content,
                                style: GoogleFonts.jetBrainsMono(fontSize: 12),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: _ArchiveActionButton(
                                text: 'RESTORE',
                                icon: Icons.unarchive_rounded,
                                color: BrutalistColors.primary,
                                onPressed: () {
                                  if (prompt.id != null) _restorePrompt(prompt.id!);
                                },
                              ),
                            ),
                            Expanded(
                              child: _ArchiveActionButton(
                                text: 'DELETE',
                                icon: Icons.delete_forever_rounded,
                                color: BrutalistColors.tertiary,
                                onPressed: () {
                                  if (prompt.id != null) _deletePrompt(prompt.id!);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Opacity(opacity: 0.1, child: Icon(Icons.inventory_2_outlined, size: 80)),
          const SizedBox(height: 24),
          Text(
            'VAULT_IS_EMPTY',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restorePrompt(int id) async {
    final success = await ApiService().restorePrompt(id);
    if (success) {
      _refreshArchivedPrompts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PROMPT RESTORED TO TERMINAL')),
      );
    }
  }

  Future<void> _deletePrompt(int id) async {
    final success = await ApiService().deletePrompt(id);
    if (success) {
      _refreshArchivedPrompts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RECORDS PERMANENTLY PURGED')),
      );
    }
  }
}

class _ArchiveActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ArchiveActionButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          border: const Border(
            top: BorderSide(color: BrutalistColors.black, width: 4),
            right: BorderSide(color: BrutalistColors.black, width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: BrutalistColors.black),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
