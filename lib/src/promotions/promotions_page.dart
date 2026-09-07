import 'package:flutter/material.dart';

import '../theme/nrd_theme.dart';

class PromotionsLoginPage extends StatefulWidget {
  const PromotionsLoginPage({super.key});

  @override
  State<PromotionsLoginPage> createState() => _PromotionsLoginPageState();
}

class _PromotionsLoginPageState extends State<PromotionsLoginPage> {
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acesso às promoções')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassSoft(
            child: Column(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 52),
                const SizedBox(height: 12),
                Text('Entre com o mesmo acesso do Nossa Gente', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Use seu CPF e sua senha do Nossa Gente. A autenticação real será conectada à camada de serviços migrada do V2.'),
                const SizedBox(height: 16),
                TextField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  decoration: const InputDecoration(labelText: 'CPF', counterText: ''),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PromotionsPage()));
                    },
                    child: const Text('Entrar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  String _query = '';
  String _store = 'Todas';
  String? _category;
  String _sort = 'Adição';

  static const _categories = ['Bebidas', 'Mercearia', 'Limpeza', 'Higiene', 'Frios'];
  static const _stores = ['Todas', 'Loja 01', 'Loja 05', 'Loja 12'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_category ?? 'Promoção'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh_rounded), tooltip: 'Atualizar'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
        children: [
          GlassSoft(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Pesquisar oferta...'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _store,
                        decoration: const InputDecoration(labelText: 'Loja'),
                        items: _stores.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _store = v ?? _store),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sort,
                        decoration: const InputDecoration(labelText: 'Ordenar'),
                        items: const [
                          DropdownMenuItem(value: 'Adição', child: Text('Adição')),
                          DropdownMenuItem(value: 'Nome', child: Text('Nome')),
                          DropdownMenuItem(value: 'Validade', child: Text('Validade')),
                          DropdownMenuItem(value: 'Maior desconto', child: Text('Maior desconto')),
                        ],
                        onChanged: (v) => setState(() => _sort = v ?? _sort),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final value = index == 0 ? null : _categories[index - 1];
                return ChoiceChip(
                  label: Text(value ?? 'Todas'),
                  selected: _category == value,
                  onSelected: (_) => setState(() => _category = value),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          GlassSoft(
            child: Column(
              children: [
                const Icon(Icons.local_offer_outlined, size: 46),
                const SizedBox(height: 10),
                Text('Catálogo de promoções preparado', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  _query.isEmpty
                      ? 'A interface equivalente ao V2 está montada. Falta conectar NossaGenteApi, favoritos, alterações diárias e imagens reais.'
                      : 'Busca preparada para: $_query',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
