import 'package:snapservice/common.dart';

class SavisCard extends ConsumerWidget {
  const SavisCard({
    super.key,
    required this.savis,
    required this.width,
    this.onAdd,
    this.onRemove,
    this.onEdit,
    this.cartQuantity,
    this.showAddButton = true,
  });

  static void onAddTap(Savis savis, WidgetRef ref) {
    ref.read(cartServiceProvider.notifier).add(savis);
  }

  static num quantityInCart(Savis savis, List<Savis> cartItems) {
    final cartIndex = cartItems.indexWhere((element) => element.id == savis.id);
    return cartIndex == -1 ? 0 : cartItems[cartIndex].quantity;
  }

  static void changeQuantity(WidgetRef ref, Savis item, num qnty) {
    ref.read(cartServiceProvider.notifier).changeQnty(item, qnty);
  }

  final Savis savis;
  final double width;
  final VoidCallback? onAdd;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final num? cartQuantity;
  final bool showAddButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServicesProvider);
    final cartItems = ref.watch(cartServiceProvider).items;
    final int quantity =
        cartQuantity?.toInt() ?? quantityInCart(savis, cartItems).toInt();

    return _item(
      ref: ref,
      theme: theme,
      image: 'assets/icons/tips.png',
      title: savis.name.trim(),
      price: savis.amount.toDouble().money,
      cartQuantity: quantity,
      onAdd: onAdd ?? () => onAddTap(savis, ref),
      onRemove: onRemove,
      onEdit: onEdit,
      showAddButton: showAddButton,
    );
  }
}

Widget _item({
  required WidgetRef ref,
  required ThemeConfig theme,
  required String image,
  required String title,
  required String price,
  required int cartQuantity,
  required VoidCallback onAdd,
  VoidCallback? onRemove,
  VoidCallback? onEdit,
  bool showAddButton = true,
}) {
  return Container(
    margin: const EdgeInsets.only(right: 20, bottom: 20),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [theme.cardGradientStart, theme.cardGradientEnd],
      ),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: theme.cardShadowColor.withOpacity(0.2),
          blurRadius: 8,
          spreadRadius: 2,
          offset: const Offset(2, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 10),
        _buildText(title, 14, FontWeight.bold, theme),
        const SizedBox(height: 5),
        _buildText(price, 12, FontWeight.bold, theme),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showAddButton) _buildAddButton(onAdd, cartQuantity, theme),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit, color: theme.activeBackGround, size: 20),
              ),
            if (cartQuantity > 0 && onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.close,
                  color: theme.activeBackGround,
                  size: 20,
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildText(String text, double size, FontWeight weight, theme) {
  return Text(
    text,
    style: TextStyle(
      color: theme.activeTextIconColor,
      fontWeight: weight,
      fontSize: size,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

Widget _buildAddButton(VoidCallback onAdd, int cartQuantity, theme) {
  return Flexible(
    child: TextButton(
      onPressed: onAdd,
      style: TextButton.styleFrom(
        foregroundColor: theme.activeBackGround,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text.rich(
        TextSpan(
          text: 'Add to cart',
          children: [
            if (cartQuantity > 0)
              TextSpan(
                text: ' ($cartQuantity)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
