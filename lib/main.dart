import 'package:material_ui/material_ui.dart';

import 'models/product.dart';
import 'screens/cart_screen.dart';
import 'screens/shop_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grove Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MarketHome(),
    );
  }
}

class MarketHome extends StatefulWidget {
  const MarketHome({super.key});

  @override
  State<MarketHome> createState() => _MarketHomeState();
}

class _MarketHomeState extends State<MarketHome> {
  int _selectedTab = 0;
  final Map<String, int> _cart = <String, int>{};

  int get _itemCount =>
      _cart.values.fold(0, (total, quantity) => total + quantity);

  void _setQuantity(Product product, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = quantity;
      }
    });
  }

  void _changeTab(int tab) => setState(() => _selectedTab = tab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedTab,
          children: [
            ShopScreen(cart: _cart, onQuantityChanged: _setQuantity),
            CartScreen(
              cart: _cart,
              onQuantityChanged: _setQuantity,
              onShopTap: () => _changeTab(0),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedTab,
        itemCount: _itemCount,
        onSelected: _changeTab,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.itemCount,
    required this.onSelected,
  });

  final int selectedIndex;
  final int itemCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.line.withValues(alpha: .75)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: .04),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              _NavItem(
                label: 'Shop',
                icon: Icons.storefront_outlined,
                selected: selectedIndex == 0,
                onTap: () => onSelected(0),
              ),
              _NavItem(
                label: 'My basket',
                icon: Icons.shopping_bag_outlined,
                selected: selectedIndex == 1,
                badge: itemCount == 0 ? null : itemCount,
                onTap: () => onSelected(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.forest : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 22, color: color),
                if (badge != null)
                  Positioned(
                    right: -10,
                    top: -7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
