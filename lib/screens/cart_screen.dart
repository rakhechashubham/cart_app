import 'package:material_ui/material_ui.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_art.dart';
import '../widgets/quantity_stepper.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.cart,
    required this.onQuantityChanged,
    required this.onShopTap,
  });

  final Map<String, int> cart;
  final void Function(Product product, int quantity) onQuantityChanged;
  final VoidCallback onShopTap;

  static const _freeDeliveryThreshold = 499;
  static const _deliveryFee = 35;

  @override
  Widget build(BuildContext context) {
    final items = products
        .where((product) => (cart[product.id] ?? 0) > 0)
        .toList();
    final itemCount = cart.values.fold(
      0,
      (total, quantity) => total + quantity,
    );
    final subtotal = items.fold<int>(
      0,
      (total, product) => total + product.price * (cart[product.id] ?? 0),
    );
    final delivery = items.isEmpty || subtotal >= _freeDeliveryThreshold
        ? 0
        : _deliveryFee;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: items.isEmpty
            ? _EmptyBasket(onShopTap: onShopTap)
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _CartHeading(itemCount: itemCount)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                      child: _DeliveryProgress(
                        subtotal: subtotal,
                        threshold: _freeDeliveryThreshold,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: _ItemsHeading(itemCount: items.length),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = items[index];
                        return _CartItem(
                          product: product,
                          quantity: cart[product.id] ?? 0,
                          onQuantityChanged: (quantity) =>
                              onQuantityChanged(product, quantity),
                          onRemove: () => onQuantityChanged(product, 0),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 19, 20, 25),
                      child: _OrderSummary(
                        subtotal: subtotal,
                        delivery: delivery,
                        total: subtotal + delivery,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CartHeading extends StatelessWidget {
  const _CartHeading({required this.itemCount});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 21),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your basket',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'} · looking good already',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.sage,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.forest,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryProgress extends StatelessWidget {
  const _DeliveryProgress({required this.subtotal, required this.threshold});
  final int subtotal;
  final int threshold;

  @override
  Widget build(BuildContext context) {
    final reached = subtotal >= threshold;
    final remaining = (threshold - subtotal).clamp(0, threshold);
    final progress = (subtotal / threshold).clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1E7),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                reached
                    ? Icons.check_circle_rounded
                    : Icons.local_shipping_outlined,
                color: AppColors.forest,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reached
                      ? 'You unlocked free delivery!'
                      : 'Add ${formatPrice(remaining)} for free delivery',
                  style: const TextStyle(
                    color: AppColors.forest,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (reached)
                const Text(
                  'NICE!',
                  style: TextStyle(
                    color: AppColors.forest,
                    fontSize: 9,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              color: AppColors.forest,
              backgroundColor: Colors.white.withValues(alpha: .85),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsHeading extends StatelessWidget {
  const _ItemsHeading({required this.itemCount});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'In your basket',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '$itemCount ${itemCount == 1 ? 'product' : 'products'}',
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemove,
  });
  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          ProductArt(product: product, width: 78, height: 78, emojiSize: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  product.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatPrice(product.price)} each',
                  style: const TextStyle(
                    color: AppColors.forest,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Remove ${product.name}',
                onPressed: onRemove,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.muted,
                  size: 17,
                ),
              ),
              const SizedBox(height: 8),
              QuantityStepper(
                quantity: quantity,
                onChanged: onQuantityChanged,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.subtotal,
    required this.delivery,
    required this.total,
  });
  final int subtotal;
  final int delivery;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order summary',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(label: 'Subtotal', value: formatPrice(subtotal)),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Delivery',
            value: delivery == 0 ? 'FREE' : formatPrice(delivery),
            valueColor: delivery == 0 ? AppColors.forest : AppColors.ink,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.line),
          ),
          _SummaryRow(label: 'Total', value: formatPrice(total), isTotal: true),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              children: [
                Icon(Icons.eco_outlined, size: 16, color: AppColors.forest),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fresh from local growers, packed with care.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: isTotal ? AppColors.ink : AppColors.muted,
      fontSize: isTotal ? 15 : 12,
      fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(
          value,
          style: style.copyWith(
            color: valueColor ?? style.color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptyBasket extends StatelessWidget {
  const _EmptyBasket({required this.onShopTap});
  final VoidCallback onShopTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 126,
              height: 126,
              decoration: const BoxDecoration(
                color: AppColors.sage,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🧺', style: TextStyle(fontSize: 62, height: 1)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your basket is taking\na little breather',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontSize: 24, height: 1.16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Fill it with the good stuff. Your fresh finds will show up right here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 23),
            FilledButton.icon(
              onPressed: onShopTap,
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: const Text('Explore the market'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 19,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
