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
  late Future<List<Prompt>> _archivedFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshArchived();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshArchived() {
    setState(() {
      _archivedFuture = ApiService().getPrompts(archived: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ARCHIVE_VAULT',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                  letterSpacing: -2,
                  color: BrutalistColors.black,
                ),
              ),
              const SizedBox(height: 12),
              const IndustrialChip(
                text: 'RESTRICTED ACCESS',
                color: BrutalistColors.secondary,
              ),
              const SizedBox(height: 24),
              IndustrialInput(
                label: 'FILTER_VAULT',
                hint: 'SEARCH_ARCHIVE...',
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Prompt>>(
            future: _archivedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final prompts = (snapshot.data ?? []).where((p) {
                return p.title.toLowerCase().contains(_searchQuery) ||
                       p.content.toLowerCase().contains(_searchQuery);
              }).toList();

              if (prompts.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                itemCount: prompts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final prompt = prompts[index];
                  return Container(
                    decoration: BrutalistTheme.getNakedDecoration(color: BrutalistColors.surfaceVariant),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: BrutalistColors.black, width: 2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  prompt.title.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IndustrialChip(text: prompt.category, color: Colors.white),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            prompt.content,
                            style: GoogleFonts.jetBrainsMono(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: BrutalistColors.black,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: ActionBlockButton(
                                  text: 'RESTORE',
                                  color: BrutalistColors.primaryContainer,
                                  onPressed: () async {
                                    await ApiService().restorePrompt(prompt.id!);
                                    _refreshArchived();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: ActionBlockButton(
                                  text: 'PURGE',
                                  color: BrutalistColors.error,
                                  onPressed: () async {
                                    await ApiService().deletePrompt(prompt.id!);
                                    _refreshArchived();
                                  },
                                ),
                              ),
                            ],
                          ),
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
      child: Container(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.black12,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'VAULT_EMPTY',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 28,
                color: Colors.black26,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Archived prompts will appear here.\nArchive prompts from the Dashboard to store them.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.black38,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

