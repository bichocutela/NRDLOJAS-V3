import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'src/about/about_page.dart';
import 'src/home/home_page_v3.dart';
import 'src/motion/nrd_motion.dart';
import 'src/promotions/promotions_page.dart';
import 'src/settings/settings_page.dart';
import 'src/theme/nrd_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Mantém o V3 abrindo em modo local até o host Flutter receber
    // a configuração Firebase nativa correspondente ao projeto.
  }

  await rive.RiveNative.init();
  runApp(const NrdV3App());
}

class NrdV3App extends StatelessWidget {
  const NrdV3App({super.key});

  Route<dynamic>? _route(RouteSettings settings) {
    final builder = switch (settings.name) {
      '/' => (BuildContext context) => const HomePageV3(),
      '/promotions' => (BuildContext context) => const PromotionsLoginPage(),
      '/settings' => (BuildContext context) => const SettingsPage(),
      '/about' => (BuildContext context) => const AboutPage(),
      _ => null,
    };

    if (builder == null) return null;
    return NrdPageRoute<void>(builder: builder);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NRD Lojas V3',
      theme: NrdTheme.light(),
      darkTheme: NrdTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: _route,
    );
  }
}
