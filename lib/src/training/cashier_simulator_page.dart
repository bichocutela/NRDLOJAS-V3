import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CashierSimulatorPage extends StatefulWidget {
  const CashierSimulatorPage({super.key});

  @override
  State<CashierSimulatorPage> createState() => _CashierSimulatorPageState();
}

class _CashierSimulatorPageState extends State<CashierSimulatorPage> {
  static const _flow = <_TrainingStep>[
    _TrainingStep(
      expectedKey: 'ENTRA',
      operatorText: 'FECHADO PARA BALANÇA',
      customerText: 'CAIXA FECHADO',
      instruction: 'Pressione ENTRA para iniciar o treinamento.',
    ),
    _TrainingStep(
      expectedKey: '1',
      operatorText: 'IDENTIFIQUE O OPERADOR',
      customerText: 'AGUARDE...',
      instruction: 'Digite o primeiro número da identificação demonstrativa.',
    ),
    _TrainingStep(
      expectedKey: '2',
      operatorText: 'OPERADOR: 1_',
      customerText: 'AGUARDE...',
      instruction: 'Continue a identificação.',
    ),
    _TrainingStep(
      expectedKey: '3',
      operatorText: 'OPERADOR: 12_',
      customerText: 'AGUARDE...',
      instruction: 'Continue a identificação.',
    ),
    _TrainingStep(
      expectedKey: '4',
      operatorText: 'OPERADOR: 123_',
      customerText: 'AGUARDE...',
      instruction: 'Finalize a identificação demonstrativa.',
    ),
    _TrainingStep(
      expectedKey: 'ENTRA',
      operatorText: 'OPERADOR: 1234',
      customerText: 'AGUARDE...',
      instruction: 'Confirme com ENTRA.',
    ),
    _TrainingStep(
      expectedKey: 'TOTAL',
      operatorText: 'CAIXA ABERTO  TOTAL R$ 18,50',
      customerText: 'TOTAL  R$ 18,50',
      instruction: 'Simule o fechamento da compra pressionando TOTAL.',
    ),
    _TrainingStep(
      expectedKey: 'DINHEIRO',
      operatorText: 'FORMA DE PAGAMENTO',
      customerText: 'TOTAL  R$ 18,50',
      instruction: 'Escolha DINHEIRO.',
    ),
    _TrainingStep(
      expectedKey: 'ENTRA',
      operatorText: 'DINHEIRO  R$ 20,00  TROCO R$ 1,50',
      customerText: 'TROCO  R$ 1,50',
      instruction: 'Confirme a operação com ENTRA.',
    ),
  ];

  int _step = 0;
  int _errors = 0;
  bool _finished = false;
  String _lastKey = '';

  _TrainingStep get _current => _flow[_step.clamp(0, _flow.length - 1)];

  void _press(String key) {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();

    if (_finished) return;

    if (key != _current.expectedKey) {
      setState(() {
        _errors++;
        _lastKey = key;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tecla incorreta. Era esperado: ${_current.expectedKey}.'),
          duration: const Duration(milliseconds: 900),
        ),
      );
      return;
    }

    setState(() {
      _lastKey = key;
      if (_step == _flow.length - 1) {
        _finished = true;
      } else {
        _step++;
      }
    });
  }

  void _reset() {
    setState(() {
      _step = 0;
      _errors = 0;
      _finished = false;
      _lastKey = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinamento de Caixa'),
        actions: [
          IconButton(
            tooltip: 'Reiniciar treinamento',
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final content = [
              Expanded(
                flex: 6,
                child: _SimulatorPanel(
                  operatorText: _finished ? 'ATENDIMENTO CONCLUÍDO' : _current.operatorText,
                  customerText: _finished ? 'OBRIGADO E VOLTE SEMPRE' : _current.customerText,
                  instruction: _finished
                      ? 'Treinamento concluído com $_errors erro(s). Reinicie para tentar novamente.'
                      : _current.instruction,
                  lastKey: _lastKey,
                  progress: (_step + (_finished ? 1 : 0)) / _flow.length,
                  finished: _finished,
                  onReset: _reset,
                ),
              ),
              if (wide) const SizedBox(width: 16) else const SizedBox(height: 16),
              Expanded(
                flex: 5,
                child: _KeyboardPanel(onKey: _press),
              ),
            ];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: wide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: content)
                  : Column(children: content),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Text(
          'Protótipo educativo isolado. As sequências atuais são demonstrativas e podem ser substituídas pelas sequências reais de treinamento.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _SimulatorPanel extends StatelessWidget {
  const _SimulatorPanel({
    required this.operatorText,
    required this.customerText,
    required this.instruction,
    required this.lastKey,
    required this.progress,
    required this.finished,
    required this.onReset,
  });

  final String operatorText;
  final String customerText;
  final String instruction;
  final String lastKey;
  final double progress;
  final bool finished;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Simulador do operador',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _Display(
            title: 'VISOR DO OPERADOR',
            text: operatorText,
            background: const Color(0xFFB7C86A),
            foreground: const Color(0xFF334019),
          ),
          const SizedBox(height: 14),
          _Display(
            title: 'VISOR DO CLIENTE',
            text: customerText,
            background: const Color(0xFF15202A),
            foreground: const Color(0xFFEAF8FF),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          finished ? 'Treinamento concluído' : 'Próximo passo',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(instruction),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(value: progress.clamp(0, 1)),
                  if (lastKey.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Última tecla: $lastKey'),
                  ],
                  if (finished) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: onReset,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Treinar novamente'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display({
    required this.title,
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String title;
  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black26),
            boxShadow: const [
              BoxShadow(blurRadius: 12, offset: Offset(0, 5), color: Colors.black12),
            ],
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              text,
              key: ValueKey(text),
              style: TextStyle(
                color: foreground,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KeyboardPanel extends StatelessWidget {
  const _KeyboardPanel({required this.onKey});

  final ValueChanged<String> onKey;

  static const _leftKeys = [
    ['ANULA', 'CONVÊNIO', 'DINHEIRO'],
    ['TEF', 'SHOW DE PRÊMIOS', 'TOTAL'],
    ['CONS PLUS', 'LIMPA', 'X'],
  ];

  static const _rightKeys = [
    ['DEPÓSITOS', 'DIFERENÇA', 'CRÉDITO MANUAL'],
    ['CASHBACK', 'BOLETO', 'POSIÇÃO OPERADOR'],
    ['REDUÇÃO Z', 'CARTÃO PRESENTE', 'CARTÃO COMPRA'],
    ['PAUSA', 'SANGRIA', 'ENTRADA OPERADOR'],
    ['RECARGA CELULAR', 'SAÍDA OPERADOR', 'ABRE GAVETA'],
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Teclado de treinamento',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        for (final row in _leftKeys)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                for (final key in row)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                      child: _KeyButton(label: key, onTap: () => onKey(key)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: _KeyButton(label: 'FUNÇÃO', onTap: () => onKey('FUNÇÃO')),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: _KeyButton(label: 'ENTRA', onTap: () => onKey('ENTRA'), accent: true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(flex: 3, child: _NumberPad(onKey: onKey)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              for (final row in _rightKeys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      for (final key in row)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _KeyButton(label: key, onTap: () => onKey(key), compact: true),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({required this.onKey});

  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['0', '00', '.'],
    ];

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _KeyButton(label: key, onTap: () => onKey(key), numeric: true),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.onTap,
    this.numeric = false,
    this.compact = false,
    this.accent = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool numeric;
  final bool compact;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: compact ? 48 : 56,
      child: Material(
        color: accent
            ? scheme.primaryContainer
            : numeric
                ? scheme.surfaceContainerHighest
                : scheme.secondaryContainer.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: numeric ? 18 : (compact ? 10 : 11),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrainingStep {
  const _TrainingStep({
    required this.expectedKey,
    required this.operatorText,
    required this.customerText,
    required this.instruction,
  });

  final String expectedKey;
  final String operatorText;
  final String customerText;
  final String instruction;
}
