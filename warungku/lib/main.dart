import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/tokens.dart';
import 'navigation/routes.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.load();
  runApp(ChangeNotifierProvider<AppState>.value(
    value: state,
    child: const WarungkuApp(),
  ));
}

class WarungkuApp extends StatelessWidget {
  const WarungkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warungku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: AppColors.background
      ),
      // The Figma frames are 412px wide. On wide screens (web/desktop preview)
      // keep the app at the design width instead of stretching the layout.
      builder: (context, child) => LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth <= 480) return child!;
          return ColoredBox(
            color: const Color(0xFFE9E7E3),
            child: Center(
              child: SizedBox(width: 412, child: ClipRect(child: child!)),
            ),
          );
        },
      ),
      home: AppScreen.beranda.build(),
    );
  }
}