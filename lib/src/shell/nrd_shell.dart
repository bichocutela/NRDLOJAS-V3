import 'package:flutter/material.dart';

import '../home/home_page_v3.dart';
import '../training/cashier_simulator_page.dart';

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
          CashierSimulatorPage(),
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
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale_rounded),
            label: 'Treinar Caixa',
          ),
        ],
      ),
    );
  }
}
