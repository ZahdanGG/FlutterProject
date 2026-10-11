import 'package:flutter/material.dart';

import '../core/icons.dart';
import '../core/tokens.dart';
import '../navigation/routes.dart';
import 'common.dart';

enum NavTab { home, orders, browse, me }

/// The Figma frames use two slightly different bottom bars:
/// [home] = Beranda (no top border, 4px shadow, English labels, clipboard/user icons)
/// [standard] = every other frame (1px top border, 8px shadow, house/clipboard-list/user-round).
enum NavStyle { home, standard }

class NavLabels {
  const NavLabels(this.home, this.orders, this.browse, this.me);
  final String home, orders, browse, me;

  static const english = NavLabels('Home', 'Orders', 'Browse', 'Me');
  static const indonesian = NavLabels('Beranda', 'Pesanan', 'Jelajah', 'Saya');
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.active,
    this.style = NavStyle.standard,
    this.labels = NavLabels.english,
    this.shadowAlpha = 0.06,
  });

  final NavTab active;
  final NavStyle style;
  final NavLabels labels;
  final double shadowAlpha;

  @override
  Widget build(BuildContext context) {
    final isHome = style == NavStyle.home;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: isHome ? null : const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, shadowAlpha),
            offset: const Offset(0, -1),
            blurRadius: isHome ? 4 : 8,
          ),
        ],
      ),
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _tab(context, NavTab.home, AppIcons.house, labels.home),
              _tab(context, NavTab.orders,
                  isHome ? AppIcons.clipboard : AppIcons.clipboardList, labels.orders),
              _tab(context, NavTab.browse, AppIcons.search, labels.browse),
              _tab(context, NavTab.me, isHome ? AppIcons.user : AppIcons.userRound, labels.me),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, NavTab tab, IconData icon, String label) {
    final isActive = tab == active;
    final isHome = style == NavStyle.home;
    final color = isActive ? AppColors.navy : AppColors.tabInactive;

    // Beranda: inactive tabs are a bare 22px icon; active tab has the 32px mint tile.
    final Widget iconBox = (isHome && !isActive)
        ? Icon(icon, size: 22, color: color)
        : Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? AppColors.mint : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          );

    return Expanded(
      child: Tappable(
        onTap: isActive ? null : () => Nav.tab(context, tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconBox,
            SizedBox(height: isHome ? 4 : 3),
            Text(label, style: inter(10, isActive ? w700 : w500, color)),
          ],
        ),
      ),
    );
  }
}
