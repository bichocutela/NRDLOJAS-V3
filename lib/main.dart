import 'package:flutter/material.dart';

import 'src/home/home_page.dart';
import 'src/theme/nrd_theme.dart';

void main() {
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
      home: const HomePage(),
    );
  }
}
