import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/services.dart';
import '../models/prompt_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
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
  List<Prompt> _cachedPrompts = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _refreshPrompts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshPrompts() {
    setState(() {
      _promptsFuture = ApiService().getPrompts().then((data) {
        _cachedPrompts = data;
        return data;
      });
    });
  }

  void _toggleVote(Prompt prompt) async {
    if (!UserSession().isLoggedIn || prompt.id == null) return;

    // Optimistic UI update
    final index = _cachedPrompts.indexWhere((p) => p.id == prompt.id);
    if (index == -1) return;

    final wasVoted = prompt.hasVoted;
    final newCount = wasVoted ? prompt.voteCount - 1 : prompt.voteCount + 1;

    setState(() {
      _cachedPrompts[index] = Prompt(
        id: prompt.id,
        title: prompt.title,
        content: prompt.content,
        category: prompt.category,
        aiModel: prompt.aiModel,
        isArchived: prompt.isArchived,
        imageUrl: prompt.imageUrl,
        authorName: prompt.authorName,
        userId: prompt.userId,
        createdAt: prompt.createdAt,
        voteCount: newCount < 0 ? 0 : newCount,
        hasVoted: !wasVoted,
      );
    });

    try {
      await ApiService().toggleVote(prompt.id!);
    } catch (e) {
      // Revert on failure
      setState(() {
        _cachedPrompts[index] = prompt;
      });
    }
  }

  Widget _buildVoteButton(Prompt prompt) {
    return GestureDetector(
      onTap: () => _toggleVote(prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: prompt.hasVoted ? BrutalistColors.primary : Colors.white,
          border: Border.all(color: BrutalistColors.black, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              prompt.hasVoted ? Icons.arrow_upward : Icons.arrow_upward_outlined,
              size: 14,
              color: BrutalistColors.black,
            ),
            const SizedBox(width: 4),
            Text(
              '${prompt.voteCount}',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: BrutalistColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'PROMPT_COPIED_TO_CLIPBOARD',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePrimary = Theme.of(context).primaryColor;

    return Material(
      color: Colors.transparent,
      child: Column(
      children: [
        // Header Section
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 24, 
            vertical: MediaQuery.of(context).size.width < 600 ? 20 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'DASHBOARD',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                    letterSpacing: -2,
                    color: BrutalistColors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              IndustrialInput(
                label: 'SEARCH_DATABASE',
                hint: 'SEARCH_PROMPTS...',
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
            ],
          ),
        ),

        // Prompts Content (Bento Grid simulation)
        Expanded(
          child: FutureBuilder<List<Prompt>>(
            future: _promptsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _cachedPrompts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final displayPrompts = _cachedPrompts.where((p) {
                return p.title.toLowerCase().contains(_searchQuery) ||
                       p.content.toLowerCase().contains(_searchQuery) ||
                       p.category.toLowerCase().contains(_searchQuery);
              }).toList();

              if (displayPrompts.isEmpty) {
                return _buildEmptyState();
              }

              final screenWidth = MediaQuery.of(context).size.width;
              final crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1);

              return MasonryGridView.count(
                padding: EdgeInsets.fromLTRB(
                  screenWidth < 600 ? 16 : 24, 
                  0, 
                  screenWidth < 600 ? 16 : 24, 
                  100
                ),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: screenWidth < 600 ? 16 : 24,
                crossAxisSpacing: screenWidth < 600 ? 16 : 24,
                itemCount: displayPrompts.length,
                itemBuilder: (context, index) {
                  final prompt = displayPrompts[index];
                  bool isHighlight = index == 0 && _searchQuery.isEmpty;
                  
                  if (isHighlight) {
                    return BentoCard(
                      title: prompt.title,
                      backgroundColor: BrutalistColors.primaryContainer,
                      tag: 'FEATURED',
                      contentPadding: EdgeInsets.all(screenWidth < 600 ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prompt.content,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: screenWidth < 600 ? 15 : 18,
                              fontWeight: FontWeight.w500,
                              color: BrutalistColors.black,
                              height: 1.4,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 24),
                          Flex(
                            direction: screenWidth < 600 ? Axis.vertical : Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: screenWidth < 600 ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: screenWidth < 600 ? 0 : 1,
                                child: Row(
                                  children: [
                                    const Icon(Icons.smart_toy, size: 16),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        prompt.aiModel.toUpperCase(),
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (screenWidth < 600) const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildVoteButton(prompt),
                                  const SizedBox(width: 12),
                                  ActionBlockButton(
                                    text: 'EXECUTE',
                                    color: Colors.black,
                                    isCompact: screenWidth < 600,
                                    onPressed: () => _navigateToEditor(prompt: prompt),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  if (prompt.imageUrl != null) {
                    return BentoCard(
                      title: prompt.title,
                      imageUrl: prompt.imageUrl,
                      tag: prompt.category,
                      contentPadding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prompt.content,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Flex(
                            direction: screenWidth < 600 ? Axis.vertical : Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: screenWidth < 600 ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: screenWidth < 600 ? 0 : 1,
                                child: Text(
                                  prompt.aiModel.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black45,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (screenWidth < 600) const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildVoteButton(prompt),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 18),
                                    onPressed: () => _copyToClipboard(prompt.content),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                    return BentoCard(
                      title: prompt.title,
                      backgroundColor: BrutalistColors.surfaceVariant,
                      tag: (prompt.authorName ?? prompt.category).toUpperCase(),
                      contentPadding: const EdgeInsets.all(16),
                      footer: Flex(
                        direction: screenWidth < 600 ? Axis.vertical : Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: screenWidth < 600 ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: screenWidth < 600 ? 0 : 1,
                            child: IndustrialChip(
                              text: prompt.aiModel.split('-').last,
                              color: Colors.white,
                            ),
                          ),
                          if (screenWidth < 600) const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildVoteButton(prompt),
                              const SizedBox(width: 12),
                              ActionBlockButton(
                                text: 'OPEN',
                                isCompact: screenWidth < 600,
                                onPressed: () => _navigateToEditor(prompt: prompt),
                              ),
                            ],
                          ),
                        ],
                      ),
                      child: Text(
                        prompt.content,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                },
              );
            },
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              border: Border.all(
                color: BrutalistColors.black.withOpacity(0.2),
                width: 3,
                style: BorderStyle.none, // Will use custom painter for dashed
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.add_circle_outline, size: 48, color: Colors.black26),
                const SizedBox(height: 16),
                Text(
                  'CREATE NEW SLOT',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ActionBlockButton(
            text: 'INITIALIZE RECORD',
            isLarge: true,
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

