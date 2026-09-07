import 'package:flutter/material.dart';

import '../theme/nrd_theme.dart';

class HomePageV3 extends StatefulWidget {
  const HomePageV3({super.key});

  @override
  State<HomePageV3> createState() => _HomePageV3State();
}

class _HomePageV3State extends State<HomePageV3> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  String _query = '';

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
            colors: [Color(0xFFB9DEFA), Color(0xFFCBEFD9), Color(0xFFDCCBFF), Color(0xFFF8CFE7)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onNotifications: _showNotifications,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) => setState(() => _query = value),
                        onSubmitted: (_) => _showSearch(),
                        decoration: InputDecoration(
                          hintText: 'Pesquisar produto...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: const Icon(Icons.clear_rounded),
                                )
                              : IconButton(
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
                          onPressed: _showSearch,
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
                      itemBuilder: (_, index) {
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
                  onAction: () => _showProducts('Mais Utilizados', _mostUsed),
                  child: SizedBox(
                    height: 136,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _mostUsed.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, index) => _MiniProductCard(product: _mostUsed[index]),
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
                      children: [for (final product in _latest) ...[_ProductRow(product: product), const SizedBox(height: 8)]],
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

  void _showSearch() {
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
            const SizedBox(height: 12),
            Text('A busca real será ligada ao catálogo migrado do V2.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notificações', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              SizedBox(height: 12),
              ListTile(leading: Icon(Icons.new_releases_outlined), title: Text('Novo produto adicionado'), subtitle: Text('Estrutura visual portada do V2.')),
              ListTile(leading: Icon(Icons.sync_outlined), title: Text('Sincronização'), subtitle: Text('Aguardando conexão com os serviços do V2.')),
            ],
          ),
        ),
      ),
    );
  }

  void _showProducts(String title, List<_Product> products) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            for (final product in products) Padding(padding: const EdgeInsets.only(bottom: 8), child: _ProductRow(product: product)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onMenu, required this.onNotifications});
  final VoidCallback onMenu;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: Container(
          height: MediaQuery.sizeOf(context).width / 3,
          constraints: const BoxConstraints(minHeight: 126),
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFD7EDFF), Color(0xFFE0F6E8), Color(0xFFE7DDFF)])),
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
              Align(alignment: Alignment.topLeft, child: Padding(padding: const EdgeInsets.all(12), child: IconButton.filledTonal(onPressed: onMenu, icon: const Icon(Icons.menu_rounded)))),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Badge(label: const Text('2'), child: IconButton.filledTonal(onPressed: onNotifications, icon: const Icon(Icons.notifications_none_rounded))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NrdDrawer extends StatelessWidget {
  const _NrdDrawer();

  @override
  Widget build(BuildContext context) {
    void go(String route) {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('NRD Lojas V3', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Flutter + Rive + Compose', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 18),
            ListTile(leading: const Icon(Icons.local_offer_outlined), title: const Text('Promoções'), onTap: () => go('/promotions')),
            ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Configurações'), onTap: () => go('/settings')),
            ListTile(leading: const Icon(Icons.info_outline), title: const Text('Sobre'), onTap: () => go('/about')),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Área Administrativa'),
              subtitle: const Text('Próxima etapa da migração'),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Painel administrativo ainda será portado do V2.'))),
            ),
          ],
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon), const SizedBox(height: 6), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)]),
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

class _Product {
  const _Product(this.code, this.name, this.category);
  final String code;
  final String name;
  final String category;
}
