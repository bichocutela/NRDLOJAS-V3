import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'src/about/about_page.dart';
import 'src/home/home_page.dart';
import 'src/promotions/promotions_page.dart';
import 'src/settings/settings_page.dart';
import 'src/theme/nrd_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await rive.RiveNative.init();
  runApp(const NrdV3App());
}

class NrdV3App extends StatelessWidget {
  const NrdV3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NRD Lojas V3',
      theme: NrdTheme.light(),
      darkTheme: NrdTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/promotions': (_) => const PromotionsLoginPage(),
        '/settings': (_) => const SettingsPage(),
        '/about': (_) => const AboutPage(),
      },
    );
  }
}
