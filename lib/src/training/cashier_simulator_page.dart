import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TrainingMode { aprender, prova, livre }
enum TrainingMission { abertura, vendaDinheiro, vendaCartao, cancelarItem, sangria, fechamento }

class CashierSimulatorPage extends StatefulWidget {
  const CashierSimulatorPage({super.key});

  @override
  State<CashierSimulatorPage> createState() => _CashierSimulatorPageState();
}

class _CashierSimulatorPageState extends State<CashierSimulatorPage> {
  static const missions = <TrainingMission, _Mission>{
    TrainingMission.abertura: _Mission(
      title: 'Abrir caixa',
      subtitle: 'Identificação e início do atendimento',
      icon: Icons.login_rounded,
      steps: [
        _Step('ENTRA', 'FECHADO PARA BALANÇA', 'CAIXA FECHADO', 'Pressione ENTRA para iniciar.'),
        _Step('1', 'IDENTIFIQUE O OPERADOR', 'AGUARDE...', 'Digite o primeiro número demonstrativo.'),
        _Step('2', 'OPERADOR: 1_', 'AGUARDE...', 'Continue a identificação.'),
        _Step('3', 'OPERADOR: 12_', 'AGUARDE...', 'Continue a identificação.'),
        _Step('4', 'OPERADOR: 123_', 'AGUARDE...', 'Finalize a identificação demonstrativa.'),
        _Step('ENTRA', 'OPERADOR: 1234', 'AGUARDE...', 'Confirme com ENTRA.'),
      ],
    ),
    TrainingMission.vendaDinheiro: _Mission(
      title: 'Venda em dinheiro',
      subtitle: 'Finalização, pagamento e troco',
      icon: Icons.payments_outlined,
      steps: [
        _Step('TOTAL', 'COMPRA R$ 18,50', 'TOTAL R$ 18,50', 'Pressione TOTAL.'),
        _Step('DINHEIRO', 'FORMA DE PAGAMENTO', 'TOTAL R$ 18,50', 'Escolha DINHEIRO.'),
        _Step('2', 'VALOR RECEBIDO: 2_', 'AGUARDE...', 'Digite um valor demonstrativo.'),
        _Step('0', 'VALOR RECEBIDO: 20_', 'AGUARDE...', 'Continue o valor.'),
        _Step('ENTRA', 'DINHEIRO R$ 20,00', 'TROCO R$ 1,50', 'Confirme com ENTRA.'),
      ],
    ),
    TrainingMission.vendaCartao: _Mission(
      title: 'Venda no cartão',
      subtitle: 'Fluxo demonstrativo de pagamento TEF',
      icon: Icons.credit_card_rounded,
      steps: [
        _Step('TOTAL', 'COMPRA R$ 42,90', 'TOTAL R$ 42,90', 'Pressione TOTAL.'),
        _Step('TEF', 'SELECIONE PAGAMENTO', 'AGUARDE O CARTÃO', 'Pressione TEF.'),
        _Step('ENTRA', 'TEF EM TREINAMENTO', 'INSIRA/APROXIME CARTÃO', 'Confirme a etapa demonstrativa.'),
      ],
    ),
    TrainingMission.cancelarItem: _Mission(
      title: 'Cancelar item',
      subtitle: 'Treino de correção durante a compra',
      icon: Icons.remove_shopping_cart_outlined,
      steps: [
        _Step('CANC ITEM', 'ITEM SELECIONADO', 'AGUARDE...', 'Pressione CANC ITEM.'),
        _Step('1', 'INFORME ITEM: _', 'AGUARDE...', 'Digite o número demonstrativo do item.'),
        _Step('ENTRA', 'ITEM 1 SELECIONADO', 'AGUARDE...', 'Confirme com ENTRA.'),
      ],
    ),
    TrainingMission.sangria: _Mission(
      title: 'Sangria',
      subtitle: 'Treino isolado da função de retirada',
      icon: Icons.account_balance_wallet_outlined,
      steps: [
        _Step('SANGRIA', 'SANGRIA', 'AGUARDE...', 'Pressione SANGRIA.'),
        _Step('1', 'VALOR: 1_', 'AGUARDE...', 'Digite um valor demonstrativo.'),
        _Step('0', 'VALOR: 10_', 'AGUARDE...', 'Continue o valor.'),
        _Step('ENTRA', 'SANGRIA R$ 10,00', 'AGUARDE...', 'Confirme com ENTRA.'),
      ],
    ),
    TrainingMission.fechamento: _Mission(
      title: 'Encerrar operação',
      subtitle: 'Sequência demonstrativa de saída',
      icon: Icons.logout_rounded,
      steps: [
        _Step('SAÍDA OPERADOR', 'SAÍDA DO OPERADOR', 'CAIXA EM ENCERRAMENTO', 'Pressione SAÍDA OPERADOR.'),
        _Step('ENTRA', 'CONFIRMAR SAÍDA?', 'AGUARDE...', 'Confirme com ENTRA.'),
      ],
    ),
  };

  TrainingMode mode = TrainingMode.aprender;
  TrainingMission selectedMission = TrainingMission.abertura;
  int step = 0;
  int errors = 0;
  bool finished = false;
  String operatorFree = 'FECHADO PARA BALANÇA';
  String customerFree = 'CAIXA FECHADO';
  final List<String> history = [];
  final Set<TrainingMission> completed = {};

  _Mission get mission => missions[selectedMission]!;
  List<_Step> get flow => mission.steps;
  _Step get current => flow[step >= flow.length ? flow.length - 1 : step];

  void resetState() {
    step = 0;
    errors = 0;
    finished = false;
    operatorFree = 'FECHADO PARA BALANÇA';
    customerFree = 'CAIXA FECHADO';
    history.clear();
  }

  void reset() => setState(resetState);

  void changeMode(TrainingMode value) {
    setState(() {
      mode = value;
      resetState();
    });
  }

  void changeMission(TrainingMission value) {
    setState(() {
      selectedMission = value;
      mode = TrainingMode.aprender;
      resetState();
    });
  }

  String normalizeKey(String key) => key.replaceAll('\n', ' ').trim();

  void press(String rawKey) {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
    final key = normalizeKey(rawKey);
    if (key.isEmpty) return;

    if (mode == TrainingMode.livre) {
      setState(() {
        history.insert(0, key);
        if (history.length > 8) history.removeLast();
        if (key == 'ENTRA') {
          operatorFree = 'ENTRA';
          customerFree = 'AGUARDE...';
        } else if (key == 'TOTAL') {
          operatorFree = 'TOTAL DA COMPRA';
          customerFree = 'TOTAL R$ 0,00';
        } else if (key == 'DINHEIRO') {
          operatorFree = 'PAGAMENTO EM DINHEIRO';
          customerFree = 'DINHEIRO';
        } else if (key == 'TEF') {
          operatorFree = 'PAGAMENTO TEF';
          customerFree = 'AGUARDE O CARTÃO';
        } else if (key == 'ANULA' || key == 'VOLTA') {
          operatorFree = 'ANULA / VOLTA';
          customerFree = 'AGUARDE...';
        } else {
          operatorFree = 'TECLA: $key';
          customerFree = 'OPERAÇÃO EM TREINAMENTO';
        }
      });
      return;
    }

    if (finished) return;
    if (key != current.expected) {
      setState(() {
        errors++;
        history.insert(0, '✕ $key');
        if (history.length > 8) history.removeLast();
      });
      if (mode == TrainingMode.prova) {
        final savedErrors = errors;
        setState(() {
          resetState();
          errors = savedErrors;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errou a sequência. A prova voltou ao início.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tente a tecla ${current.expected}.')),
        );
      }
      return;
    }

    setState(() {
      history.insert(0, '✓ $key');
      if (history.length > 8) history.removeLast();
      if (step == flow.length - 1) {
        finished = true;
        completed.add(selectedMission);
      } else {
        step++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final operatorText = mode == TrainingMode.livre
        ? operatorFree
        : finished
            ? 'MISSÃO CONCLUÍDA'
            : current.operatorText;
    final customerText = mode == TrainingMode.livre
        ? customerFree
        : finished
            ? 'TREINAMENTO CONCLUÍDO'
            : current.customerText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinar Caixa'),
        actions: [
          IconButton(onPressed: reset, tooltip: 'Reiniciar', icon: const Icon(Icons.restart_alt_rounded)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _MissionStrip(
              selected: selectedMission,
              completed: completed,
              onSelected: changeMission,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
              child: SegmentedButton<TrainingMode>(
                segments: const [
                  ButtonSegment(value: TrainingMode.aprender, icon: Icon(Icons.school_outlined), label: Text('Aprender')),
                  ButtonSegment(value: TrainingMode.prova, icon: Icon(Icons.assignment_turned_in_outlined), label: Text('Prova')),
                  ButtonSegment(value: TrainingMode.livre, icon: Icon(Icons.sports_esports_outlined), label: Text('Livre')),
                ],
                selected: {mode},
                onSelectionChanged: (v) => changeMode(v.first),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final info = _InfoPanel(
                    mission: mission,
                    operatorText: operatorText,
                    customerText: customerText,
                    mode: mode,
                    current: current,
                    step: step,
                    totalSteps: flow.length,
                    errors: errors,
                    finished: finished,
                    history: history,
                    onReset: reset,
                  );
                  final keyboard = _KeyboardPanel(onKey: press);
                  if (c.maxWidth >= 900) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(flex: 5, child: info),
                          const SizedBox(width: 12),
                          Expanded(flex: 7, child: keyboard),
                        ],
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    children: [info, const SizedBox(height: 12), keyboard, const SizedBox(height: 20)],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionStrip extends StatelessWidget {
  const _MissionStrip({required this.selected, required this.completed, required this.onSelected});
  final TrainingMission selected;
  final Set<TrainingMission> completed;
  final ValueChanged<TrainingMission> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        scrollDirection: Axis.horizontal,
        itemCount: _CashierSimulatorPageState.missions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = _CashierSimulatorPageState.missions.entries.elementAt(index);
          final active = entry.key == selected;
          final done = completed.contains(entry.key);
          return SizedBox(
            width: 158,
            child: Card(
              elevation: active ? 3 : 0,
              color: active ? Theme.of(context).colorScheme.primaryContainer : null,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelected(entry.key),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(done ? Icons.check_circle_rounded : entry.value.icon),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.value.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 2),
                            Text(entry.value.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.mission, required this.operatorText, required this.customerText, required this.mode, required this.current, required this.step, required this.totalSteps, required this.errors, required this.finished, required this.history, required this.onReset});
  final _Mission mission;
  final String operatorText;
  final String customerText;
  final TrainingMode mode;
  final _Step current;
  final int step;
  final int totalSteps;
  final int errors;
  final bool finished;
  final List<String> history;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final free = mode == TrainingMode.livre;
    final exam = mode == TrainingMode.prova;
    final stars = errors == 0 ? 3 : errors <= 2 ? 2 : 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Icon(mission.icon),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(mission.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                Text(mission.subtitle, style: Theme.of(context).textTheme.bodySmall),
              ])),
              if (!free) Chip(label: Text('Erros: $errors')),
            ]),
            const SizedBox(height: 12),
            _Display(title: 'VISOR DO OPERADOR', text: operatorText, operator: true),
            const SizedBox(height: 12),
            _Display(title: 'VISOR DO CLIENTE', text: customerText, operator: false),
            const SizedBox(height: 14),
            if (!free) ...[
              LinearProgressIndicator(value: finished ? 1 : step / totalSteps),
              const SizedBox(height: 10),
              Text(
                finished
                    ? 'Missão concluída: ${List.filled(stars, '★').join()}${List.filled(3 - stars, '☆').join()}'
                    : exam
                        ? 'Faça a sequência sem ajuda. Um erro reinicia esta missão.'
                        : current.instruction,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (!finished && !exam) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Próxima tecla: ${current.expected}')),
              if (finished) Padding(padding: const EdgeInsets.only(top: 10), child: FilledButton.icon(onPressed: onReset, icon: const Icon(Icons.replay_rounded), label: const Text('Treinar novamente'))),
            ] else
              const Text('Explore livremente as teclas e observe a reação dos dois visores.'),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 5, runSpacing: 5, children: history.take(6).map((e) => Chip(label: Text(e))).toList()),
            ],
            const SizedBox(height: 8),
            Text('Sequências demonstrativas para teste da interface. Substituir pelos procedimentos reais validados da loja.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display({required this.title, required this.text, required this.operator});
  final String title;
  final String text;
  final bool operator;

  @override
  Widget build(BuildContext context) {
    final bg = operator ? const Color(0xFFC8D77D) : const Color(0xFF101820);
    final fg = operator ? const Color(0xFF526126) : const Color(0xFFE8F8FF);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        constraints: BoxConstraints(minHeight: operator ? 72 : 82),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(operator ? 5 : 8),
          border: Border.all(color: Colors.black87, width: 3),
          boxShadow: const [BoxShadow(blurRadius: 7, offset: Offset(0, 2), color: Colors.black26)],
        ),
        alignment: Alignment.centerLeft,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 130),
          child: Text(
            text,
            key: ValueKey(text),
            style: TextStyle(fontFamily: 'monospace', fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1, color: fg),
          ),
        ),
      ),
    ]);
  }
}

class _KeyboardPanel extends StatelessWidget {
  const _KeyboardPanel({required this.onKey});
  final ValueChanged<String> onKey;

  Widget button(String label, Color color, {double height = 45, double font = 10, Color foreground = const Color(0xFF263238)}) {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: SizedBox(
        height: height,
        child: Material(
          elevation: label.isEmpty ? 0 : 3,
          color: label.isEmpty ? const Color(0xFF252525) : color,
          borderRadius: BorderRadius.circular(3),
          child: InkWell(
            onTap: label.isEmpty ? null : () => onKey(label),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(border: Border.all(color: Colors.black87, width: 1.3), borderRadius: BorderRadius.circular(3)),
              child: Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: font, height: 1, fontWeight: FontWeight.w800, color: foreground)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFFA8D8B0);
    const yellow = Color(0xFFFFD928);
    const blue = Color(0xFF79C6E7);
    const dark = Color(0xFF655C56);
    const blueRows = [
      ['DEPÓSITOS\nBANCÁRIOS', '', 'CASHBACK', 'REDUÇÃO\nZ'],
      ['DIFERENÇA\nDE PREÇO', 'BOLETO', 'CARTÃO\nPRESENTE', 'PAUSA'],
      ['CRÉDITO\nMANUAL', 'POSIÇÃO\nOPERADOR', 'CARTÃO\nCOMPRA', 'RECARGA\nCELULAR'],
      ['SANGRIA', 'ENTRADA\nOPERADOR', 'SAÍDA\nOPERADOR', ''],
      ['ENTRA', 'ABRE\nGAVETA', 'CANC\nITEM', 'CANC\nCUPOM'],
    ];
    const nums = [['7', '8', '9'], ['4', '5', '6'], ['1', '2', '3'], ['', '0', '.']];

    return Card(
      color: const Color(0xFF3B3B3B),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 7, child: Column(children: [
              Row(children: [Expanded(child: button('ANULA', green)), Expanded(child: button('', green)), Expanded(child: button('CONS\nPLUS', green))]),
              Row(children: [Expanded(child: button('CONVÊNIO\nNORDESTÃO', green)), Expanded(child: button('TEF', green)), Expanded(child: button('LIMPA', green))]),
              Row(children: [Expanded(child: button('', green)), Expanded(child: button('SHOW DE\nPRÊMIOS', green)), Expanded(child: button('', green))]),
              Row(children: [Expanded(child: button('TROCA DE\nMERCADORIA', green)), Expanded(child: button('', green)), Expanded(child: button('X', green))]),
              Row(children: [Expanded(child: button('FUNÇÃO', green)), Expanded(child: button('DINHEIRO', green)), Expanded(child: button('TOTAL', green))]),
            ])),
            const SizedBox(width: 6),
            Expanded(flex: 4, child: Column(children: [
              Row(children: [Expanded(child: button('VOLTA', yellow)), Expanded(child: button('ENTRA', yellow))]),
              for (final row in nums) Row(children: [for (final n in row) Expanded(child: button(n, dark, font: 17, foreground: Colors.white))]),
            ])),
          ]),
          const SizedBox(height: 7),
          for (final row in blueRows) Row(children: [for (final item in row) Expanded(child: button(item, blue, height: 43, font: 9))]),
        ]),
      ),
    );
  }
}

class _Mission {
  const _Mission({required this.title, required this.subtitle, required this.icon, required this.steps});
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_Step> steps;
}

class _Step {
  const _Step(this.expected, this.operatorText, this.customerText, this.instruction);
  final String expected;
  final String operatorText;
  final String customerText;
  final String instruction;
}
