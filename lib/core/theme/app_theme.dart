import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Semantic colors used by widgets. Keep color decisions here so screens do
  // not depend on raw Colors.* or Color(...) values.
  static const Color black = Color(0xFF000000);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color black87 = Color(0xDE000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black38 = Color(0x61000000);
  static const Color black12 = Color(0x1F000000);
  static const Color transparent = Color(0x00000000);
  static const Color warning = Color(0xFFF59E0B);
  static const Color appointmentGoldFade = Color.fromRGBO(226, 232, 240, 0.6);
  static const Color appointmentCream = Color.fromRGBO(243, 237, 226, 1.0);
  static const Color appointmentPast =Color.fromRGBO(226, 232, 240, 1);
  static const Color color_00F1F5F9 = Color(0x00F1F5F9);
  static const Color color_00FFFFFF = Color(0x00FFFFFF);
  static const Color color_26287FF0 = Color(0x26287FF0);
  static const Color color_33000000 = Color(0x33000000);
  static const Color color_4DFFFFFF = Color(0x4DFFFFFF);
  static const Color color_FF0056B3 = Color(0xFF0056B3);
  static const Color color_FF00A86B = Color(0xFF00A86B);
  static const Color color_FF00A878 = Color(0xFF00A878);
  static const Color color_FF00B27A = Color(0xFF00B27A);
  static const Color color_FF0A0D12 = Color(0xFF0A0D12);
  static const Color color_FF0F172A = Color(0xFF0F172A);
  static const Color color_FF101828 = Color(0xFF101828);
  static const Color color_FF111827 = Color(0xFF111827);
  static const Color color_FF15985B = Color(0xFF15985B);
  static const Color color_FF172033 = Color(0xFF172033);
  static const Color color_FF198C72 = Color(0xFF198C72);
  static const Color color_FF1C8AFF = Color(0xFF1C8AFF);
  static const Color color_FF1D1816 = Color(0xFF1D1816);
  static const Color color_FF1E293B = Color(0xFF1E293B);
  static const Color color_FF1E9389 = Color(0xFF1E9389);
  static const Color color_FF1F2937 = Color(0xFF1F2937);
  static const Color color_FF287FF0 = Color(0xFF287FF0);
  static const Color color_FF2B7FFF = Color(0xFF2B7FFF);
  static const Color color_FF2F80ED = Color(0xFF2F80ED);
  static const Color color_FF2F80FF = Color(0xFF2F80FF);
  static const Color color_FF2F9BFF = Color(0xFF2F9BFF);
  static const Color color_FF31527A = Color(0xFF31527A);
  static const Color color_FF333333 = Color(0xFF333333);
  static const Color color_FF334155 = Color(0xFF334155);
  static const Color color_FF344054 = Color(0xFF344054);
  static const Color color_FF374151 = Color(0xFF374151);
  static const Color color_FF3E9B6B = Color(0xFF3E9B6B);
  static const Color color_FF40DB93 = Color(0xFF40DB93);

  static const Color color_FFECFDF5 = Color(0xFFECFDF5);
  static const Color color_FF009966 = Color(0xFF009966);

  static const Color color_FF444444 = Color(0xFF444444);
  static const Color color_FF475467 = Color(0xFF475467);
  static const Color color_FF475569 = Color(0xFF475569);
  static const Color color_FF4B5563 = Color(0xFF4B5563);
  static const Color color_FF51A2FF = Color(0xFF51A2FF);
  static const Color color_FF52CFC4 = Color(0xFF52CFC4);
  static const Color color_FF5A6275 = Color(0xFF5A6275);
  static const Color color_FF5B4F4B = Color(0xFF5B4F4B);
  static const Color color_FF64748B = Color(0xFF64748B);
  static const Color color_FF67B4FF = Color(0xFF67B4FF);
  static const Color color_FF69AFFF = Color(0xFF69AFFF);
  static const Color color_FF777777 = Color(0xFF777777);
  static const Color color_FF8392A7 = Color(0xFF8392A7);
  static const Color color_FFBEDBFF = Color(0xFFBEDBFF);
  static const Color color_FFCA9D38 = Color(0xFF009689);
  static const Color color_FFCBD5E1 = Color(0xFFCBD5E1);
  static const Color color_FFCE040E = Color(0xFFCE040E);
  static const Color color_FFD0D8E5 = Color(0xFFD0D8E5);
  static const Color color_FFD1D5DB = Color(0xFFD1D5DB);
  static const Color color_FFD8B26E = Color(0xFF2B7FFF);
  static const Color color_FFD9B875 = Color(0xFF2B7FFF);
  static const Color color_FFDC2626 = Color(0xFFDC2626);
  static const Color color_FFDCE3EC = Color(0xFFDCE3EC);
  static const Color color_FFDCE8EF = Color(0xFFDCE8EF);
  static const Color color_FFE0E7EF = Color(0xFFE0E7EF);
  static const Color color_FFE17100 = Color(0xFFE17100);
  static const Color color_FFE2E8F0 = Color(0xFFE2E8F0);
  static const Color color_FFE3BE71 = Color(0xFFE3BE71);
  static const Color color_FFE3E9DC = Color(0xFFE3E9DC);
  static const Color color_FFE4E8EE = Color(0xFFE4E8EE);
  static const Color color_FFE4EAF1 = Color(0xFFE4EAF1);
  static const Color color_FFE5EDF5 = Color(0xFFE5EDF5);
  static const Color color_FFE6EAEE = Color(0xFFE6EAEE);
  static const Color color_FFE7000B = Color(0xFFE7000B);
  static const Color color_FFE7E2DE = Color(0xFFE2E8F0);
  static const Color color_FFE8E4E3 = Color(0xFFE8E4E3);
  static const Color color_FFE8EEF5 = Color(0xFFE8EEF5);
  static const Color color_FFE8F2FF = Color(0xFFE8F2FF);
  static const Color color_FFE8FFF5 = Color(0xFFE8FFF5);
  static const Color color_FFEAF0F7 = Color(0xFFEAF0F7);
  static const Color color_FFEAF3FF = Color(0xFFEAF3FF);
  static const Color color_FFECE8E4 = Color(0xFFE2E8F0);
  static const Color color_FFECECEC = Color(0xFFECECEC);
  static const Color color_FFEFF6FF = Color(0xFFEFF6FF);
  static const Color color_FFF00012 = Color(0xFFF00012);
  static const Color color_FFF0F0F0 = Color(0xFFF0F0F0);
  static const Color color_FFF1F1F3 = Color(0xFFF1F1F3);
  static const Color color_FFF1F5F9 = Color(0xFFF1F5F9);
  static const Color color_FFF1F6FC = Color(0xFFF1F6FC);
  static const Color color_FFF2F2F2 = Color(0xFFF2F2F2);
  static const Color color_FFF2F6FA = Color(0xFFF2F6FA);
  static const Color color_FFF3F1F1 = Color(0xFFF3F1F1);
  static const Color color_FFF3F3F5 = Color(0xFFF3F3F5);
  static const Color color_FFF4F4F4 = Color(0xFFF1F5F9);
  static const Color color_FFF4F8FE = Color(0xFFF4F8FE);
  static const Color color_FFF59E0B = Color(0xFFF59E0B);
  static const Color color_FFF5F5F5 = Color(0xFFF5F5F5);
  static const Color color_FFF5F6F8 = Color(0xFFF5F6F8);
  static const Color color_FFF7F5F4 = Color(0xFFF8FAFC);
  static const Color color_FFF8F7F6 = Color(0xFFF8F7F6);
  static const Color color_FFF8F9FA = Color(0xFFF8F9FA);
  static const Color color_FFF8FAFC = Color(0xFFF8FAFC);
  static const Color color_FFF9FAFB = Color(0xFFF9FAFB);
  static const Color color_FFFAF9F8 = Color(0xFFF8FAFC);
  static const Color color_FFFB2C36 = Color(0xFFFB2C36);
  static const Color color_FFFBFAF9 = Color(0xFFF8FAFC);
  static const Color color_FFFCFBFA = Color(0xFFFCFBFA);
  static const Color color_FFFEF2F2 = Color(0xFFFEF2F2);
  static const Color color_FFFF0000 = Color(0xFFFF0000);
  static const Color color_FFFF666D = Color(0xFFFF666D);
  static const Color color_FFFFBA00 = Color(0xFFFFBA00);
  static const Color color_FFFFE2E2 = Color(0xFFFFE2E2);
  static const Color color_FFFFEEA0 = Color(0xFFFFEEA0);
  static const Color color_FFFFFBF1 = Color(0xFFFFFBF1);
  static const Color color_FFFFFFE8 = Color(0xFFFFFFE8);
  static const Color color_FFFFFFFF = Color(0xFFFFFFFF);
  static const Color color_00000000 = Color(0x00000000);
  static const Color color_1F000000 = Color(0x1F000000);
  static const Color color_3DFFFFFF = Color(0x3DFFFFFF);
  static const Color color_61000000 = Color(0x61000000);
  static const Color color_8A000000 = Color(0x8A000000);
  static const Color color_B3FFFFFF = Color(0xB3FFFFFF);
  static const Color color_DE000000 = Color(0xDE000000);
  static const Color color_FF000000 = Color(0xFF000000);
  static const Color color_FF0B5DB5 = Color(0xFF0B5DB5);
  static const Color color_FF121212 = Color(0xFF121212);
  static const Color color_FF16A36D = Color(0xFF16A36D);
  static const Color color_FF1E1E1E = Color(0xFF1E1E1E);
  static const Color color_FF222222 = Color(0xFF222222);
  static const Color color_FF555555 = Color(0xFF555555);
  static const Color color_FF999999 = Color(0xFF999999);
  static const Color color_FFD3A944 = Color(0xFFD3A944);
  static const Color color_FFD64545 = Color(0xFFD64545);
  static const Color color_FFE0B75E = Color(0xFFE0B75E);
  static const Color color_FFE7F1FF = Color(0xFFE7F1FF);
  static const Color color_FFF1F1F1 = Color(0xFFF1F1F1);
  static const Color color_FFF2F0EE = Color(0xFFF2F0EE);
  static const Color color_FFF5F8FF = Color(0xFFF5F8FF);
  static const Color color_FFFFB900 = Color(0xFFFFB900);
  static const Color primaryBlue = Color(0xFF0056B3);
  static const Color primaryBlueDark = Color(0xFF0B5DB5);
  static const Color primaryGold = Color(0xFF2B7FFF);
  static const Color buttonGold = Color(0xFF2B7FFF);
  static const Color secondaryBlue = Color(0xFFE7F1FF);
  static const Color backgroundWhite = Color(0xFFF5F8FF);
  static const Color pageBackground = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF2F0EE);
  static const Color tagBackground = Color(0xFFF1F5F9);
  static const Color avatarBackground = Color(0xFFE5EDF5);
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textMuted = Color(0xFF334155);
  static const Color textLight = Color(0xFF999999);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF16A36D);
  static const Color star = Color(0xFFFFB900);
  static const Color danger = Color(0xFFD64545);
  static const Color textChoco = Color(0xff475569);
  static const TextStyle titleBold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: pageBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: backgroundWhite,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: surface,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: surface,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: surface,
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        labelStyle: GoogleFonts.inter(),
        hintStyle: GoogleFonts.inter(color: Colors.grey),
      ),
    );
  }
}
