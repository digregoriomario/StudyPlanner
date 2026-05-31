part of '../main.dart';

class AppStyle {
  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF8FAFC);
  static const Color ink = Color(0xFF111111);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySoft = Color(0xFFEFF6FF);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerDark = Color(0xFFB91C1C);
  static const Color dangerSoft = Color(0xFFFEF2F2);
  static const Color muted = Color(0xFF8A8A8A);
  static const Color subtle = Color(0xFF5F6368);
  static const Color line = Color(0xFFE2E8F0);
  static const Color lineStrong = Color(0xFFCBD5E1);
  static const Color darkSurface = primaryDark;
  static const Color darkSurfaceSoft = primary;
  static const Color warm = Color(0xFFEFF6FF);
  static const double maxPageWidth = 1240;
  static const double sidebarWidth = 292;
  static const double buttonHeight = 48;
  static const double buttonRadius = 16;

  static BoxShadow get softShadow => BoxShadow(
        color: Colors.black.withValues(alpha: .045),
        blurRadius: 28,
        offset: const Offset(0, 14),
      );

  static BoxShadow get liftShadow => BoxShadow(
        color: Colors.black.withValues(alpha: .075),
        blurRadius: 34,
        offset: const Offset(0, 18),
      );
}

class Responsive {
  static bool mobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 620;
  static bool tablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 980;
}
