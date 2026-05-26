import 'package:flutter/material.dart';

class AppTheme {
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFF8B6914);
  static const Color goldLight = Color(0xFFF5E6A3);
  static const Color bgDark = Color(0xFF080808);
  static const Color bgCard = Color(0xFF111111);
  static const Color bgCard2 = Color(0xFF1A1A1A);
  static const Color border = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFE8E0D0);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textHint = Color(0xFF444444);

  // Stone colors
  static const Color diamondColor = Color(0xFFA8D8EA);
  static const Color rubyColor = Color(0xFFE63946);
  static const Color emeraldColor = Color(0xFF2DC653);
  static const Color sapphireColor = Color(0xFF4361EE);
  static const Color pearlColor = Color(0xFFF0EAD6);
  static const Color otherColor = Color(0xFFC084FC);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          surface: bgCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0600),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: gold,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: gold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: bgDark,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5),
          ),
        ),
      );
}

class StoneInfo {
  final String key;
  final String label;
  final String emoji;
  final Color color;

  const StoneInfo({
    required this.key,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

const List<StoneInfo> stoneTypes = [
  StoneInfo(key: 'goldBalls', label: 'Gold Balls', emoji: '🪙', color: AppTheme.gold),
  StoneInfo(key: 'diamonds', label: 'Diamonds', emoji: '💎', color: AppTheme.diamondColor),
  StoneInfo(key: 'rubies', label: 'Rubies', emoji: '🔴', color: AppTheme.rubyColor),
  StoneInfo(key: 'emeralds', label: 'Emeralds', emoji: '💚', color: AppTheme.emeraldColor),
  StoneInfo(key: 'sapphires', label: 'Sapphires', emoji: '🔵', color: AppTheme.sapphireColor),
  StoneInfo(key: 'pearls', label: 'Pearls', emoji: '⚪', color: AppTheme.pearlColor),
  StoneInfo(key: 'otherStones', label: 'Other', emoji: '💠', color: AppTheme.otherColor),
];
