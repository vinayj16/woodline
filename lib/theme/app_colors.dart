import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4CAF50); // Green 500
  static const Color primaryDark = Color(0xFF388E3C); // Green 700
  static const Color primaryLight = Color(0xFFC8E6C9); // Green 100
  
  // Accent Colors
  static const Color accent = Color(0xFFFFC107; // Amber 500
  static const Color accentDark = Color(0xFFFFA000; // Amber 700
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Grey 900
  static const Color textSecondary = Color(0xFF757575); // Grey 600
  static const Color textLight = Color(0xFFFFFFFF); // White
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5); // Grey 100
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color error = Color(0xFFD32F2F); // Red 700
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green 500
  static const Color warning = Color(0xFFFFA000; // Amber 700
  static const Color info = Color(0xFF1976D2); // Blue 700
  
  // Other Colors
  static const Color divider = Color(0xFFE0E0E0); // Grey 300
  static const Color disabled = Color(0xFFBDBDBD); // Grey 400
  static const Color border = Color(0xFFE0E0E0); // Grey 300
  static const Color highlight = Color(0x1F000000); // Black 12%
  static const Color splash = Color(0x1F000000); // Black 12%
  
  // Additional colors from design
  static const Color lightGreen = Color(0xFFE8F5E9); // Green 50
  static const Color lightGrey = Color(0xFFF5F5F5); // Grey 100
  static const Color darkGrey = Color(0xFF424242); // Grey 800
  static const Color lightBlue = Color(0xFFE3F2FD); // Blue 50
  
  // Social Colors
  static const Color facebook = Color(0xFF4267B2);
  static const Color google = Color(0xFFDB4437);
  static const Color apple = Color(0xFF000000);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  // Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
  
  // Text Selection
  static const Color textSelection = Color(0x664CAF50); // Green 500 with 40% opacity
  
  // Disabled Button
  static const Color disabledButton = Color(0xFFE0E0E0); // Grey 300
  static const Color disabledButtonText = Color(0xFF9E9E9E; // Grey 500
  
  // Input Fields
  static const Color inputFill = Color(0xFFFAFAFA); // Grey 50
  static const Color inputBorder = Color(0xFFE0E0E0; // Grey 300
  static const Color inputFocusedBorder = Color(0xFF4CAF50); // Green 500
  static const Color inputErrorBorder = Color(0xFFE53935); // Red 600
  
  // Snackbar
  static const Color snackbarSuccess = Color(0xFF4CAF50); // Green 500
  static const Color snackbarError = Color(0xFFE53935); // Red 600
  static const Color snackbarInfo = Color(0xFF1976D2; // Blue 700
  static const Color snackbarWarning = Color(0xFFFFA000; // Amber 700
  
  // Chip
  static const Color chipBackground = Color(0xFFE8F5E9); // Green 50
  static const Color chipSelectedBackground = Color(0xFF4CAF50); // Green 500
  static const Color chipText = Color(0xFF2E7D32; // Green 800
  static const Color chipSelectedText = Color(0xFFFFFFFF); // White
}
