import 'package:flutter/material.dart';

/// 🐾 App Colors
class PawsColors {
  // Brand colors
  static const Color primary = Color(0xFFFF7A00); // vibrant orange
  static const Color primaryDark = Color(0xFFE66A00);
  static const Color secondary = Color(0xFF4E342E); // brown (earthy, pet vibe)
  static const Color accent = Color(0xFFFFC107); // amber for highlights

  // Background
  static const Color background = Color(0xFFF7F7F7); // 👈 Greyish white
  static const Color surface = Colors.white;
  static const Color backgroundDark = Color(0xFF121212);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textLight = Color(0xFFFFFFFF);

  // States
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  // Neutrals
  static const Color border = Color(0xFFDDDDDD);
  static const Color disabled = Color(0xFFBDBDBD);
}

class PawsTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: PawsColors.primary,
    iconTheme: const IconThemeData(color: PawsColors.primary),
    scaffoldBackgroundColor: PawsColors.background,
    colorScheme: const ColorScheme.light(
      primary: PawsColors.primary,
      secondary: PawsColors.secondary,
      surface: Colors.white,
      error: PawsColors.error,
      onPrimary: PawsColors.textLight,
      onSecondary: PawsColors.textLight,
      onSurface: PawsColors.textPrimary,
      onError: PawsColors.textLight,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: PawsColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: PawsColors.textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: PawsColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: PawsColors.textSecondary),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: PawsColors.textPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PawsColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PawsColors.primary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PawsColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PawsColors.primary,
        side: const BorderSide(color: PawsColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PawsColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: PawsColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: PawsColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: PawsColors.textPrimary),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      modalBackgroundColor: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      modalBarrierColor: Colors.black54,
      showDragHandle: true,
      dragHandleColor: Colors.grey.shade400,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: const BoxConstraints(maxWidth: double.infinity),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: PawsColors.primaryDark,
    scaffoldBackgroundColor: PawsColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: PawsColors.primary,
      secondary: PawsColors.secondary,
      surface: Color(0xFF1E1E1E),
      error: PawsColors.error,
      onPrimary: PawsColors.textLight,
      onSecondary: PawsColors.textLight,
      onSurface: Colors.white,
      onError: PawsColors.textLight,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
    ),
  );
}

/// 🎨 Utility class for consistent bottom sheet styling
class PawsBottomSheet {
  /// Creates a styled bottom sheet container
  static Widget container({
    required Widget child,
    String? title,
    VoidCallback? onClose,
    List<Widget>? actions,
    EdgeInsets? padding,
    bool showDragHandle = true,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PawsColors.disabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

            // Header
            if (title != null || actions != null || onClose != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: PawsColors.textPrimary,
                          ),
                        ),
                      ),
                    if (actions != null) ...actions,
                  ],
                ),
              ),

            // Content
            Flexible(
              child: Padding(
                padding: padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show a styled modal bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    Color? backgroundColor,
    EdgeInsets? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => container(
        title: title,
        actions: actions,
        showDragHandle: showDragHandle,
        backgroundColor: backgroundColor,
        padding: padding,
        onClose: () => Navigator.of(context).pop(),
        child: child,
      ),
    );
  }

  /// Creates a gradient background sheet (premium look)
  static Widget gradientContainer({
    required Widget child,
    String? title,
    VoidCallback? onClose,
    List<Widget>? actions,
    EdgeInsets? padding,
    bool showDragHandle = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            PawsColors.primary.withValues(alpha: 0.02),
            PawsColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: PawsColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle with gradient
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [PawsColors.primary, PawsColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

            // Header
            if (title != null || actions != null || onClose != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: PawsColors.textPrimary,
                          ),
                        ),
                      ),
                    if (actions != null) ...actions,
                    if (onClose != null)
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          foregroundColor: PawsColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

            // Content
            Flexible(
              child: Padding(
                padding: padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
