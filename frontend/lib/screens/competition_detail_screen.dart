import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/competition_model.dart';
import '../models/prompt_model.dart';
import '../services/api_service.dart';
import '../widgets/brutalist_widgets.dart';
import '../theme/brutalist_theme.dart';
import 'prompt_editor_screen.dart';

class CompetitionDetailScreen extends StatefulWidget {
  final int competitionId;

  const CompetitionDetailScreen({super.key, required this.competitionId});

  @override
  State<CompetitionDetailScreen> createState() => _CompetitionDetailScreenState();
}

class _CompetitionDetailScreenState extends State<CompetitionDetailScreen> {
  late Future<Competition> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _refreshDetails();
  }

  void _refreshDetails() {
    setState(() {
      _detailsFuture = ApiService().getCompetitionDetails(widget.competitionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrutalistColors.background,
      appBar: AppBar(
        title: Text('BATTLE_DETAILS', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Competition>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('CRITICAL_ERROR: ${snapshot.error}'));
          }

          final comp = snapshot.data!;
          final entries = comp.entries ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(comp),
                const SizedBox(height: 40),
                if (entries.isNotEmpty) ...[
                  Text(
                    'TOP_CONTENDERS',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  _buildLeaderboard(entries.take(3).toList()),
                  const SizedBox(height: 40),
                  Text(
                    'ALL_SUBMISSIONS',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  ...entries.skip(3).map((e) => _buildEntryCard(e)).toList(),
                ] else ...[
                  _buildNoEntriesState(comp),
                ],
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSubmissionEditor(),
        backgroundColor: BrutalistColors.primaryContainer,
        label: Text('JOIN_BATTLE', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.black)),
        icon: const Icon(Icons.add, color: Colors.black),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
        ),
      ),
    );
  }

  Widget _buildHeader(Competition comp) {
    return BentoCard(
      title: 'BATTLE_INTEL',
      backgroundColor: BrutalistColors.primaryContainer,
      contentPadding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comp.title,
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1),
          ),
          const SizedBox(height: 12),
          Text(
            comp.description,
            style: GoogleFonts.spaceGrotesk(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatChip('DEADLINE', comp.deadline.toString().split(' ')[0]),
              const SizedBox(width: 12),
              _buildStatChip('STATUS', comp.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(List<Prompt> topEntries) {
    return Column(
      children: topEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final prompt = entry.value;
        final colors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: BentoCard(
            title: 'RANK #${index + 1}',
            headerColor: colors[index],
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('@${prompt.authorName ?? 'ANONYMOUS'}', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 12)),
                IndustrialChip(text: '${prompt.voteCount} VOTES', color: BrutalistColors.primaryContainer),
              ],
            ),
            child: Text(
              prompt.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(fontStyle: FontStyle.italic),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEntryCard(Prompt prompt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: BentoCard(
        title: prompt.title,
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('@${prompt.authorName ?? 'ANONYMOUS'}', style: GoogleFonts.jetBrainsMono(fontSize: 10)),
            IndustrialChip(text: '${prompt.voteCount} VOTES', color: BrutalistColors.concrete),
          ],
        ),
        child: Text(prompt.content, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildNoEntriesState(Competition comp) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.shield_outlined, size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          Text(
            'THE_ARENA_IS_EMPTY',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.black26),
          ),
          const SizedBox(height: 8),
          Text(
            'BE_THE_FIRST_TO_SUBMIT',
            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  void _openSubmissionEditor() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PromptEditorScreen(competitionId: widget.competitionId),
      ),
    );
    if (result == true) {
      _refreshDetails();
    }
  }
}
