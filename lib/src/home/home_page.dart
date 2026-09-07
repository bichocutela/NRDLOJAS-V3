import 'package:flutter/material.dart';

import '../theme/nrd_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _categories = [
    ('Hortifruti', Icons.eco_outlined),
    ('Padaria', Icons.bakery_dining_outlined),
    ('Açougue', Icons.restaurant_outlined),
    ('Higiene', Icons.sanitizer_outlined),
    ('Limpeza', Icons.local_laundry_service_outlined),
    ('Peixaria', Icons.set_meal_outlined),
  ];

  static const _mostUsed = [
    _Product('7891000100103', 'Leite Integral', 'Mercearia'),
    _Product('7894900011517', 'Refrigerante 2L', 'Bebidas'),
    _Product('7896004400917', 'Arroz 1kg', 'Mercearia'),
    _Product('7891021000208', 'Café 250g', 'Mercearia'),
  ];

  static const _latest = [
    _Product('7890000000011', 'Produto adicionado recentemente', 'Novidades'),
    _Product('7890000000028', 'Novo item de catálogo', 'Novidades'),
    _Product('7890000000035', 'Produto atualizado', 'Novidades'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const _NrdDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB9DEFA),
              Color(0xFFCBEFD9),
              Color(0xFFDCCBFF),
              Color(0xFFF8CFE7),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(onMenu: _openDrawer)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _showSearch(context),
                        decoration: InputDecoration(
                          hintText: 'Pesquisar produto...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: IconButton(
                            tooltip: 'Pesquisar por voz',
                            onPressed: () {},
                            icon: const Icon(Icons.mic_none_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () => _showSearch(context),
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('Pesquisar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(
                child: _Section(
                  title: 'Categorias',
                  child: SizedBox(
                    height: 92,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = _categories[index];
                        return _CategoryChip(label: item.$1, icon: item.$2);
                      },
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: _Section(
                  title: 'Mais Utilizados',
                  action: 'VER TODOS',
                  onAction: () {},
                  child: SizedBox(
                    height: 136,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _mostUsed.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) => _MiniProductCard(product: _mostUsed[index]),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: _Section(
                  title: 'Últimos Adicionados',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        for (final product in _latest) ...[
                          _ProductRow(product: product),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: _Section(
                  title: 'Histórico Recente',
                  action: 'LIMPAR',
                  onAction: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ProductRow(product: _mostUsed.first),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: _Section(
                  title: 'Meus Favoritos',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ProductRow(product: _mostUsed[1], favorite: true),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _showSearch(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pesquisar Produtos', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              controller: _searchController,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Nome ou código'),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onMenu});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: Container(
          height: MediaQuery.sizeOf(context).width / 3,
          constraints: const BoxConstraints(minHeight: 126),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7EDFF), Color(0xFFE0F6E8), Color(0xFFE7DDFF)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('NRD', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                    Text('Códigos Correlatos', style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: IconButton.filledTonal(onPressed: onMenu, icon: const Icon(Icons.menu_rounded)),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Badge(
                    label: const Text('3'),
                    child: IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.action, this.onAction});

  final String title;
  final Widget child;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
              if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: GlassSoft(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        radius: 22,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon), const SizedBox(height: 6), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)],
        ),
      ),
    );
  }
}

class _MiniProductCard extends StatelessWidget {
  const _MiniProductCard({required this.product});

  final _Product product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
      child: GlassSoft(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.inventory_2_outlined),
            const Spacer(),
            Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(product.code, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, this.favorite = false});

  final _Product product;
  final bool favorite;

  @override
  Widget build(BuildContext context) {
    return GlassSoft(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${product.category} • ${product.code}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(favorite ? Icons.favorite : Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _NrdDrawer extends StatelessWidget {
  const _NrdDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('NRD Lojas V3', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 18),
            const ListTile(leading: Icon(Icons.local_offer_outlined), title: Text('Promoções')),
            const ListTile(leading: Icon(Icons.settings_outlined), title: Text('Configurações')),
            const ListTile(leading: Icon(Icons.info_outline), title: Text('Sobre')),
            const Divider(),
            const ListTile(leading: Icon(Icons.admin_panel_settings_outlined), title: Text('Área Administrativa')),
          ],
        ),
      ),
    );
  }
}

class _Product {
  const _Product(this.code, this.name, this.category);

  final String code;
  final String name;
  final String category;
}
