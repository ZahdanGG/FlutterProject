import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
  );
}

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed, this.outlined = false, this.loading = false, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool loading;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
        : Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ]);
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: loading ? null : onPressed, child: child)
          : FilledButton(onPressed: loading ? null : onPressed, child: child),
    );
  }
}

class InfoBox extends StatelessWidget {
  const InfoBox(this.message, {super.key, this.icon = Icons.info_outline, this.error = false});
  final String message;
  final IconData icon;
  final bool error;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: error ? c.errorContainer : c.primaryContainer, borderRadius: BorderRadius.circular(10)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: error ? c.onErrorContainer : c.onPrimaryContainer),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: TextStyle(fontSize: 12, height: 1.5, color: error ? c.onErrorContainer : c.onPrimaryContainer))),
      ]),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
    if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!, style: const TextStyle(fontSize: 12))),
  ]);
}

class FoodPhoto extends StatelessWidget {
  const FoodPhoto(this.path, {super.key, this.width, this.height = 150, this.fit = BoxFit.cover, this.radius = 12});
  final String path;
  final double? width;
  final double height;
  final BoxFit fit;
  final double radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(path, width: width, height: height, fit: fit, errorBuilder: (context, error, stack) => Container(
      width: width, height: height, color: Theme.of(context).colorScheme.primaryContainer,
      child: const Center(child: Icon(Icons.restaurant_outlined, size: 36)),
    )),
  );
}

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({super.key, required this.value, required this.onChanged, this.min = 1, this.max = 99});
  final int value, min, max;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    IconButton(onPressed: value > min ? () => onChanged(value - 1) : null, tooltip: 'Kurangi jumlah', icon: const Icon(Icons.remove_circle_outline)),
    SizedBox(width: 24, child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
    IconButton(onPressed: value < max ? () => onChanged(value + 1) : null, tooltip: 'Tambah jumlah', icon: const Icon(Icons.add_circle_outline)),
  ]);
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(24)), child: Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary)),
      const SizedBox(height: 24),
      Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text(message, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
      if (action != null) ...[const SizedBox(height: 28), action!],
    ]),
  );
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmAction(BuildContext context, {required String title, required String message, String confirmLabel = 'Lanjutkan'}) async {
  return await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
    title: Text(title), content: Text(message),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
      FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(confirmLabel)),
    ],
  )) ?? false;
}

Future<void> foundationNotice(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Preview UI'),
    content: const Text('Halaman ini masih dalam tahap pengembangan'),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Oke'))],
  ),
);
