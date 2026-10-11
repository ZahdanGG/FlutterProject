import 'package:flutter/material.dart';

import '../core/icons.dart';
import '../core/tokens.dart';
import '../data/catalog.dart';
import '../navigation/routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';

/// Figma frame "Beranda" (1:335). Offsets below (e.g. the banner starting at
/// x=18, the recommendation cards at x=33/37) are the exact values from Figma.
class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String _category = 'All';

  static const _chips = [
    ('🍽️', 'All'),
    ('🍗', 'Ayam'),
    ('🐟', 'Ikan'),
    ('🥚', 'Telor'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _deliveryHeader(),
                    const SizedBox(height: 24),
                    _searchPill(context),
                    const SizedBox(height: 24),
                    _categoryChips(context),
                    const SizedBox(height: 24),
                    _dailyBanner(context),
                    const SizedBox(height: 24),
                    _sectionHeader('History', 24, 24,
                        () => Nav.push(context, AppScreen.riwayat)),
                    const SizedBox(height: 16),
                    _orderAgain(),
                    const SizedBox(height: 24),
                    _sectionHeader('Rekomendasi', 24, 16,
                        () => Nav.push(context, AppScreen.rekomendasi)),
                    const SizedBox(height: 16),
                    _paketHemat(),
                    const SizedBox(height: 10),
                    _nasiGorengKampung(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          const AppBottomNav(
            active: NavTab.home,
            style: NavStyle.home,
            labels: NavLabels.english,
          ),
        ],
      ),
    );
  }

  // ---- top ------------------------------------------------------------------

  Widget _deliveryHeader() => Padding(
        padding: const EdgeInsets.only(left: 24, right: 17),
        child: SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('📍', style: inter(14, w400, Colors.black)),
                  const SizedBox(width: 6),
                  Text('Jakarta Barat', style: inter(16, w700, AppColors.ink)),
                  const SizedBox(width: 6),
                  const Icon(AppIcons.chevronDown, size: 16, color: AppColors.ink),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 8,
                      top: 7,
                      child: Text('🔔', style: inter(16, w400, AppColors.navy)),
                    ),
                    Positioned(
                      left: 20,
                      top: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.notifDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _searchPill(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Tappable(
          onTap: () => Nav.push(context, AppScreen.semuaMenu),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(AppIcons.search, size: 22, color: AppColors.muted),
                const SizedBox(width: 8),
                Text('Search', style: inter(16, w400, AppColors.searchHint, height: 1.5)),
              ],
            ),
          ),
        ),
      );

  Widget _categoryChips(BuildContext context) => Padding(
        // Figma: container at x=14 + first chip at x=24 -> 38.
        padding: const EdgeInsets.only(left: 38),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < _chips.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                CategoryChip(
                  emoji: _chips[i].$1,
                  label: _chips[i].$2,
                  selected: _category == _chips[i].$2,
                  borderWhenSelected: false,
                  onTap: () {
                    if (_chips[i].$2 == 'All') {
                      // Only the "All" chip has a prototype link in Figma.
                      setState(() => _category = 'All');
                      Nav.push(context, AppScreen.semuaMenu);
                    } else {
                      setState(() => _category = _chips[i].$2);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      );

  // ---- banner ---------------------------------------------------------------

  Widget _dailyBanner(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 18, right: 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 180,
            color: AppColors.navy,
            child: Stack(
              children: [
                Positioned(
                  left: 231,
                  top: 0,
                  bottom: 0,
                  width: 140,
                  child: FoodImage(imgPromoSalad),
                ),
                Positioned(
                  left: 16,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(AppIcons.zap, size: 10, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('DAILY LOGIN', style: inter(10, w700, Colors.white)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 37,
                  width: 199,
                  child: Text(
                    'Kumpulkan Poin dan dapatkan diskon kupon',
                    style: inter(22, w800, Colors.white, height: 1.15),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 116,
                  width: 199,
                  child: Text(
                    'dapatkan diskon hingga 100%',
                    style: inter(12, w500, AppColors.promoSub),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 137,
                  child: Tappable(
                    onTap: () => Nav.push(context, AppScreen.detailPromo),
                    child: Container(
                      width: 103,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('Claim now', style: inter(13, w700, AppColors.navy)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ---- history / recommendations ------------------------------------------

  Widget _sectionHeader(String title, double left, double right, VoidCallback onSeeAll) =>
      Padding(
        padding: EdgeInsets.only(left: left, right: right),
        child: SizedBox(
          height: 22,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: inter(18, w700, AppColors.ink)),
              Tappable(
                onTap: onSeeAll,
                child: Text('See all', style: inter(14, w600, AppColors.navy)),
              ),
            ],
          ),
        ),
      );

  Widget _orderAgain() {
    Widget item(Widget tileChild, Color bg, String label) => SizedBox(
          width: 64,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: tileChild,
              ),
              const SizedBox(height: 8),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: inter(12, w500, AppColors.muted)),
            ],
          ),
        );

    Widget letter(String l, Color c) => Text(l, style: inter(22, w700, c));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item(letter('NP', const Color(0xFFB63C15)), const Color(0xFFFEF2EC), 'Nasi Paket'),
          item(letter('S', const Color(0xFF126A3A)), AppColors.mint, 'Susu'),
          item(const Icon(AppIcons.coffee, size: 24, color: AppColors.coffeeTeal),
              const Color(0xFFEAF6F7), 'Kopi'),
          item(letter('M', const Color(0xFFC79600)), const Color(0xFFFFF9EC), 'Mie'),
          item(letter('J', const Color(0xFF9F1F1F)), const Color(0xFFFFF0F1), 'Jus'),
        ],
      ),
    );
  }

  Widget _rating(String value) => SizedBox(
        width: 40,
        child: Row(
          children: [
            const Icon(AppIcons.star, size: 14, color: AppColors.starAmber),
            const SizedBox(width: 4),
            Text(value, style: inter(14, w600, AppColors.ink)),
          ],
        ),
      );

  Widget _paketHemat() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 37),
            child: SizedBox(
              width: 342,
              height: 160,
              child: Stack(
                children: [
                  FoodImage(imgPaketHemat, radius: 16, width: 342, height: 160),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      width: 88,
                      height: 27,
                      padding: const EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.92),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          Text('🔥', style: inter(12, w400, Colors.black)),
                          const SizedBox(width: 2),
                          Text('Trending', style: inter(12, w600, AppColors.ink)),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 298,
                    top: 12,
                    child: HeartBadge(id: 'paket-hemat', size: 32, glyphSize: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 33, right: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paket Hemat', style: inter(16, w700, AppColors.ink)),
                _rating('4.8'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 33),
            child: Text('Nasi • Ayam • 5 min', style: inter(13, w400, AppColors.muted)),
          ),
        ],
      );

  Widget _nasiGorengKampung() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 33),
            child: FoodImage(imgNasiGorengKampung, radius: 16, width: 346, height: 165),
          ),
          const SizedBox(height: 17),
          Padding(
            padding: const EdgeInsets.only(left: 33, right: 29),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nasi Goreng Kampung', style: inter(16, w700, AppColors.ink)),
                _rating('4.6'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text('Nasi • Ayam • Sosis • 10-15 min',
                style: inter(13, w400, AppColors.muted)),
          ),
        ],
      );
}
