import 'package:flutter/material.dart';

import '../theme/nrd_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final copyright = year <= 2026 ? '2026' : '2026-$year';

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: ListView(
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
                const Text('Versão: 3.0.0\nDesenvolvedor: Alessandro Paulo\n@bichocutela @haydendanex'),
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
                const Text('A estrutura do V2 para atualização, QR Code e compartilhamento será reconectada quando os serviços nativos do V3 forem ligados ao Flutter.'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.android), label: const Text('Android'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.phone_iphone), label: const Text('iPhone'))),
                  ],
                ),
              ],
            ),
          ),
        ],
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
