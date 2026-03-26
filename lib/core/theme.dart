import 'package:flutter/material.dart';

/// Configuración de la temática visual de la aplicación (ThemeData).
/// 
/// Actúa como la fuente centralizada de diseño (Design System),
/// asegurando una UI consistente, profesional y vanguardista tanto 
/// en modo claro como oscuro. Implementa Material 3 de forma extendida.
class AppTheme {
  
  // Colores principales definidos para una sensación premium y moderna
  static const Color _primarySeed = Color(0xFF6200EA); // Deep Purple vibrante
  static const Color _secondarySeed = Color(0xFF00BFA5); // Teal accent

  /// Configuración para el modo claro (Light Mode)
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      secondary: _secondarySeed,
      brightness: Brightness.light,
      surfaceTint: Colors.white, // Evitar tintes agresivos en superficies
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Gris extra claro para mayor limpieza
      
      // Configuración de la barra de aplicación (AppBar)
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0, // Evita sombras por defecto al scrollear
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),

      // Configuración de las tarjetas (Cards)
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Bordes bien redondeados y modernos
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Tipografía moderna y espaciada
      textTheme: _buildTextTheme(colorScheme.onSurface),
    );
  }

  /// Configuración para el modo oscuro (Dark Mode)
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      secondary: _secondarySeed,
      brightness: Brightness.dark,
      surfaceTint: const Color(0xFF1E1E1E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212), // Gris muy oscuro, mejor que negro puro
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E), // Superficie ligeramente elevada respecto al fondo
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      textTheme: _buildTextTheme(colorScheme.onSurface),
    );
  }

  /// Construye la tipografía base.
  /// Si estuviésemos usando Google Fonts, aquí anidaríamos `GoogleFonts.interTextTheme()`.
  /// Al no estar configurado, forzamos pesos y espaciados para lograr un look similar.
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1.5),
      displayMedium: TextStyle(fontWeight: FontWeight.w800, color: textColor, letterSpacing: -1.0),
      displaySmall: TextStyle(fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: textColor),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: textColor),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: textColor, fontSize: 16),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: textColor, fontSize: 14),
    );
  }
}
