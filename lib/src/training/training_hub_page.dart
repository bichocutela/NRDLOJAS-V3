import 'package:flutter/material.dart';

import 'cashier_simulator_page.dart';

class TrainingHubPage extends StatelessWidget {
  const TrainingHubPage({super.key});

  void _openSimulator(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CashierSimulatorPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academia NRD'),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: .72),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.point_of_sale_rounded, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Treinamento de Caixa',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Aprenda a posição das teclas e pratique operações em um ambiente simulado.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openSimulator(context),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text('Abrir simulador'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Como funciona',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const _TrainingCard(
              icon: Icons.school_outlined,
              title: 'Modo Aprender',
              text: 'O aplicativo informa o próximo passo e a tecla esperada. Ideal para o primeiro contato com o teclado.',
            ),
            const SizedBox(height: 10),
            const _TrainingCard(
              icon: Icons.assignment_turned_in_outlined,
              title: 'Modo Prova',
              text: 'A ajuda some. O operador precisa lembrar a sequência e um erro reinicia a missão atual.',
            ),
            const SizedBox(height: 10),
            const _TrainingCard(
              icon: Icons.sports_esports_outlined,
              title: 'Caixa Livre',
              text: 'Permite explorar as teclas sem roteiro e observar a resposta dos visores de operador e cliente.',
            ),
            const SizedBox(height: 20),
            Text(
              'Roteiro de prática',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const _Roadmap(),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Esta versão é educativa e isolada do PDV real. As sequências atuais são demonstrativas até os procedimentos verdadeiros serem validados e cadastrados.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  const _TrainingCard({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Roadmap extends StatelessWidget {
  const _Roadmap();

  static const _items = [
    ('1', 'Abrir caixa', Icons.login_rounded),
    ('2', 'Venda em dinheiro', Icons.payments_outlined),
    ('3', 'Venda no cartão', Icons.credit_card_rounded),
    ('4', 'Cancelar item', Icons.remove_shopping_cart_outlined),
    ('5', 'Sangria', Icons.account_balance_wallet_outlined),
    ('6', 'Encerrar operação', Icons.logout_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            for (var i = 0; i < _items.length; i++) ...[
              ListTile(
                leading: CircleAvatar(
                  child: Text(_items[i].$1),
                ),
                title: Text(
                  _items[i].$2,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                trailing: Icon(_items[i].$3),
              ),
              if (i != _items.length - 1) const Divider(height: 1, indent: 72),
            ],
          ],
        ),
      ),
    );
  }
}
