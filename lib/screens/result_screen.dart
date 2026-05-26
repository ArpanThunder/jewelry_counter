import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/jewelry_result.dart';
import '../models/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final JewelryResult result;
  final File image;

  const ResultScreen({
    super.key,
    required this.result,
    required this.image,
  });

  Color get _confidenceColor {
    switch (result.confidence.toLowerCase()) {
      case 'high':
        return const Color(0xFF22C55E);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.gold),
            onPressed: () => _copyToClipboard(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              _buildImageCard(),
              const SizedBox(height: 16),

              // Type & metal badge
              _buildJewelryBadge(),
              const SizedBox(height: 20),

              // Stone count grid
              _buildStoneGrid(),
              const SizedBox(height: 14),

              // Total row
              _buildTotalRow(),
              const SizedBox(height: 14),

              // Composition bar
              if (result.totalElements > 0) _buildCompositionBar(),
              const SizedBox(height: 14),

              // Confidence row
              _buildConfidenceRow(),
              const SizedBox(height: 14),

              // Description
              if (result.description.isNotEmpty)
                _buildInfoCard(
                  title: "GEMOLOGIST'S REPORT",
                  content: result.description,
                  contentColor: const Color(0xFFB0A090),
                ),

              // Notes
              if (result.notes.isNotEmpty && result.notes != 'none')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _buildInfoCard(
                    title: 'NOTES',
                    content: result.notes,
                    contentColor: AppTheme.textSecondary,
                  ),
                ),

              const SizedBox(height: 24),

              // Analyze again button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Text('📿', style: TextStyle(fontSize: 16)),
                  label: const Text(
                    'Analyze Another Ornament',
                    style: TextStyle(letterSpacing: 0.5),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.gold,
                    side: const BorderSide(color: AppTheme.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        image,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildJewelryBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          '${_capitalize(result.jewelryType)}  ·  ${_capitalize(result.metal)}',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildStoneGrid() {
    // Build list of stones that exist OR are worth showing
    final stones = [
      _StoneData('goldBalls', '🪙', 'Gold Balls', result.goldBalls, AppTheme.gold),
      _StoneData('diamonds', '💎', 'Diamonds', result.diamonds, AppTheme.diamondColor),
      _StoneData('rubies', '🔴', 'Rubies', result.rubies, AppTheme.rubyColor),
      _StoneData('emeralds', '💚', 'Emeralds', result.emeralds, AppTheme.emeraldColor),
      _StoneData('sapphires', '🔵', 'Sapphires', result.sapphires, AppTheme.sapphireColor),
      _StoneData('pearls', '⚪', 'Pearls', result.pearls, AppTheme.pearlColor),
      if (result.otherStones > 0)
        _StoneData(
          'otherStones',
          '💠',
          result.otherStonesType == 'none' || result.otherStonesType.isEmpty
              ? 'Other'
              : _capitalize(result.otherStonesType),
          result.otherStones,
          AppTheme.otherColor,
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: stones.length,
      itemBuilder: (_, i) => _StoneCard(data: stones[i]),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL ELEMENTS',
            style: TextStyle(
              color: AppTheme.textHint,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            '${result.totalElements}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompositionBar() {
    final total = result.totalElements;
    final sections = [
      _BarSection(result.goldBalls, AppTheme.gold, 'Gold'),
      _BarSection(result.diamonds, AppTheme.diamondColor, 'Diamonds'),
      _BarSection(result.rubies, AppTheme.rubyColor, 'Rubies'),
      _BarSection(result.emeralds, AppTheme.emeraldColor, 'Emeralds'),
      _BarSection(result.sapphires, AppTheme.sapphireColor, 'Sapphires'),
      _BarSection(result.pearls, AppTheme.pearlColor, 'Pearls'),
      _BarSection(result.otherStones, AppTheme.otherColor, 'Other'),
    ].where((s) => s.count > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMPOSITION',
          style: TextStyle(
            color: AppTheme.textHint,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        // Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: sections.map((s) {
              return Flexible(
                flex: s.count,
                child: Container(
                  height: 10,
                  color: s.color,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: sections.map((s) {
            final pct = ((s.count / total) * 100).round();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: s.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${s.label} $pct%',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfidenceRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'AI CONFIDENCE',
            style: TextStyle(
              color: AppTheme.textHint,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          Row(
            children: [
              // 3-bar confidence indicator
              ...List.generate(3, (i) {
                final filled = result.confidence == 'high'
                    ? true
                    : result.confidence == 'medium'
                        ? i < 2
                        : i < 1;
                return Container(
                  width: 20,
                  height: 8,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: filled ? _confidenceColor : AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                result.confidence.toUpperCase(),
                style: TextStyle(
                  color: _confidenceColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required Color contentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: contentColor,
              fontSize: 13,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _copyToClipboard(BuildContext context) {
    final text = '''
Jewelry Analysis Report
=======================
Type: ${_capitalize(result.jewelryType)}
Metal: ${_capitalize(result.metal)}

Stone Count:
• Gold Balls: ${result.goldBalls}
• Diamonds: ${result.diamonds}
• Rubies: ${result.rubies}
• Emeralds: ${result.emeralds}
• Sapphires: ${result.sapphires}
• Pearls: ${result.pearls}
• Other Stones: ${result.otherStones}
──────────────
Total: ${result.totalElements}

Confidence: ${result.confidence.toUpperCase()}
${result.description}
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report copied to clipboard!'),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────

class _StoneData {
  final String key;
  final String emoji;
  final String label;
  final int count;
  final Color color;

  const _StoneData(this.key, this.emoji, this.label, this.count, this.color);
}

class _BarSection {
  final int count;
  final Color color;
  final String label;

  const _BarSection(this.count, this.color, this.label);
}

class _StoneCard extends StatelessWidget {
  final _StoneData data;

  const _StoneCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasStones = data.count > 0;
    return Container(
      decoration: BoxDecoration(
        color: hasStones
            ? data.color.withOpacity(0.08)
            : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasStones
              ? data.color.withOpacity(0.35)
              : AppTheme.border,
          width: hasStones ? 1.2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(
            '${data.count}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: hasStones ? data.color : AppTheme.textHint,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data.label,
            style: TextStyle(
              color: hasStones
                  ? AppTheme.textSecondary
                  : AppTheme.textHint,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
