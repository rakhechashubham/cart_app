import 'package:material_ui/material_ui.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';

class ProductArt extends StatelessWidget {
  const ProductArt({
    super.key,
    required this.product,
    this.height = 138,
    this.emojiSize = 67,
    this.width = double.infinity,
  });

  final Product product;
  final double height;
  final double emojiSize;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: product.color),
              ),
            ),
            Positioned(
              right: -16,
              top: -27,
              child: Container(
                width: height * .8,
                height: height * .8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .32),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -height * .15,
              bottom: -height * .53,
              child: Container(
                width: height * .8,
                height: height * .8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .22),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Transform.rotate(
              angle: -.08,
              child: Text(
                product.emoji,
                style: TextStyle(
                  fontSize: emojiSize,
                  height: 1,
                  shadows: const [
                    Shadow(
                      color: Color(0x18000000),
                      blurRadius: 12,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
              ),
            ),
            if (product.tag != null)
              Positioned(
                top: 9,
                left: 9,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .88),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.tag!,
                    style: const TextStyle(
                      color: AppColors.forest,
                      fontSize: 8,
                      letterSpacing: .45,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
