import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/app_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BootstrapApp(store: AppStore()));
}
