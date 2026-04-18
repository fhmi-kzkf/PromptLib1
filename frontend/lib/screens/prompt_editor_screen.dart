import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prompt_model.dart';
import '../services/api_service.dart';
import '../widgets/brutalist_widgets.dart';
import '../theme/brutalist_theme.dart';

class PromptEditorScreen extends StatefulWidget {
  final Prompt? prompt;

  const PromptEditorScreen({super.key, this.prompt});

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
    final isEditing = widget.prompt != null;

    return Scaffold(
      backgroundColor: BrutalistColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'MODIFY_RECORD' : 'NEW_RECORD',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            IndustrialInput(
              controller: _titleController,
              label: 'IDENTIFIER (TITLE)',
              hint: 'e.g. SYSTEM_GEN_V1',
            ),
            const SizedBox(height: 24),
            IndustrialInput(
              controller: _categoryController,
              label: 'CLASSIFICATION (CATEGORY)',
              hint: 'e.g. TECHNICAL, CREATIVE',
            ),
            const SizedBox(height: 24),
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROMPT_PAYLOAD',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BrutalistTheme.getNakedDecoration(),
                      child: TextField(
                        controller: _contentController,
                        maxLines: 12,
                        style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 36,
                  right: 12,
                  child: ActionBlockButton(
                    text: 'REFINE',
                    color: BrutalistColors.secondary,
                    onPressed: _isRefining ? () {} : _refinePrompt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ActionBlockButton(
              text: isEditing ? 'COMMIT_CHANGES' : 'SAVE_TO_VAULT',
              onPressed: _isLoading ? () {} : _savePrompt,
            ),
            if (isEditing) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ActionBlockButton(
                      text: 'ARCHIVE',
                      color: BrutalistColors.concrete,
                      onPressed: _archivePrompt,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ActionBlockButton(
                      text: 'DELETE',
                      color: BrutalistColors.tertiary,
                      onPressed: _deletePrompt,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
