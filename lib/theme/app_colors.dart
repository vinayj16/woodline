import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32); // Green 800
  static const Color primaryDark = Color(0xFF1B5E20); // Green 900
  static const Color primaryLight = Color(0xFF4CAF50); // Green 500
  
  // Accent Colors
  static const Color accent = Color(0xFFFF8F00); // Amber 700
  static const Color accentDark = Color(0xFFE65100); // Orange 900
  static const Color accentLight = Color(0xFFFFC107); // Amber 500
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Grey 900
  static const Color textSecondary = Color(0xFF757575); // Grey 600
  static const Color textLight = Color(0xFFFFFFFF); // White
  static const Color textDisabled = Color(0xFFBDBDBD); // Grey 400
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FA); // Light grey
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Grey 100
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green 500
  static const Color warning = Color(0xFFFFA726); // Orange 400
  static const Color error = Color(0xFFE53935); // Red 600
  static const Color info = Color(0xFF2196F3); // Blue 500
  
  // Border and Divider Colors
  static const Color border = Color(0xFFE0E0E0); // Grey 300
  static const Color divider = Color(0xFFBDBDBD); // Grey 400
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000); // Black 10%
  static const Color shadowLight = Color(0x0D000000); // Black 5%
  
  // Overlay Colors
  static const Color overlay = Color(0x80000000); // Black 50%
  static const Color overlayLight = Color(0x40000000); // Black 25%
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );
  
  // Material Color Swatches
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF2E7D32,
    <int, Color>{
      50: Color(0xFFE8F5E8),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF4CAF50),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );
}