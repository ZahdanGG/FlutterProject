import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../state/app_state.dart';

/// Tap target without ripple (Figma defines no pressed state).
class Tappable extends StatelessWidget {
  const Tappable({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      );
}

/// White circle with 1px border (header back / action buttons).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton(
      {super.key, required this.icon, required this.iconSize, this.onTap});
  final IconData icon;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tappable(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: iconSize, color: AppColors.ink),
        ),
      );
}

/// "Header halaman": leading / centered title / trailing (36px slots).
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.height = 52,
    this.hPad = 20,
    this.titleWeight = w700,
  });
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final double hPad;
  final FontWeight titleWeight;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              leading ?? const SizedBox(width: 36, height: 36),
              Text(title, style: inter(20, titleWeight, AppColors.ink)),
              trailing ?? const SizedBox(width: 36, height: 36),
            ],
          ),
        ),
      );
}

/// White card with 1px border (radius 16 by default).
class CardBox extends StatelessWidget {
  const CardBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.color = Colors.white,
    this.borderColor = AppColors.border,
    this.borderWidth = 1,
  });
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: borderWidth > 0 ? Border.all(color: borderColor, width: borderWidth) : null,
        ),
        child: child,
      );
}

/// Food photo with a neutral fallback if the asset file is missing.
class FoodImage extends StatelessWidget {
  const FoodImage(this.asset, {super.key, this.radius = 0, this.height, this.width});
  final String asset;
  final double radius;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          width: width,
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.field),
          ),
        ),
      );
}

/// Translucent white circle with a ♡ / ♥ glyph that toggles favorite state.
class HeartBadge extends StatelessWidget {
  const HeartBadge({
    super.key,
    required this.id,
    required this.size,
    required this.glyphSize,
    this.alpha = 0.92,
  });
  final String id;
  final double size;
  final double glyphSize;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final fav = context.select<AppState, bool>((s) => s.isFavorite(id));
    return Tappable(
      onTap: () => context.read<AppState>().toggleFavorite(id),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, alpha),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Text(fav ? '♥' : '♡', style: inter(glyphSize, w400, AppColors.ink)),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
    this.padH = 14,
    this.labelWeight = w600,
    this.borderWhenSelected = true,
  });
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double padH;
  final FontWeight labelWeight;
  final bool borderWhenSelected;

  @override
  Widget build(BuildContext context) {
    final showBorder = !selected || borderWhenSelected;
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: showBorder
              ? Border.all(color: selected ? AppColors.navy : AppColors.border)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: inter(14, w400, Colors.black)),
            const SizedBox(width: 6),
            Text(label,
                style: inter(13, labelWeight, selected ? Colors.white : AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

/// Navy (filled) or white (outlined) 50px button, radius 16.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.outlined = false,
  });
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final fg = outlined ? AppColors.navy : Colors.white;
    return Tappable(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: outlined ? Colors.white : AppColors.navy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: outlined ? AppColors.border : AppColors.navy),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
            ],
            Text(label, style: inter(14, w700, fg)),
          ],
        ),
      ),
    );
  }
}

/// "Aksi bawah": total on the left, primary button on the right.
class TotalActionBar extends StatelessWidget {
  const TotalActionBar({
    super.key,
    required this.total,
    required this.buttonLabel,
    required this.onTap,
    this.shadowAlpha = 0.1,
    this.safeBottom = false,
  });
  final int total;
  final String buttonLabel;
  final VoidCallback onTap;
  final double shadowAlpha;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, shadowAlpha),
            offset: const Offset(0, -1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total', style: inter(11, w400, AppColors.muted)),
                const SizedBox(height: 2),
                Text(rupiah(total), style: inter(15, w700, AppColors.ink)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: PrimaryButton(label: buttonLabel, onTap: onTap)),
        ],
      ),
    );
    return safeBottom
        ? ColoredBox(color: Colors.white, child: SafeArea(top: false, child: bar))
        : bar;
  }
}

/// "Baris rincian": label left, value right.
class DetailRow extends StatelessWidget {
  const DetailRow(this.label, this.value, {super.key, this.valueColor = AppColors.ink});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: inter(13, w400, AppColors.muted)),
          Text(value, style: inter(13, w600, valueColor)),
        ],
      );
}

class TotalRow extends StatelessWidget {
  const TotalRow(this.value, {super.key});
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: inter(15, w700, AppColors.ink)),
          Text(value, style: inter(15, w700, AppColors.ink)),
        ],
      );
}

class Divider1 extends StatelessWidget {
  const Divider1({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, width: double.infinity, color: AppColors.border);
}

/// "Alamat pengantaran" card shared by Order and Checkout.
class AddressCard extends StatelessWidget {
  const AddressCard({super.key});

  @override
  Widget build(BuildContext context) => CardBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(AppIcons.mapPin, size: 17, color: AppColors.navy),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jakarta Barat', style: inter(14, w700, AppColors.ink)),
                        const SizedBox(height: 2),
                        Text('Rumah', style: inter(12, w600, AppColors.green)),
                      ],
                    ),
                  ],
                ),
                Text('Ubah', style: inter(13, w700, AppColors.navy)),
              ],
            ),
            const SizedBox(height: 12),
            Text('Jl. Contoh No. 123, Jakarta Barat',
                style: inter(13, w400, AppColors.muted, height: 1.4)),
          ],
        ),
      );
}
