import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors read directly from the Figma file.
class AppColors {
  static const background = Color(0xFFFAF8F5);
  static const navy = Color(0xFF002E63);
  static const ink = Color(0xFF18211E);
  static const muted = Color(0xFF737D78);
  static const border = Color(0xFFE5E8E5);
  static const mint = Color(0xFFEEF7F2);
  static const field = Color(0xFFF3F3F2);
  static const green = Color(0xFF18815A);
  static const tabInactive = Color(0xFF9CA3AF);
  static const skyTint = Color(0xFFEEF4FA);
  static const amberText = Color(0xFFB97800);
  static const amberTint = Color(0xFFFFF7E8);
  static const searchHint = Color(0xFF828282);
  static const promoSub = Color(0xFFA6CCBC);

  // Not readable from the Figma data (they live inside SVG assets).
  // Approximated from the Beranda screenshot - see README.
  static const starAmber = Color(0xFFF2A91E);
  static const notifDot = Color(0xFFE5484D);
  static const coffeeTeal = Color(0xFF1B7F8C);
}

/// Inter text style. [height] is a multiplier (Figma 140% -> 1.4); null = auto.
TextStyle inter(double size, FontWeight weight, Color color,
    {double? height}) {
  return GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: 0,
  );
}

const w400 = FontWeight.w400;
const w500 = FontWeight.w500;
const w600 = FontWeight.w600;
const w700 = FontWeight.w700;
const w800 = FontWeight.w800;
