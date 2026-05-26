import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_theme.dart';
import '../services/gemini_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _isAnalyzing = false;
  String _loadingMessage = '';
  int _loadingStep = 0;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final _picker = ImagePicker();

  final List<String> _loadingMessages = [
    '🔍  Scanning your jewelry...',
    '🪙  Counting gold balls...',
    '💎  Detecting diamonds...',
    '🔴  Identifying rubies...',
    '💚  Looking for emeralds...',
    '📋  Preparing your report...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadingMessage = _loadingMessages[0];
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1400,
        maxHeight: 1400,
      );
      if (picked == null) return;
      setState(() {
        _selectedImage = File(picked.path);
      });
    } catch (e) {
      _showError('Could not pick image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _loadingStep = 0;
      _loadingMessage = _loadingMessages[0];
    });

    // Cycle loading messages
    final timer = Stream.periodic(
      const Duration(milliseconds: 1000),
      (i) => i,
    ).take(_loadingMessages.length).listen((i) {
      if (mounted) {
        setState(() {
          _loadingStep = i % _loadingMessages.length;
          _loadingMessage = _loadingMessages[_loadingStep];
        });
      }
    });

    try {
      final result = await GeminiService.analyzeImage(_selectedImage!);
      timer.cancel();

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            image: _selectedImage!,
          ),
        ),
      );
    } catch (e) {
      timer.cancel();
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _sheetOption(
                icon: Icons.camera_alt_rounded,
                title: 'Take Photo',
                subtitle: 'Capture jewelry with camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              _sheetOption(
                icon: Icons.photo_library_rounded,
                title: 'Choose from Gallery',
                subtitle: 'Pick an existing jewelry photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppTheme.gold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.gold, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💎 Jewelry Analyzer'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Image area
              _buildImageArea(),
              const SizedBox(height: 16),

              // Pick buttons
              _buildPickButtons(),
              const SizedBox(height: 16),

              // Analyze button
              if (_selectedImage != null) _buildAnalyzeButton(),

              const SizedBox(height: 32),

              // Stone legend
              _buildLegend(),

              const SizedBox(height: 24),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ScaleTransition(
          scale: _pulseAnim,
          child: const Text('💎', style: TextStyle(fontSize: 52)),
        ),
        const SizedBox(height: 10),
        const Text(
          'Jewelry Stone Counter',
          style: TextStyle(
            color: AppTheme.gold,
            fontSize: 22,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Gold Balls  ·  Diamonds  ·  Rubies  ·  Emeralds  ·  More',
          style: TextStyle(
            color: AppTheme.textHint,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildImageArea() {
    return GestureDetector(
      onTap: _isAnalyzing ? null : _showSourceSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0600),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _selectedImage != null
                ? AppTheme.gold.withOpacity(0.5)
                : AppTheme.border,
            width: _selectedImage != null ? 1.5 : 1,
          ),
          boxShadow: _selectedImage != null
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: _isAnalyzing
            ? _buildLoadingOverlay()
            : _selectedImage != null
                ? _buildImagePreview()
                : _buildEmptyState(),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: AppTheme.gold,
                strokeWidth: 2,
                backgroundColor: AppTheme.border,
              ),
            ),
            Text('💎', style: TextStyle(fontSize: 26)),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          _loadingMessage,
          style: const TextStyle(
            color: AppTheme.gold,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _loadingMessages.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: i == _loadingStep ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i == _loadingStep ? AppTheme.gold : AppTheme.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
          ),
        ),
        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(23)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Remove button
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImage = null),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.close,
                  color: AppTheme.textSecondary, size: 16),
            ),
          ),
        ),
        // Tap to change hint
        Positioned(
          bottom: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Text(
              'Tap to change',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.gold.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: AppTheme.gold,
            size: 34,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tap to select jewelry photo',
          style: TextStyle(color: AppTheme.gold, fontSize: 15),
        ),
        const SizedBox(height: 6),
        const Text(
          'Necklace · Ring · Bangle · Earring · Mangalsutra',
          style: TextStyle(color: AppTheme.textHint, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildPickButtons() {
    return Row(
      children: [
        Expanded(
          child: _pickButton(
            Icons.camera_alt_rounded,
            'Camera',
            () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _pickButton(
            Icons.photo_library_rounded,
            'Gallery',
            () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _pickButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isAnalyzing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.gold, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _analyzeImage,
        child: const Text('✨  Analyze Jewelry'),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETECTS',
            style: TextStyle(
              color: AppTheme.textHint,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: stoneTypes
                .map((s) => _legendChip(s.emoji, s.label, s.color))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _legendChip(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Powered by Google Gemini AI  ·  Free Tier',
              style: TextStyle(color: AppTheme.textHint, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          '1,500 free scans/day  ·  No credit card needed',
          style: TextStyle(color: Color(0xFF2A2A2A), fontSize: 10),
        ),
      ],
    );
  }
}
