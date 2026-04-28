import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prompt_model.dart';
import '../services/api_service.dart';
import '../widgets/brutalist_widgets.dart';
import '../theme/brutalist_theme.dart';
import '../services/user_session.dart';

class PromptEditorScreen extends StatefulWidget {
  final Prompt? prompt;
  final int? competitionId; // Added for submissions

  const PromptEditorScreen({super.key, this.prompt, this.competitionId});

  @override
  State<PromptEditorScreen> createState() => _PromptEditorScreenState();
}

class _PromptEditorScreenState extends State<PromptEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isRefining = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prompt != null) {
      _titleController.text = widget.prompt!.title;
      _contentController.text = widget.prompt!.content;
      _categoryController.text = widget.prompt!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = UserSession().rank?.toUpperCase() == 'ADMIN';
    final bool canCommit = isAdmin; 
    final isEditing = widget.prompt != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: BrutalistColors.background,
      appBar: AppBar(
        title: Text(
          !canCommit ? 'VIEW_RECORD (READ-ONLY)' : (isEditing ? 'MODIFY_RECORD' : 'ADD PROMPT'),
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop() 
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Content Area
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: IndustrialInput(
                          controller: _titleController,
                          label: 'IDENTIFIER',
                          hint: 'e.g. SYSTEM_GEN_V1',
                          readOnly: !canCommit,
                        ),
                      ),
                      if (isDesktop) const SizedBox(width: 24),
                      if (isDesktop)
                        Expanded(
                          child: IndustrialInput(
                            controller: _categoryController,
                            label: 'CLASSIFICATION',
                            hint: 'e.g. TECHNICAL',
                            readOnly: !canCommit,
                          ),
                        ),
                    ],
                  ),
                  if (!isDesktop) const SizedBox(height: 24),
                  if (!isDesktop)
                    IndustrialInput(
                      controller: _categoryController,
                      label: 'CLASSIFICATION',
                      hint: 'e.g. TECHNICAL',
                      readOnly: !canCommit,
                    ),
                  const SizedBox(height: 32),
                  
                  // Prompt Payload Box
                  Container(
                    decoration: BrutalistTheme.getShadowDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: const BoxDecoration(
                            color: BrutalistColors.black,
                            border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'PROMPT_PAYLOAD',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IndustrialChip(
                                text: 'UTF-8',
                                color: BrutalistColors.primaryContainer,
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          controller: _contentController,
                          maxLines: 15,
                          // Content is ALWAYS editable locally so users can tweak it
                          style: GoogleFonts.jetBrainsMono(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: BrutalistColors.black,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(20),
                            border: InputBorder.none,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: BrutalistColors.black, width: 2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // EVERYONE can use REFINE WITH AI
                              ActionBlockButton(
                                text: 'REFINE WITH AI',
                                color: BrutalistColors.secondary,
                                icon: Icons.auto_awesome,
                                onPressed: _isRefining ? () {} : _refinePrompt,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (canCommit)
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        ActionBlockButton(
                          text: isEditing ? 'COMMIT_CHANGES' : 'SAVE_TO_VAULT',
                          isLarge: true,
                          onPressed: _isLoading ? () {} : _savePrompt,
                        ),
                        if (isEditing)
                          ActionBlockButton(
                            text: 'DELETE',
                            color: BrutalistColors.error,
                            onPressed: _deletePrompt,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          // Desktop Sidebar
          if (isDesktop)
            Container(
              width: 300,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: BrutalistColors.black, width: 3)),
                color: BrutalistColors.surfaceVariant,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SidebarHeader(title: 'METADATA_CORE'),
                  _SidebarStatRow(label: 'TOKEN_LIMIT', value: '4,096'),
                  _SidebarStatRow(label: 'LATENCY', value: '142ms'),
                  _SidebarStatRow(label: 'COST_EST', value: '\$0.002'),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: BentoCard(
                      title: 'SYSTEM_LOG',
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'READY_FOR_COMMMIT\nCHECKSUM: OK\nUSER_ID: 0092',
                          style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _refinePrompt() async {
    if (_contentController.text.isEmpty) {
      _showSnackbar('Payload empty. Aborting.');
      return;
    }

    setState(() => _isRefining = true);
    try {
      final refined = await ApiService().refinePrompt(_contentController.text);
      _contentController.text = refined;
      _showSnackbar('Payload optimization complete.');
    } catch (e) {
      _showSnackbar('Critical error during refinement.');
    } finally {
      setState(() => _isRefining = false);
    }
  }

  Future<void> _savePrompt() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      _showSnackbar('Missing required fields.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prompt = Prompt(
        id: widget.prompt?.id,
        title: _titleController.text,
        content: _contentController.text,
        category: _categoryController.text,
        aiModel: 'gemini-2.5-flash',
        isArchived: widget.prompt?.isArchived ?? false,
        competitionId: widget.competitionId ?? widget.prompt?.competitionId,
      );

      if (widget.prompt != null) {
        await ApiService().updatePrompt(prompt);
      } else {
        await ApiService().createPrompt(prompt);
      }
      
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        _showSnackbar('Record saved to vault.');
      }
    } catch (e) {
      _showSnackbar('Failed to commit record.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _archivePrompt() async {
    try {
      if (widget.prompt?.id != null) {
        await ApiService().archivePrompt(widget.prompt!.id!);
        _showSnackbar('Record moved to Archive.');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackbar('Archival failed.');
    }
  }

  Future<void> _deletePrompt() async {
    try {
      if (widget.prompt?.id != null) {
        await ApiService().deletePrompt(widget.prompt!.id!);
        _showSnackbar('Record purged from system.');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackbar('Purge failed.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: BrutalistColors.primary,
        behavior: SnackBarBehavior.floating,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 4),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final String title;
  const _SidebarHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: BrutalistColors.black,
        border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
      ),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SidebarStatRow extends StatelessWidget {
  final String label;
  final String value;
  const _SidebarStatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BrutalistColors.black, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 10),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w900, fontSize: 10, color: BrutalistColors.secondary),
          ),
        ],
      ),
    );
  }
}
