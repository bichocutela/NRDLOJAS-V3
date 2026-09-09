import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TrainingMode { aprender, prova, livre }

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

  TrainingMode _mode = TrainingMode.aprender;
  int _step = 0;
  int _errors = 0;
  bool _finished = false;
  String _lastKey = '';
  String _freeOperator = 'FECHADO PARA BALANÇA';
  String _freeCustomer = 'CAIXA FECHADO';
  final List<String> _history = [];

  _TrainingStep get _current => _flow[_step.clamp(0, _flow.length - 1)];

  void _setMode(TrainingMode mode) {
    setState(() {
      _mode = mode;
      _resetState();
    });
  }

  void _resetState() {
    _step = 0;
    _errors = 0;
    _finished = false;
    _lastKey = '';
    _freeOperator = 'FECHADO PARA BALANÇA';
    _freeCustomer = 'CAIXA FECHADO';
    _history.clear();
  }

  void _reset() => setState(_resetState);

  void _press(String key) {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();

    if (_mode == TrainingMode.livre) {
      _pressFree(key);
      return;
    }
    if (_finished) return;

    if (key != _current.expectedKey) {
      setState(() {
        _errors++;
        _lastKey = key;
        _history.insert(0, '✕ $key');
        if (_history.length > 8) _history.removeLast();
      });

      if (_mode == TrainingMode.prova) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sequência incorreta. A prova voltou ao início.'),
            duration: Duration(milliseconds: 1200),
          ),
        );
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          setState(() {
            final errors = _errors;
            _resetState();
            _errors = errors;
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Essa tecla não é a próxima. Tente ${_current.expectedKey}.'),
            duration: const Duration(milliseconds: 950),
          ),
        );
      }
      return;
    }

    setState(() {
      _lastKey = key;
      _history.insert(0, '✓ $key');
      if (_history.length > 8) _history.removeLast();
      if (_step == _flow.length - 1) {
        _finished = true;
      } else {
        _step++;
      }
    });
  }

  void _pressFree(String key) {
    setState(() {
      _lastKey = key;
      _history.insert(0, key);
      if (_history.length > 8) _history.removeLast();

      switch (key) {
        case 'ENTRA':
          _freeOperator = 'ENTRA';
          _freeCustomer = 'AGUARDE...';
          break;
        case 'TOTAL':
          _freeOperator = 'TOTAL DA COMPRA';
          _freeCustomer = 'TOTAL  R$ 0,00';
          break;
        case 'DINHEIRO':
          _freeOperator = 'PAGAMENTO EM DINHEIRO';
          _freeCustomer = 'DINHEIRO';
          break;
        case 'TEF':
          _freeOperator = 'PAGAMENTO TEF';
          _freeCustomer = 'AGUARDE O CARTÃO';
          break;
        case 'ANULA':
          _freeOperator = 'ANULA / VOLTA';
          _freeCustomer = 'AGUARDE...';
          break;
        case 'LIMPA':
          _freeOperator = 'CAMPO LIMPO';
          break;
        default:
          _freeOperator = 'TECLA: $key';
          _freeCustomer = 'OPERAÇÃO EM TREINAMENTO';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final operatorText = _mode == TrainingMode.livre
        ? _freeOperator
        : (_finished ? 'ATENDIMENTO CONCLUÍDO' : _current.operatorText);
    final customerText = _mode == TrainingMode.livre
        ? _freeCustomer
        : (_finished ? 'OBRIGADO E VOLTE SEMPRE' : _current.customerText);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinar Caixa'),
        actions: [
          IconButton(
            tooltip: 'Reiniciar',
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: SegmentedButton<TrainingMode>(
                    segments: const [
                      ButtonSegment(
                        value: TrainingMode.aprender,
                        icon: Icon(Icons.school_outlined),
                        label: Text('Aprender'),
                      ),
                      ButtonSegment(
                        value: TrainingMode.prova,
                        icon: Icon(Icons.timer_outlined),
                        label: Text('Prova'),
                      ),
                      ButtonSegment(
                        value: TrainingMode.livre,
                        icon: Icon(Icons.sports_esports_outlined),
                        label: Text('Livre'),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (value) => _setMode(value.first),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _InfoPanel(
                                  operatorText: operatorText,
                                  customerText: customerText,
                                  mode: _mode,
                                  current: _current,
                                  step: _step,
                                  errors: _errors,
                                  finished: _finished,
                                  history: _history,
                                  onReset: _reset,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 7,
                                child: _KeyboardPanel(onKey: _press),
                              ),
                            ],
                          )
                        : ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _InfoPanel(
                                operatorText: operatorText,
                                customerText: customerText,
                                mode: _mode,
                                current: _current,
                                step: _step,
                                errors: _errors,
                                finished: _finished,
                                history: _history,
                                onReset: _reset,
                              ),
                              const SizedBox(height: 12),
                              _KeyboardPanel(onKey: _press),
                              const SizedBox(height: 16),
                            ],
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.operatorText,
    required this.customerText,
    required this.mode,
    required this.current,
    required this.step,
    required this.errors,
    required this.finished,
    required this.history,
    required this.onReset,
  });

  final String operatorText;
  final String customerText;
  final TrainingMode mode;
  final _TrainingStep current;
  final int step;
  final int errors;
  final bool finished;
  final List<String> history;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final isFree = mode == TrainingMode.livre;
    final isExam = mode == TrainingMode.prova;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(isFree ? Icons.sports_esports : isExam ? Icons.assignment_turned_in_outlined : Icons.school_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isFree ? 'Caixa Livre' : isExam ? 'Modo Prova' : 'Modo Aprender',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                if (!isFree)
                  Chip(label: Text('Erros: $errors')),
              ],
            ),
            const SizedBox(height: 12),
            _OperatorDisplay(text: operatorText),
            const SizedBox(height: 12),
            _CustomerDisplay(text: customerText),
            const SizedBox(height: 14),
            if (!isFree) ...[
              LinearProgressIndicator(value: finished ? 1 : (step / _CashierSimulatorPageState._flow.length)),
              const SizedBox(height: 10),
              Text(
                finished
                    ? 'Treinamento concluído. Você teve $errors erro(s).'
                    : isExam
                        ? 'Faça a sequência sem ajuda. Um erro reinicia a operação.'
                        : current.instruction,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (!finished && !isExam) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.touch_app_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text('Próxima tecla: ${current.expectedKey}'),
                  ],
                ),
              ],
              if (finished) ...[
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Treinar novamente'),
                ),
              ],
            ] else ...[
              const Text('Toque livremente nas teclas para conhecer o teclado e observar a reação dos visores.'),
            ],
            if (history.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Últimas teclas', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: history.take(6).map((item) => Chip(label: Text(item))).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OperatorDisplay extends StatelessWidget {
  const _OperatorDisplay({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VISOR DO OPERADOR', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFC8D77D),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFF4B5036), width: 3),
            boxShadow: const [BoxShadow(blurRadius: 7, color: Colors.black26, inset: true)],
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: Text(
              text,
              key: ValueKey(text),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Color(0xFF526126),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomerDisplay extends StatelessWidget {
  const _CustomerDisplay({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VISOR DO CLIENTE', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF101820),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black87, width: 3),
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: Text(
              text,
              key: ValueKey(text),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE8F8FF),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF3B3B3B),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(flex: 7, child: _FunctionBlock(onKey: onKey)),
                const SizedBox(width: 8),
                Expanded(flex: 4, child: _NumberBlock(onKey: onKey)),
              ],
            ),
            const SizedBox(height: 9),
            _BlueBlock(onKey: onKey),
          ],
        ),
      ),
    );
  }
}

class _FunctionBlock extends StatelessWidget {
  const _FunctionBlock({required this.onKey});
  final ValueChanged<String> onKey;

  Widget key(String label, {double h = 46, Color? color}) => Padding(
        padding: const EdgeInsets.all(2.5),
        child: _KeyButton(label: label, onTap: () => onKey(label), height: h, color: color ?? const Color(0xFFA8D8B0)),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [Expanded(child: key('ANULA')), Expanded(child: key('')), Expanded(child: key('CONS\nPLUS'))]),
        Row(children: [Expanded(child: key('CONVÊNIO\nNORDESTÃO')), Expanded(child: key('TEF')), Expanded(child: key('LIMPA', h: 94))]),
        Row(children: [Expanded(child: key('')), Expanded(child: key('SHOW DE\nPRÊMIOS'))]),
        Row(children: [Expanded(child: key('TROCA DE\nMERCADORIA')), Expanded(child: key('')), Expanded(child: key('X'))]),
        Row(children: [Expanded(child: key('FUNÇÃO')), Expanded(child: key('DINHEIRO')), Expanded(child: key('TOTAL'))]),
      ],
    );
  }
}

class _NumberBlock extends StatelessWidget {
  const _NumberBlock({required this.onKey});
  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    Widget number(String label) => Padding(
          padding: const EdgeInsets.all(2.5),
          child: _KeyButton(
            label: label,
            onTap: () => onKey(label),
            height: 44,
            color: const Color(0xFF655C56),
            foreground: Colors.white,
            fontSize: 17,
          ),
        );

    return Column(
      children: [
        Row(children: [Expanded(child: _KeyButton(label: 'VOLTA', onTap: () => onKey('VOLTA'), height: 44, color: const Color(0xFFFFD928))), const SizedBox(width: 5), Expanded(child: _KeyButton(label: 'ENTRA', onTap: () => onKey('ENTRA'), height: 44, color: const Color(0xFFFFD928)))]),
        const SizedBox(height: 4),
        for (final row in const [
          ['7', '8', '9'],
          ['4', '5', '6'],
          ['1', '2', '3'],
          ['', '0', '.'],
        ])
          Row(children: [for (final item in row) Expanded(child: number(item))]),
      ],
    );
  }
}

class _BlueBlock extends StatelessWidget {
  const _BlueBlock({required this.onKey});
  final ValueChanged<String> onKey;

  static const rows = [
    ['DEPÓSITOS\nBANCÁRIOS', '', 'CASHBACK', 'REDUÇÃO\nZ'],
    ['DIFERENÇA\nDE PREÇO', 'BOLETO', 'CARTÃO\nPRESENTE', 'PAUSA'],
    ['CRÉDITO\nMANUAL', 'POSIÇÃO\nOPERADOR', 'CARTÃO\nCOMPRA', 'RECARGA\nCELULAR'],
    ['SANGRIA', 'ENTRADA\nOPERADOR', 'SAÍDA\nOPERADOR', ''],
    ['ENTRA', 'ABRE\nGAVETA', 'CANC\nITEM', 'CANC\nCUPOM'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Row(
            children: [
              for (final item in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: _KeyButton(
                      label: item,
                      onTap: () => onKey(item),
                      height: 44,
                      color: const Color(0xFF79C6E7),
                      fontSize: 9.5,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.onTap,
    required this.height,
    required this.color,
    this.foreground = const Color(0xFF263238),
    this.fontSize = 10.5,
  });

  final String label;
  final VoidCallback onTap;
  final double height;
  final Color color;
  final Color foreground;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final disabled = label.isEmpty;
    return SizedBox(
      height: height,
      child: Material(
        color: disabled ? const Color(0xFF252525) : color,
        elevation: disabled ? 0 : 3,
        borderRadius: BorderRadius.circular(3),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 1.4),
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: fontSize,
                height: 1.0,
                fontWeight: FontWeight.w800,
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
