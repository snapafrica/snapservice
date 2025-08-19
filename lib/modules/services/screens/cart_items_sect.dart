import 'package:snapservice/common.dart';

class CartItemsSection extends StatelessWidget {
  const CartItemsSection({
    super.key,
    required this.maxWidth,
    required this.theme,
    required this.cartService,
    required this.settingsService,
    required this.agentsService,
    required this.onRemoveItem,
    required this.onTapAssign,
    required this.onTapAdd,
    required this.onTapRemove,
    required this.onRemoveDiscount,
    required this.onSetDiscount,
    required this.onSetAddons,
  });
  final double maxWidth;
  final ThemeConfig theme;
  final Cart cartService;
  final SettingsConfig settingsService;
  final AsyncValue<List<Agent>> agentsService;
  final ValueChanged<Savis> onRemoveItem;
  final ValueChanged<({Agent agent, Savis savis})> onTapAssign;
  final ValueChanged<Savis> onTapAdd;
  final ValueChanged<Savis> onTapRemove;
  final ValueChanged<Savis> onRemoveDiscount;
  final ValueChanged<({Savis savis, num discount})> onSetDiscount;
  final ValueChanged<({int savis, List<Map<String, dynamic>> addons})>
  onSetAddons;

  @override
  Widget build(BuildContext context) {
    final cartitems = cartService.items;
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: maxWidth,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: cartitems.length,
          itemBuilder: (context, index) {
            final item = cartitems[index];
            final assigned = cartService.assigned?['${item.id}'];
            final discount = num.tryParse(item.discount);
            final hasdiscount = discount != null && discount >= 1;
            return Card(
              color: theme.primaryBackGround,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          agentsService.when(
                            loading: () => const CircularProgressIndicator(),
                            error:
                                (error, stackTrace) => Text(
                                  'Unable to load agents',
                                  style: TextStyle(
                                    color: theme.deleteColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            data: (data) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    PickAgent.show(context, data).then((value) {
                                      if (value != null) {
                                        onTapAssign((
                                          agent: value,
                                          savis: item,
                                        ));
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        assigned != null
                                            ? Colors.green.shade700
                                            : theme.secondaryBackGround,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    assigned?['agentName'] ?? 'Assign',
                                    style: TextStyle(
                                      color: theme.textIconPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: theme.activeTextIconColor,
                            ),
                          ),
                          Text(
                            item.amount.toDouble().money,
                            style: TextStyle(color: theme.activeTextIconColor),
                          ),
                          if (settingsService.showDiscount)
                            const SizedBox(height: 6),
                          if (settingsService.showDiscount)
                            OutlinedButton(
                              onPressed: () {
                                ProductDiscountEdit.show(
                                  context,
                                  discount: discount,
                                  remove: () {
                                    Navigator.pop(context);
                                    onRemoveDiscount(item);
                                  },
                                ).then((value) {
                                  if (value != null && value <= item.amount) {
                                    onSetDiscount((
                                      savis: item,
                                      discount: value,
                                    ));
                                  }
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.activeTextIconColor,
                                side: BorderSide(
                                  color:
                                      hasdiscount
                                          ? Colors.green.shade700
                                          : theme.activeTextIconColor,
                                ),
                              ),
                              child: Text(
                                'Discount${hasdiscount ? ' : ${discount.toDouble().money}' : ''}',
                              ),
                            ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => onTapRemove(item),
                                icon: Icon(
                                  Icons.remove,
                                  color: theme.activeTextIconColor,
                                ),
                              ),
                              Text(
                                item.quantity.toString(),
                                style: TextStyle(
                                  color: theme.activeTextIconColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () => onTapAdd(item),
                                icon: Icon(
                                  Icons.add,
                                  color: theme.activeTextIconColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        () {
                          cartService.addons
                              .where(
                                (element) =>
                                    element['mainServiceId'] == item.id,
                              )
                              .toList();
                          return TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: theme.secondaryBackGround,
                              foregroundColor: theme.activeTextIconColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              final myaddons =
                                  cartService.addons
                                      .where(
                                        (element) =>
                                            element['mainServiceId'] == item.id,
                                      )
                                      .toList();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => Material(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top:
                                                MediaQuery.paddingOf(
                                                  context,
                                                ).top,
                                          ),
                                          child: OrderAddAddon(
                                            orderId: 0,
                                            itemId: item.id,
                                            prevAddons: myaddons,
                                          ),
                                        ),
                                      ),
                                ),
                              ).then((value) {
                                if (value.toString() != 'null') {
                                  final addons =
                                      value as List<Map<String, dynamic>>;
                                  onSetAddons((savis: item.id, addons: addons));
                                }
                              });
                            },
                            child: Text(
                              'Addons ${cartService.addons.where((e) => e['mainServiceId'] == item.id).length}',
                              style: TextStyle(
                                color: theme.textIconPrimaryColor,
                              ),
                            ),
                          );
                        }(),
                        IconButton(
                          onPressed: () => onRemoveItem(item),
                          icon: Icon(
                            Icons.delete_rounded,
                            color: theme.deleteColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          getSinglePrice(amt: item.amount, qty: item.quantity),
                          style: TextStyle(
                            fontWeight: hasdiscount ? null : FontWeight.bold,
                            color: theme.activeTextIconColor,
                            decoration:
                                hasdiscount ? TextDecoration.lineThrough : null,
                            fontSize: hasdiscount ? 12 : null,
                          ),
                        ),
                        if (hasdiscount)
                          Text(
                            getSinglePrice(
                              amt: item.amount - discount,
                              qty: item.quantity,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String getSinglePrice({required num amt, required num qty}) {
    return (amt * qty).toDouble().money;
  }
}
