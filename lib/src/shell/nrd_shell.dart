import 'package:flutter/material.dart';

import '../home/home_page_v3.dart';
import '../training/training_hub_page.dart';

class NrdShell extends StatefulWidget {
  const NrdShell({super.key});

  @override
  State<NrdShell> createState() => _NrdShellState();
}

class _NrdShellState extends State<NrdShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomePageV3(),
          TrainingHubPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Treinamento',
          ),
        ],
      ),
    );
  }
}
