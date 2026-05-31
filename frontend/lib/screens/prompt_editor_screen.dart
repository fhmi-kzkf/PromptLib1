import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../models/prompt_model.dart';
import '../services/api_service.dart';
import '../widgets/brutalist_widgets.dart';
import '../theme/brutalist_theme.dart';
import '../services/user_session.dart';

class PromptEditorScreen extends StatefulWidget {
  final Prompt? prompt;
  final int? competitionId;
  final VoidCallback? onPostSuccess; // Callback to switch to dashboard tab

  const PromptEditorScreen({super.key, this.prompt, this.competitionId, this.onPostSuccess});

  @override
  State<PromptEditorScreen> createState() => _PromptEditorScreenState();
}

class _PromptEditorScreenState extends State<PromptEditorScreen> with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isRefining = false;
  bool _isLoading = false;
  bool _isUploading = false;

  // Image attachment
  String? _imageUrl; // Server path after upload
  Uint8List? _imageBytes; // Local preview
  String? _imageFileName;

  // AI Animation
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  bool _showTypewriter = false;
  String _typewriterText = '';
  int _typewriterIndex = 0;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    if (widget.prompt != null) {
      _titleController.text = widget.prompt!.title;
      _contentController.text = widget.prompt!.content;
      _categoryController.text = widget.prompt!.category;
      _imageUrl = widget.prompt!.imageUrl;
    }

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    _typewriterTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = UserSession().isLoggedIn;
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
                          readOnly: !canCommit && !isLoggedIn,
                        ),
                      ),
                      if (isDesktop) const SizedBox(width: 24),
                      if (isDesktop)
                        Expanded(
                          child: IndustrialInput(
                            controller: _categoryController,
                            label: 'CLASSIFICATION',
                            hint: 'e.g. TECHNICAL',
                            readOnly: !canCommit && !isLoggedIn,
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
                      readOnly: !canCommit && !isLoggedIn,
                    ),
                  const SizedBox(height: 32),

                  // Prompt Payload Box with AI overlay
                  _buildPromptPayloadBox(),

                  const SizedBox(height: 24),

                  // Image Attachment Section
                  _buildImageAttachment(),

                  const SizedBox(height: 32),

                  // Action buttons
                  _buildActionButtons(canCommit, isLoggedIn, isEditing),
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
                          'READY_FOR_COMMMIT\nCHECKSUM: OK\nUSER_ID: ${UserSession().userId ?? "N/A"}',
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

  // ========== PROMPT PAYLOAD BOX WITH AI ANIMATION ==========

  Widget _buildPromptPayloadBox() {
    return Container(
      decoration: BrutalistTheme.getShadowDecoration(color: Colors.white),
      child: Column(
        children: [
          // Header bar
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
                if (_isRefining)
                  FadeTransition(
                    opacity: _pulseController,
                    child: const IndustrialChip(
                      text: 'AI_PROCESSING',
                      color: BrutalistColors.secondary,
                      textColor: Colors.white,
                    ),
                  )
                else
                  const IndustrialChip(
                    text: 'UTF-8',
                    color: BrutalistColors.primaryContainer,
                  ),
              ],
            ),
          ),
          // Text field with AI overlay
          Stack(
            children: [
              TextField(
                controller: _contentController,
                maxLines: 15,
                enabled: !_isRefining,
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _isRefining ? Colors.transparent : BrutalistColors.black,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(20),
                  border: InputBorder.none,
                ),
              ),
              // AI Processing Overlay
              if (_isRefining)
                Positioned.fill(
                  child: _buildAiOverlay(),
                ),
            ],
          ),
          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: BrutalistColors.black, width: 2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _isRefining
                  ? ActionBlockButton(
                      text: 'PROCESSING...',
                      color: BrutalistColors.surfaceVariant,
                      icon: Icons.hourglass_top,
                      onPressed: () {},
                    )
                  : ActionBlockButton(
                      text: 'REFINE WITH AI',
                      color: BrutalistColors.secondary,
                      icon: Icons.auto_awesome,
                      onPressed: _refinePrompt,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.92),
      child: Stack(
        children: [
          // Scan line animation
          AnimatedBuilder(
            animation: _scanLineController,
            builder: (context, child) {
              return Positioned(
                top: _scanLineController.value * 300,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        BrutalistColors.primaryContainer.withOpacity(0.8),
                        BrutalistColors.primaryContainer,
                        BrutalistColors.primaryContainer.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Grid pattern background
          ...List.generate(6, (i) {
            return Positioned(
              top: (i * 50) + 10,
              left: 20,
              right: 20,
              child: FadeTransition(
                opacity: _pulseController,
                child: Container(
                  height: 1,
                  color: BrutalistColors.primaryContainer.withOpacity(0.1),
                ),
              ),
            );
          }),
          // Center text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spinning indicator
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(BrutalistColors.primaryContainer),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _pulseController,
                  child: Text(
                    '> AI_OPTIMIZING_PAYLOAD...',
                    style: GoogleFonts.jetBrainsMono(
                      color: BrutalistColors.primaryContainer,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ANALYZING STRUCTURE // REFINING SEMANTICS',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white24,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== IMAGE ATTACHMENT ==========

  Widget _buildImageAttachment() {
    return Container(
      decoration: BrutalistTheme.getNakedDecoration(color: BrutalistColors.surfaceVariant),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: _isUploading ? null : _pickImage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _imageUrl != null || _imageBytes != null
                      ? Icons.image
                      : Icons.add_photo_alternate_outlined,
                    size: 20,
                    color: BrutalistColors.black,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _imageUrl != null || _imageBytes != null
                        ? 'IMAGE_ATTACHED'
                        : 'ATTACH_IMAGE (OPTIONAL)',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: BrutalistColors.black,
                      ),
                    ),
                  ),
                  if (_isUploading)
                    const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_imageUrl != null || _imageBytes != null)
                    GestureDetector(
                      onTap: _clearImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: BrutalistColors.error,
                          border: Border.all(color: BrutalistColors.black, width: 2),
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: BrutalistColors.primaryContainer,
                        border: Border.all(color: BrutalistColors.black, width: 2),
                      ),
                      child: const Icon(Icons.add, size: 14),
                    ),
                ],
              ),
            ),
          ),
          // Preview
          if (_imageBytes != null)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: BrutalistColors.black, width: 2)),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              width: double.infinity,
              child: Image.memory(
                _imageBytes!,
                fit: BoxFit.cover,
              ),
            )
          else if (_imageUrl != null)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: BrutalistColors.black, width: 2)),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              width: double.infinity,
              child: Image.network(
                _resolveImageUrl(_imageUrl!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: BrutalistColors.surfaceVariant,
                  child: Center(
                    child: Text(
                      'IMAGE_LOAD_FAILED',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _resolveImageUrl(String url) {
    if (url.startsWith('http')) return url;
    // Build absolute URL from relative path
    final baseUri = Uri.parse(ApiService().baseUrl);
    return '${baseUri.scheme}://${baseUri.host}:${baseUri.port}$url';
  }

  // ========== ACTION BUTTONS ==========

  Widget _buildActionButtons(bool canCommit, bool isLoggedIn, bool isEditing) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // POST_TO_DASHBOARD — available for all logged-in users
        if (isLoggedIn && !isEditing)
          ActionBlockButton(
            text: _isLoading ? 'POSTING...' : 'POST_TO_DASHBOARD',
            isLarge: true,
            color: BrutalistColors.primaryContainer,
            icon: Icons.publish,
            onPressed: _isLoading ? () {} : _postToDashboard,
          ),
        // Admin: COMMIT_CHANGES / SAVE_TO_VAULT
        if (canCommit)
          ActionBlockButton(
            text: isEditing
              ? (_isLoading ? 'SAVING...' : 'COMMIT_CHANGES')
              : (_isLoading ? 'SAVING...' : 'SAVE_TO_VAULT'),
            isLarge: true,
            onPressed: _isLoading ? () {} : _savePrompt,
          ),
        if (canCommit && isEditing)
          ActionBlockButton(
            text: 'DELETE',
            color: BrutalistColors.error,
            onPressed: _deletePrompt,
          ),
      ],
    );
  }

  // ========== LOGIC ==========

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true, // Required for web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _imageBytes = file.bytes;
            _imageFileName = file.name;
            _imageUrl = null; // Clear any previous server URL
          });
        }
      }
    } catch (e) {
      _showSnackbar('Failed to pick image.');
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageFileName = null;
      _imageUrl = null;
    });
  }

  /// Upload the picked image to server and return the URL
  Future<String?> _uploadImageIfNeeded() async {
    if (_imageBytes == null || _imageFileName == null) {
      return _imageUrl; // Return existing URL or null
    }

    setState(() => _isUploading = true);
    try {
      final url = await ApiService().uploadImage(
        bytes: _imageBytes!,
        fileName: _imageFileName!,
      );
      setState(() {
        _imageUrl = url;
        _isUploading = false;
      });
      return url;
    } catch (e) {
      setState(() => _isUploading = false);
      _showSnackbar('Image upload failed.');
      return null;
    }
  }

  Future<void> _refinePrompt() async {
    if (_contentController.text.isEmpty) {
      _showSnackbar('Payload empty. Aborting.');
      return;
    }

    setState(() => _isRefining = true);
    try {
      final refined = await ApiService().refinePrompt(_contentController.text);
      // Typewriter effect
      _startTypewriter(refined);
    } catch (e) {
      setState(() => _isRefining = false);
      _showSnackbar('Critical error during refinement.');
    }
  }

  void _startTypewriter(String text) {
    _typewriterText = text;
    _typewriterIndex = 0;
    _contentController.text = '';

    setState(() {
      _isRefining = false;
      _showTypewriter = true;
    });

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (_typewriterIndex < _typewriterText.length) {
        _typewriterIndex++;
        _contentController.text = _typewriterText.substring(0, _typewriterIndex);
        // Move cursor to end
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _contentController.text.length),
        );
      } else {
        timer.cancel();
        setState(() => _showTypewriter = false);
        _showSnackbar('Payload optimization complete.');
      }
    });
  }

  Future<void> _postToDashboard() async {
    if (_titleController.text.isEmpty) {
      _showSnackbar('Missing required field: IDENTIFIER.');
      return;
    }
    if (_categoryController.text.isEmpty) {
      _showSnackbar('Missing required field: CLASSIFICATION.');
      return;
    }
    if (_contentController.text.isEmpty) {
      _showSnackbar('Missing required field: PAYLOAD.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Upload image first if needed
      final imageUrl = await _uploadImageIfNeeded();

      final prompt = Prompt(
        title: _titleController.text,
        content: _contentController.text,
        category: _categoryController.text,
        aiModel: 'gemini-2.5-flash',
        imageUrl: imageUrl,
      );

      await ApiService().createPrompt(prompt);
      _showSnackbar('Prompt posted to dashboard!');

      // Navigate back or switch to dashboard
      if (widget.onPostSuccess != null) {
        widget.onPostSuccess!();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackbar('Failed to post prompt. Check all fields.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePrompt() async {
    if (_titleController.text.isEmpty) {
      _showSnackbar('Missing required field: IDENTIFIER.');
      return;
    }
    if (_categoryController.text.isEmpty) {
      _showSnackbar('Missing required field: CLASSIFICATION.');
      return;
    }
    if (_contentController.text.isEmpty) {
      _showSnackbar('Missing required field: PAYLOAD.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Upload image first if needed
      final imageUrl = await _uploadImageIfNeeded();

      final prompt = Prompt(
        id: widget.prompt?.id,
        title: _titleController.text,
        content: _contentController.text,
        category: _categoryController.text,
        aiModel: 'gemini-2.5-flash',
        isArchived: widget.prompt?.isArchived ?? false,
        imageUrl: imageUrl,
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
