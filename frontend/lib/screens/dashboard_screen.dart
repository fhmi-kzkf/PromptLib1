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
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Prompt>> _promptsFuture;
  List<Prompt> _cachedPrompts = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    refreshPrompts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void refreshPrompts() {
    setState(() {
      _promptsFuture = ApiService().getPrompts().then((data) {
        if (mounted) {
          setState(() {
            _cachedPrompts = data;
          });
        }
        return data;
      });
    });
  }

  void _toggleVote(Prompt prompt) async {
    if (!UserSession().isLoggedIn || prompt.id == null) return;

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

  void _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PROMPT_COPIED_TO_CLIPBOARD',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.black),
          ),
          backgroundColor: BrutalistColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 4),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CLIPBOARD DENIED (HTTP). PLEASE CLICK "OPEN" TO COPY.',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.white),
          ),
          backgroundColor: BrutalistColors.error,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 4),
          ),
        ),
      );
    }
  }

  /// Uniform action row for ALL card types: Vote + COPY + OPEN
  Widget _buildCardActions(Prompt prompt, {bool isCompact = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildVoteButton(prompt),
        const SizedBox(width: 8),
        _buildSmallActionButton(
          icon: Icons.copy,
          label: 'COPY',
          onTap: () => _copyToClipboard(prompt.content),
        ),
        const SizedBox(width: 8),
        ActionBlockButton(
          text: 'OPEN',
          isCompact: isCompact,
          onPressed: () => _navigateToEditor(prompt: prompt),
        ),
      ],
    );
  }

  Widget _buildSmallActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: BrutalistColors.black, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: BrutalistColors.black),
            const SizedBox(width: 4),
            Text(
              label,
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

  Widget _buildFilterChips() {
    if (_cachedPrompts.isEmpty) return const SizedBox.shrink();

    // Extract unique categories
    final Set<String> uniqueCategories = {'ALL'};
    for (var p in _cachedPrompts) {
      if (p.category.trim().isNotEmpty) {
        uniqueCategories.add(p.category.toUpperCase());
      }
    }

    final categories = uniqueCategories.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 24,
      ),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat);
              },
              child: IndustrialChip(
                text: cat,
                color: isSelected ? BrutalistColors.primaryContainer : Colors.white,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
      children: [
        // Header Section
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 24,
            vertical: MediaQuery.of(context).size.width < 600 ? 12 : 16,
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
                    fontSize: 36,
                    letterSpacing: -2,
                    color: BrutalistColors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
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

        // Filter Chips
        _buildFilterChips(),
        const SizedBox(height: 16),

        // Prompts Content
        Expanded(
          child: FutureBuilder<List<Prompt>>(
            future: _promptsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _cachedPrompts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final displayPrompts = _cachedPrompts.where((p) {
                final matchesSearch = p.title.toLowerCase().contains(_searchQuery) ||
                       p.content.toLowerCase().contains(_searchQuery) ||
                       p.category.toLowerCase().contains(_searchQuery);
                final matchesCategory = _selectedCategory == 'ALL' || p.category.toUpperCase() == _selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

              if (displayPrompts.isEmpty) {
                return _buildEmptyState();
              }

              final screenWidth = MediaQuery.of(context).size.width;
              final crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1);
              final isCompact = screenWidth < 600;

              return MasonryGridView.count(
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 16 : 24,
                  0,
                  isCompact ? 16 : 24,
                  100
                ),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: isCompact ? 16 : 24,
                crossAxisSpacing: isCompact ? 16 : 24,
                itemCount: displayPrompts.length,
                itemBuilder: (context, index) {
                  final prompt = displayPrompts[index];
                  bool isHighlight = index == 0 && _searchQuery.isEmpty;

                  // ========== FEATURED CARD ==========
                  if (isHighlight) {
                    return BentoCard(
                      title: prompt.title,
                      backgroundColor: BrutalistColors.primaryContainer,
                      tag: 'FEATURED',
                      contentPadding: EdgeInsets.all(isCompact ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prompt.content,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: isCompact ? 15 : 18,
                              fontWeight: FontWeight.w500,
                              color: BrutalistColors.black,
                              height: 1.4,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 24),
                          Flex(
                            direction: isCompact ? Axis.vertical : Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: isCompact ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: isCompact ? 0 : 1,
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
                              if (isCompact) const SizedBox(height: 16),
                              _buildCardActions(prompt, isCompact: isCompact),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // ========== IMAGE CARD ==========
                  if (prompt.imageUrl != null) {
                    return BentoCard(
                      title: prompt.title,
                      imageUrl: _resolveImageUrl(prompt.imageUrl!),
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
                            direction: isCompact ? Axis.vertical : Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: isCompact ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: isCompact ? 0 : 1,
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
                              if (isCompact) const SizedBox(height: 12),
                              _buildCardActions(prompt, isCompact: isCompact),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // ========== TEXT-ONLY CARD ==========
                  return BentoCard(
                    title: prompt.title,
                    backgroundColor: BrutalistColors.surfaceVariant,
                    tag: (prompt.authorName ?? prompt.category).toUpperCase(),
                    contentPadding: const EdgeInsets.all(16),
                    footer: Flex(
                      direction: isCompact ? Axis.vertical : Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: isCompact ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: isCompact ? 0 : 1,
                          child: IndustrialChip(
                            text: prompt.aiModel.split('-').last,
                            color: Colors.white,
                          ),
                        ),
                        if (isCompact) const SizedBox(height: 12),
                        _buildCardActions(prompt, isCompact: isCompact),
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

  String _resolveImageUrl(String url) {
    if (url.startsWith('http')) return url;
    final baseUri = Uri.parse(ApiService().baseUrl);
    return '${baseUri.scheme}://${baseUri.host}:${baseUri.port}$url';
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
                style: BorderStyle.none,
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
      refreshPrompts();
    }
  }
}
