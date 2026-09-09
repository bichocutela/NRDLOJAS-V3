import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/nrd_theme.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const _currentVersion = '3.4.013';
  static const _latestReleaseApi =
      'https://api.github.com/repos/bichocutela/NRDLOJAS-V3/releases/latest';

  bool _checkingUpdate = true;
  String? _updateError;
  String? _latestVersion;
  String? _releaseName;
  String? _releaseNotes;
  String? _downloadUrl;

  bool get _hasUpdate {
    if (_latestVersion == null) return false;
    return _compareVersions(_latestVersion!, _currentVersion) > 0;
  }

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _checkingUpdate = true;
      _updateError = null;
    });

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(_latestReleaseApi));
      request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      request.headers.set(HttpHeaders.userAgentHeader, 'NRDLOJAS-V3');
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Falha ao consultar atualização (${response.statusCode}).');
      }

      final payload = jsonDecode(await utf8.decodeStream(response)) as Map<String, dynamic>;
      final tag = (payload['tag_name'] as String? ?? '').replaceFirst(RegExp(r'^v'), '');
      final assets = (payload['assets'] as List<dynamic>? ?? const []);
      String? apkUrl;
      for (final item in assets) {
        final asset = item as Map<String, dynamic>;
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _latestVersion = tag.isEmpty ? _currentVersion : tag;
        _releaseName = payload['name'] as String?;
        _releaseNotes = payload['body'] as String?;
        _downloadUrl = apkUrl ?? payload['html_url'] as String?;
        _checkingUpdate = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checkingUpdate = false;
        _updateError = 'Não foi possível verificar agora. Tente novamente quando estiver conectado.';
      });
    } finally {
      client.close(force: true);
    }
  }

  int _compareVersions(String a, String b) {
    List<int> parse(String value) => value
        .split('.')
        .map((part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();

    final aa = parse(a);
    final bb = parse(b);
    final maxLength = aa.length > bb.length ? aa.length : bb.length;
    for (var i = 0; i < maxLength; i++) {
      final av = i < aa.length ? aa[i] : 0;
      final bv = i < bb.length ? bb[i] : 0;
      if (av != bv) return av.compareTo(bv);
    }
    return 0;
  }

  Future<void> _openUpdate() async {
    final raw = _downloadUrl;
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.parse(raw);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final copyright = year <= 2026 ? '2026' : '2026-$year';

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: RefreshIndicator(
        onRefresh: _checkForUpdates,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
          children: [
            GlassSoft(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sobre o Aplicativo', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  const Text(
                    'Este aplicativo foi desenvolvido por Alessandro P., Operador de Caixa, com o objetivo de auxiliar os colaboradores da Frente de Loja na consulta rápida de códigos correlatos, contribuindo para mais agilidade, precisão e eficiência no atendimento aos clientes.\n\n'
                    'O projeto nasceu da vivência diária na operação de caixa e da necessidade de tornar a rotina de trabalho mais prática. Ele é uma ferramenta de apoio operacional interno e não substitui procedimentos, normas, orientações ou sistemas oficiais da empresa.',
                  ),
                  const SizedBox(height: 12),
                  Text('© $copyright Alessandro P. Todos os direitos do aplicativo são reservados ao autor.'),
                  const SizedBox(height: 8),
                  const Text('Versão: $_currentVersion\nDesenvolvedor: Alessandro Paulo\n@bichocutela @haydendanex'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassSoft(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.system_update_alt_rounded),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Atualizações', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      ),
                      IconButton(
                        tooltip: 'Verificar novamente',
                        onPressed: _checkingUpdate ? null : _checkForUpdates,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_checkingUpdate)
                    const Row(
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2)),
                        SizedBox(width: 10),
                        Expanded(child: Text('Verificando se existe uma nova versão...')),
                      ],
                    )
                  else if (_updateError != null)
                    Text(_updateError!)
                  else if (_hasUpdate) ...[
                    Text(
                      'Nova versão disponível: ${_latestVersion ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if ((_releaseName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(_releaseName!),
                    ],
                    if ((_releaseNotes ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _releaseNotes!.trim(),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _downloadUrl == null ? null : _openUpdate,
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Baixar atualização'),
                      ),
                    ),
                  ] else ...[
                    const Text('Você está usando a versão mais recente disponível.'),
                    const SizedBox(height: 4),
                    Text('Versão instalada: $_currentVersion'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassSoft(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Links úteis', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const _InfoLink(label: 'Site', value: 'nordestaomaisvoce.com.br'),
                  const _InfoLink(label: 'App Nossa Gente', value: 'app.nordestao.com.br'),
                  const _InfoLink(label: 'Nordestão Pra Você', value: 'pravoce.nordestao.com.br'),
                  const _InfoLink(label: 'Encarte', value: 'pravoce.nordestao.com.br/tabloids'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassSoft(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instalação e compartilhamento', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Quando uma nova versão estiver publicada no GitHub Releases, a seção Atualizações acima irá indicar e oferecer o APK disponível.'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: FilledButton.icon(onPressed: _checkForUpdates, icon: const Icon(Icons.android), label: const Text('Verificar Android'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.phone_iphone), label: const Text('iPhone'))),
                    ],
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

class _InfoLink extends StatelessWidget {
  const _InfoLink({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const Icon(Icons.link_rounded),
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.open_in_new_rounded),
      onTap: () {},
    );
  }
}
