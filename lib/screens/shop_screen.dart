import 'package:material_ui/material_ui.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({
    super.key,
    required this.cart,
    required this.onQuantityChanged,
  });

  final Map<String, int> cart;
  final void Function(Product product, int quantity) onQuantityChanged;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  String _category = 'All';

  List<Product> get _visibleProducts {
    final normalizedQuery = _query.trim().toLowerCase();
    return products.where((product) {
      final matchesCategory =
          _category == 'All' || product.category == _category;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery) ||
          product.category.toLowerCase().contains(normalizedQuery) ||
          product.description.toLowerCase().contains(normalizedQuery);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToProducts() {
    _scrollController.animateTo(
      400,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: CustomScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(child: _BrandHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FreshBanner(onShopTap: _scrollToProducts),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: _SearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _CategoryFilters(
                selected: _category,
                onSelected: (value) => setState(() => _category = value),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionHeading(
                query: _query,
                category: _category,
                resultCount: _visibleProducts.length,
              ),
            ),
            if (_visibleProducts.isEmpty)
              const SliverToBoxAdapter(child: _NoProductsFound())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 980
                        ? 5
                        : width >= 730
                        ? 4
                        : width >= 520
                        ? 3
                        : 2;
                    return SliverGrid.builder(
                      itemCount: _visibleProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 258,
                      ),
                      itemBuilder: (context, index) {
                        final product = _visibleProducts[index];
                        return ProductCard(
                          product: product,
                          quantity: widget.cart[product.id] ?? 0,
                          onQuantityChanged: (quantity) =>
                              widget.onQuantityChanged(product, quantity),
                        );
                      },
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 17),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.eco_rounded, size: 23, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'grove',
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: -1.2,
                  height: 1,
                  color: AppColors.forest,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 11,
                    color: AppColors.coral,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'FRESH TO YOUR DOOR',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.muted,
                      letterSpacing: .75,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule_rounded, size: 15, color: AppColors.forest),
                SizedBox(width: 6),
                Text(
                  'Today, 4–6 pm',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
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

class _FreshBanner extends StatelessWidget {
  const _FreshBanner({required this.onShopTap});
  final VoidCallback onShopTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 166,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF244D3E), Color(0xFF47775A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -76,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .11),
                  width: 32,
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -46,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .06),
              ),
            ),
          ),
          Positioned(
            right: 21,
            top: 9,
            child: Transform.rotate(
              angle: -.1,
              child: const Text(
                '🥑',
                style: TextStyle(fontSize: 106, height: 1.2),
              ),
            ),
          ),
          Positioned(
            right: 104,
            bottom: 4,
            child: Transform.rotate(
              angle: .14,
              child: const Text(
                '🍊',
                style: TextStyle(fontSize: 49, height: 1.2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 19, 0, 16),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 420 ? 225 : 270,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'A LITTLE FRESHNESS',
                      style: TextStyle(
                        color: Color(0xFFDDE9D7),
                        fontSize: 8,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Good food.\nGood mood.',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.04,
                      fontSize: 24,
                      letterSpacing: -.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Farm fresh finds, picked just for you.',
                    style: TextStyle(color: Color(0xFFD5E3D8), fontSize: 10.5),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onShopTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0E6),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop the harvest',
                            style: TextStyle(
                              color: AppColors.forest,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: AppColors.forest,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search fruit, veg, pantry…',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.forest,
          size: 21,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.selected, required this.onSelected});
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 7),
        scrollDirection: Axis.horizontal,
        itemCount: productCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = productCategories[index];
          final isSelected = category == selected;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(category),
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.muted,
            ),
            selectedColor: AppColors.forest,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? AppColors.forest : AppColors.line,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.query,
    required this.category,
    required this.resultCount,
  });
  final String query;
  final String category;
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    final hasFilter = query.isNotEmpty || category != 'All';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasFilter
                      ? (query.isNotEmpty ? 'Search results' : category)
                      : 'Fresh picks',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  hasFilter
                      ? '$resultCount lovely finds'
                      : 'Good things, grown close to home',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, size: 14, color: AppColors.muted),
                SizedBox(width: 4),
                Text(
                  'Handpicked',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
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

class _NoProductsFound extends StatelessWidget {
  const _NoProductsFound();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 54),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.sage,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.forest,
              size: 29,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'No fresh finds here yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Try another search or browse a different aisle.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
