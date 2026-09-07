import 'package:flutter/material.dart';

import '../theme/nrd_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _fontScale = 1.0;
  double _barcodeNumberScale = 1.0;
  double _barcodeTitleScale = 1.0;
  double _glassTransparency = .55;
  bool _largeText = false;
  bool _boldOutline = false;
  bool _uppercaseBold = false;
  bool _vibrateOnClick = true;
  bool _vibrateOnFound = true;
  bool _notificationsEnabled = true;
  bool _productNotifications = true;
  bool _codeNotifications = true;
  String _theme = 'glass';
  String _appearance = 'system';
  String _glassAccent = 'multicolor';
  String _glassType = 'soft';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
        children: [
          _SectionCard(
            title: 'Aparência',
            subtitle: 'Fonte, temas, modo de aparência e vibração',
            child: Column(
              children: [
                _SliderSetting(
                  label: 'Tamanho da Fonte',
                  value: _fontScale,
                  min: .8,
                  max: 2,
                  suffix: '${_fontScale.toStringAsFixed(1)}x',
                  onChanged: (v) => setState(() => _fontScale = v),
                ),
                _SliderSetting(
                  label: 'Tamanho do número do código',
                  value: _barcodeNumberScale,
                  min: .8,
                  max: 1.6,
                  suffix: '${_barcodeNumberScale.toStringAsFixed(1)}x',
                  onChanged: (v) => setState(() => _barcodeNumberScale = v),
                ),
                _SliderSetting(
                  label: 'Tamanho do título do produto',
                  value: _barcodeTitleScale,
                  min: .8,
                  max: 1.5,
                  suffix: '${_barcodeTitleScale.toStringAsFixed(1)}x',
                  onChanged: (v) => setState(() => _barcodeTitleScale = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Aumentar letras da tela inicial'),
                  value: _largeText,
                  onChanged: (v) => setState(() => _largeText = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Letras em contorno negrito'),
                  value: _boldOutline,
                  onChanged: (v) => setState(() => _boldOutline = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Todas letras maiúsculas em negrito'),
                  value: _uppercaseBold,
                  onChanged: (v) => setState(() => _uppercaseBold = v),
                ),
                const Divider(),
                DropdownButtonFormField<String>(
                  initialValue: _theme,
                  decoration: const InputDecoration(labelText: 'Tema do Aplicativo'),
                  items: const [
                    DropdownMenuItem(value: 'multicolor', child: Text('Multicolorido')),
                    DropdownMenuItem(value: 'red', child: Text('Vermelho')),
                    DropdownMenuItem(value: 'gold', child: Text('Dourado')),
                    DropdownMenuItem(value: 'green', child: Text('Verde')),
                    DropdownMenuItem(value: 'blue', child: Text('Azul')),
                    DropdownMenuItem(value: 'orange', child: Text('Laranja')),
                    DropdownMenuItem(value: 'glass', child: Text('Glass Soft')),
                  ],
                  onChanged: (v) => setState(() => _theme = v ?? _theme),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _appearance,
                  decoration: const InputDecoration(labelText: 'Modo de aparência'),
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('Seguir sistema')),
                    DropdownMenuItem(value: 'light', child: Text('Claro')),
                    DropdownMenuItem(value: 'dark', child: Text('Escuro')),
                  ],
                  onChanged: (v) => setState(() => _appearance = v ?? _appearance),
                ),
                if (_theme == 'glass') ...[
                  const SizedBox(height: 14),
                  GlassSoft(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Personalizar Glass Soft', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: _glassAccent,
                          decoration: const InputDecoration(labelText: 'Cor do vidro'),
                          items: const [
                            DropdownMenuItem(value: 'multicolor', child: Text('Pastel multicolorido')),
                            DropdownMenuItem(value: 'blue', child: Text('Azul')),
                            DropdownMenuItem(value: 'green', child: Text('Verde')),
                            DropdownMenuItem(value: 'purple', child: Text('Lilás')),
                            DropdownMenuItem(value: 'pink', child: Text('Rosa')),
                            DropdownMenuItem(value: 'orange', child: Text('Laranja')),
                            DropdownMenuItem(value: 'cyan', child: Text('Ciano')),
                          ],
                          onChanged: (v) => setState(() => _glassAccent = v ?? _glassAccent),
                        ),
                        const SizedBox(height: 12),
                        Text('Transparência do vidro: ${(_glassTransparency * 100).round()}%'),
                        Slider(
                          value: _glassTransparency,
                          min: .20,
                          max: .90,
                          onChanged: (v) => setState(() => _glassTransparency = v),
                        ),
                        const SizedBox(height: 4),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'soft', label: Text('Suave')),
                            ButtonSegment(value: 'frosted', label: Text('Fosco')),
                            ButtonSegment(value: 'crystal', label: Text('Cristal')),
                          ],
                          selected: {_glassType},
                          onSelectionChanged: (v) => setState(() => _glassType = v.first),
                        ),
                      ],
                    ),
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vibrar ao tocar'),
                  value: _vibrateOnClick,
                  onChanged: (v) => setState(() => _vibrateOnClick = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vibrar ao encontrar produto'),
                  value: _vibrateOnFound,
                  onChanged: (v) => setState(() => _vibrateOnFound = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Notificações',
            subtitle: 'Controle os avisos recebidos no aplicativo',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ativar notificações'),
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Produto adicionado'),
                  value: _productNotifications,
                  onChanged: _notificationsEnabled ? (v) => setState(() => _productNotifications = v) : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Código alterado'),
                  value: _codeNotifications,
                  onChanged: _notificationsEnabled ? (v) => setState(() => _codeNotifications = v) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Feedback',
            subtitle: 'Sugestões e melhorias',
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lightbulb_outline_rounded),
              label: const Text('Enviar sugestão'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassSoft(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({required this.label, required this.value, required this.min, required this.max, required this.suffix, required this.onChanged});
  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(label)), Text(suffix)]),
          Slider(value: value, min: min, max: max, onChanged: onChanged),
        ],
      ),
    );
  }
}
