import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../data/catalog.dart';
import '../navigation/routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';

/// Figma frame "Semua Menu" (1:464).
class SemuaMenuScreen extends StatefulWidget {
  const SemuaMenuScreen({super.key});

  @override
  State<SemuaMenuScreen> createState() => _SemuaMenuScreenState();
}

class _SemuaMenuScreenState extends State<SemuaMenuScreen> {
  static const _chips = [
    ('🍽️', 'Semua'),
    ('🍗', 'Ayam'),
    ('🐟', 'Ikan'),
    ('🥚', 'Telor'),
    ('🍜', 'Mie'),
    ('🍚', 'Nasi'),
    ('🍟', 'Snack'),
    ('🥤', 'Minuman'),
  ];

  String _category = 'Semua';
  String _query = '';

  List<MenuItem> get _visible => kMenuGrid.where((m) {
        final inCategory = _category == 'Semua' || m.categories.contains(_category);
        final q = _query.trim().toLowerCase();
        final matches = q.isEmpty ||
            m.name.toLowerCase().contains(q) ||
            m.tags.toLowerCase().contains(q);
        return inCategory && matches;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    final left = <MenuItem>[];
    final right = <MenuItem>[];
    for (var i = 0; i < items.length; i++) {
      (i.isEven ? left : right).add(items[i]);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  PageHeader(
                    title: 'Semua Menu',
                    height: 48,
                    hPad: 24,
                    titleWeight: w400,
                    leading: RoundIconButton(
                      icon: AppIcons.chevronLeft,
                      iconSize: 19,
                      onTap: () => Nav.back(context),
                    ),
                    trailing: const RoundIconButton(
                      icon: AppIcons.slidersHorizontal,
                      iconSize: 17,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _searchField(),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final c in _chips)
                                CategoryChip(
                                  emoji: c.$1,
                                  label: c.$2,
                                  selected: _category == c.$2,
                                  padH: 12,
                                  labelWeight: w400,
                                  onTap: () => setState(() => _category = c.$2),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('Semua Makanan', style: inter(18, w700, AppColors.ink)),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _column(left)),
                              const SizedBox(width: 12),
                              Expanded(child: _column(right)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const AppBottomNav(
            active: NavTab.browse,
            labels: NavLabels.indonesian,
          ),
        ],
      ),
    );
  }

  Widget _searchField() => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(AppIcons.search, size: 20, color: AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: inter(16, w400, AppColors.ink, height: 1.5),
                decoration: InputDecoration.collapsed(
                  hintText: 'Cari makanan atau restoran',
                  hintStyle: inter(16, w400, AppColors.muted, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _column(List<MenuItem> items) => Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _foodCard(items[i]),
          ],
        ],
      );

  Widget _foodCard(MenuItem m) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(24, 33, 30, 0.04),
              offset: Offset(0, 5),
              blurRadius: 14,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 132,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(child: FoodImage(m.image!)),
                  if (m.badge != null)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.93),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(m.badge!, style: inter(10, w700, AppColors.ink)),
                      ),
                    ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: HeartBadge(id: m.id, size: 30, glyphSize: 17, alpha: 0.93),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name, style: inter(15, w700, AppColors.ink)),
                  const SizedBox(height: 6),
                  Text(m.tags, style: inter(12, w400, AppColors.muted)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('★ ${m.rating}', style: inter(12, w400, AppColors.ink)),
                      Text(m.time!, style: inter(11, w400, AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_rp(m.price), style: inter(14, w400, AppColors.navy)),
                ],
              ),
            ),
          ],
        ),
      );

  String _rp(int v) => rupiah(v);
}
