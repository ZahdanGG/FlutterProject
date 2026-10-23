import 'package:flutter/widgets.dart';
import '../core/services/app_store.dart';

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({
    super.key,
    required AppStore store,
    required super.child,
  }) : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope harus membungkus aplikasi.');
    return scope!.notifier!;
  }
}
