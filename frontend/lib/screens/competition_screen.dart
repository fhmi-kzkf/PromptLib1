import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/competition_model.dart';
import '../services/api_service.dart';
import '../widgets/brutalist_widgets.dart';
import '../theme/brutalist_theme.dart';
import 'competition_detail_screen.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  late Future<List<Competition>> _competitionsFuture;

  @override
  void initState() {
    super.initState();
    _refreshCompetitions();
  }

  void _refreshCompetitions() {
    setState(() {
      _competitionsFuture = ApiService().getCompetitions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BATTLEFIELD',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                    letterSpacing: -2,
                    color: BrutalistColors.black,
                  ),
                ),
                Text(
                  'PROMPT_ENGINEERING_CHALLENGES',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: BrutalistColors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Competition>>(
              future: _competitionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final comps = snapshot.data ?? [];
                if (comps.isEmpty) {
                  return const Center(child: Text('NO_ACTIVE_CHALLENGES'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: comps.length,
                  itemBuilder: (context, index) {
                    final comp = comps[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: BentoCard(
                        title: comp.title,
                        backgroundColor: BrutalistColors.concrete,
                        contentPadding: const EdgeInsets.all(24),
                        footer: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IndustrialChip(
                              text: '${comp.entryCount} ENTRIES',
                              color: Colors.white,
                            ),
                            ActionBlockButton(
                              text: 'JOIN_BATTLE',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CompetitionDetailScreen(competitionId: comp.id!),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comp.description,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'ENDS IN: ${comp.deadline.difference(DateTime.now()).inDays} DAYS',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
}
