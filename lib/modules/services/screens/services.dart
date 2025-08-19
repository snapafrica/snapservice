import 'package:intl/intl.dart';
import 'package:snapservice/common.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  TextEditingController searchController = TextEditingController();
  final bool _isCartVisible = false;
  bool showSearch = false;
  String selectedCategory = 'All';

  List<String> allCategories = [
    'Decoration',
    'Tips Gel',
    'Acrylic',
    'Plain Gel',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final businessServices = ref.watch(businessServicesProvider);
    final servicesState = ref.watch(businessServicesProvider);
    final user = ref.watch(authenticationServiceProvider).valueOrNull?.user;
    final cartItems = ref.watch(cartServiceProvider).items;

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    bool isSmallScreen = width < 900;

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: isSmallScreen
          ? AppBar(
              backgroundColor: theme.secondaryBackGround,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.storeName ?? 'snapservice',
                    style: TextStyle(color: theme.textIconPrimaryColor),
                  ),
                  Text(
                    DateFormat('dd MMMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textIconSecondaryColor,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: theme.textIconSecondaryColor),
                      SizedBox(width: 5),
                      Text(
                        'Search',
                        style: TextStyle(color: theme.textIconSecondaryColor),
                      ),
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      showSearch = !showSearch;
                    });
                  },
                ),
                if (cartItems.isNotEmpty)
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shopping_cart,
                          color: theme.textIconPrimaryColor,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartPage()),
                          );
                        },
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: theme.activeBackGround,
                          child: Text(
                            cartItems.length.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.activeTextIconColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            )
          : null,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 14,
            child: Column(
              children: [
                if (!isSmallScreen)
                  _topMenu(
                    title: user?.storeName ?? 'snapservice',
                    subTitle: DateFormat('dd MMMM yyyy').format(DateTime.now()),
                    action: _search(theme),
                    theme: theme,
                  ),
                if (!isSmallScreen) _categoryTabs(height, theme),
                if (showSearch && isSmallScreen)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: TextField(
                      autofocus: true,
                      readOnly: true,
                      controller: searchController,
                      style: TextStyle(color: theme.textIconPrimaryColor),
                      decoration: InputDecoration(
                        labelText: "Search services here...",
                        labelStyle: TextStyle(color: theme.searchTextIconColor),
                        filled: true,
                        fillColor: theme.primaryBackGround,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.searchTextIconColor,
                        ),
                      ),
                      onTap: () => SearchServices.show(
                        context,
                        List.from(businessServices.services)..removeWhere(
                          (element) => element.type.toLowerCase() != 'main',
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 4),
                _productGrid(servicesState, theme),
              ],
            ),
          ),
          if (!isSmallScreen) Expanded(flex: 1, child: Container()),
          if (!isSmallScreen && width > 900)
            Expanded(flex: 5, child: CartSummaryWidget(height: height)),
          if (isSmallScreen && _isCartVisible)
            CartSummaryWidget(height: height),
        ],
      ),
    );
  }

  Widget _itemTab({
    required String icon,
    required String title,
    required bool isActive,
    required ThemeConfig theme,
  }) {
    return Container(
      width: 176,
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.cardShadowColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(2, 4),
          ),
        ],
        color: theme.primaryBackGround,
        border: isActive
            ? Border.all(color: theme.activeBackGround, width: 3)
            : Border.all(color: theme.primaryBackGround, width: 3),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 38),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: theme.activeTextIconColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topMenu({
    required String title,
    required String subTitle,
    required Widget action,
    required ThemeConfig theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.textIconPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subTitle,
              style: TextStyle(
                color: theme.textIconSecondaryColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
        Expanded(flex: 1, child: Container(width: double.infinity)),
        Expanded(flex: 5, child: action),
      ],
    );
  }

  Widget _search(theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.primaryBackGround,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.searchTextIconColor),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                setState(() {});
              },
              style: TextStyle(color: theme.searchTextIconColor, fontSize: 11),
              decoration: InputDecoration(
                hintText: 'Search services here...',
                hintStyle: TextStyle(
                  color: theme.searchTextIconColor,
                  fontSize: 11,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTabs(double height, theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = "All";
                });
              },
              child: _itemTab(
                icon: 'assets/icons/gel.png',
                title: "All",
                isActive: selectedCategory == 'All',
                theme: theme,
              ),
            ),
            ...allCategories.map((category) {
              bool isActive = selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: _itemTab(
                  icon: 'assets/icons/gel.png',
                  title: category,
                  isActive: isActive,
                  theme: theme,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _productGrid(ServicesState servicesState, theme) {
    if (servicesState is ServicesLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          width: context.sz.width / 2,
          child: const LinearProgressIndicator(),
        ),
      );
    } else if (servicesState is ServicesError) {
      return Center(
        child: Text(
          "Error: ${servicesState.error}",
          style: TextStyle(color: theme.deleteColor),
        ),
      );
    } else if (servicesState is ServicesLoaded) {
      final List<Savis> services = servicesState.services.where((service) {
        final isCategoryMatch =
            selectedCategory == 'All' ||
            service.type.contains(selectedCategory);
        final isSearchMatch = service.name.toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
        return isCategoryMatch && isSearchMatch;
      }).toList();

      if (services.isEmpty) {
        return emptyState(ref, text: 'No services available');
      }
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(businessServicesProvider);
              ref.invalidate(cartServiceProvider);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = MediaQuery.of(context).size.width;
                int crossAxisCount = width > 1200
                    ? 4
                    : width > 800
                    ? 3
                    : width > 600
                    ? 3
                    : 2;
                double aspectRatio = (constraints.maxWidth < 400)
                    ? 0.8 / 1.3
                    : 0.9 / 1.2;

                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return _item(
                      image: 'assets/icons/gel.png',
                      title: service.name,
                      price: service.amount.toDouble().money,
                      onAdd: () => onAdd(ref, service),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    return emptyState(ref, text: 'No data available');
  }

  Widget _item({
    required String image,
    required String title,
    required String price,
    required VoidCallback onAdd,
  }) {
    final theme = ref.watch(themeServicesProvider);
    final cartItems = ref.watch(cartServiceProvider).items;
    final int cartQuantity = cartItems
        .where((item) => item.name == title)
        .fold(0, (sum, item) => sum + item.quantity.toInt());
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
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: theme.activeTextIconColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            price,
            style: TextStyle(
              color: theme.activeTextIconColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Flexible(
            child: TextButton(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                foregroundColor: theme.activeBackGround,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text.rich(
                TextSpan(
                  text: 'Add to cart',
                  children: [
                    TextSpan(
                      text: cartQuantity > 0 ? '($cartQuantity)' : '',
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
          ),
        ],
      ),
    );
  }

  void onAdd(WidgetRef ref, Savis savis) {
    final prev = ref.read(cartServiceProvider).items;
    final existsIndex = prev.indexWhere((element) => element.id == savis.id);

    if (existsIndex == -1) {
      final newSavis = savis.copyWith(quantity: 1);
      ref.read(cartServiceProvider.notifier).add(newSavis);
    } else {
      ref
          .read(cartServiceProvider.notifier)
          .changeQnty(prev[existsIndex], prev[existsIndex].quantity + 1);
    }
  }
}

class CartSummaryWidget extends ConsumerWidget {
  final double height;

  const CartSummaryWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServicesProvider);
    final cartNotifier = ref.watch(cartServiceProvider);
    final cartItems = cartNotifier.items;
    final cartPhone = cartNotifier.phone;

    final double width = MediaQuery.of(context).size.width;
    bool isSmallScreen = width < 900;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!isSmallScreen)
                Text(
                  "Cart items",
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.textIconPrimaryColor,
                  ),
                ),
              if (!isSmallScreen)
                if (cartPhone != null && cartPhone.isNotEmpty) ...[
                  const Spacer(),
                  PopupMenuButton<_MenuActions>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: theme.textIconPrimaryColor,
                    ),
                    color: theme.textIconPrimaryColor,
                    itemBuilder: (BuildContext context) => _MenuActions.values
                        .map(
                          (e) => PopupMenuItem<_MenuActions>(
                            value: e,
                            child: Row(
                              children: [
                                Icon(
                                  e.logo(),
                                  color: theme.textIconPrimaryColor,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  e.name(),
                                  style: TextStyle(
                                    color: theme.textIconPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onSelected: (_MenuActions item) {
                      if (item == _MenuActions.customer) {
                        context.go('/customer_screen?isAgent=false');
                      } else if (item == _MenuActions.exitmode) {
                        ref.read(cartServiceProvider.notifier).clearState();
                      }
                    },
                  ),
                ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Total Items: ${cartItems.length}",
            style: TextStyle(color: theme.textIconSecondaryColor),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cartItems.isEmpty
                ? emptyState(ref, text: 'Cart is empty')
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return CartItemWidget(
                        item: cartItems[index],
                        ref: ref,
                        theme: ref.watch(themeServicesProvider),
                        cartService: ref.watch(cartServiceProvider),
                        settingsService: ref.watch(settingsServicesProvider),
                        agentsService: ref.watch(agentsServicesProvider),
                        onRemoveItem: (item) {
                          ref.read(cartServiceProvider.notifier).remove(item);
                        },
                        onTapAdd: (value) {
                          ref
                              .read(cartServiceProvider.notifier)
                              .changeQnty(value, value.quantity + 1);
                        },
                        onTapRemove: (value) {
                          ref
                              .read(cartServiceProvider.notifier)
                              .changeQnty(value, value.quantity - 1);
                        },
                        onRemoveDiscount: (value) {
                          ref
                              .read(cartServiceProvider.notifier)
                              .setDiscount(value, 0);
                        },
                        onSetDiscount: (value) {
                          ref
                              .read(cartServiceProvider.notifier)
                              .setDiscount(value.savis, value.discount);
                        },
                        onTapAssign: (value) {
                          ref
                              .read(cartServiceProvider.notifier)
                              .agent = MapEntry('${value.savis.id}', {
                            'agentName': value.agent.name,
                            'agentId': '${value.agent.id}',
                          });
                        },
                        onSetAddons: (value) {
                          ref
                              .read(cartServiceProvider.notifier)
                              .addAddon(
                                savisId: value.savis,
                                addons: value.addons,
                              );
                        },
                      );
                    },
                  ),
          ),
          _orderTotalSection(context, theme, cartItems),
        ],
      ),
    );
  }

  Widget _orderTotalSection(
    BuildContext context,
    ThemeConfig theme,
    List<Savis> cartItems,
  ) {
    if (cartItems.isEmpty) return const SizedBox();

    final subtotal = cartItems.fold(
      0.0,
      (sum, item) =>
          sum +
          ((double.tryParse(item.amount.toString()) ?? 0.0) * item.quantity),
    );
    final totalDiscount = cartItems.fold(
      0.0,
      (sum, item) =>
          sum +
          ((double.tryParse(item.discount.toString()) ?? 0.0) * item.quantity),
    );
    final total = subtotal - totalDiscount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.cardGradientStart, theme.cardGradientEnd],
          ),
          borderRadius: BorderRadius.circular(14),
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
          children: [
            if (totalDiscount > 0) ...[
              _buildTotalRow('Sub Total', subtotal.toDouble().money, theme),
              _buildTotalRow(
                'Discount Savings',
                '-${totalDiscount.toDouble().money}',
                theme,
              ),
              Divider(color: theme.textIconPrimaryColor),
            ],
            _buildTotalRow('Total', total.toDouble().money, theme),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.go('/create_order', extra: cartItems);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.activeTextIconColor,
                backgroundColor: theme.activeBackGround,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_checkout,
                    size: 20,
                    color: theme.activeTextIconColor,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, ThemeConfig theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.activeTextIconColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.activeTextIconColor,
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}

class CartItemWidget extends StatefulWidget {
  final Savis item;
  final WidgetRef ref;
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

  const CartItemWidget({
    super.key,
    required this.item,
    required this.ref,
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

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  bool showButtons = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => showButtons = !showButtons),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.theme.cardGradientStart,
              widget.theme.cardGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: widget.theme.cardShadowColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildMainRow(widget.theme),
            _buildToggleButton(widget.theme),
            if (showButtons) _buildActionButtons(widget.theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMainRow(theme) {
    return Row(
      children: [
        _buildItemDetails(theme),
        _buildQuantityControls(theme),
        _buildRemoveButton(theme),
      ],
    );
  }

  Widget _buildItemDetails(theme) {
    double amount = double.tryParse(widget.item.amount.toString()) ?? 0.0;
    double discount = double.tryParse(widget.item.discount.toString()) ?? 0.0;
    bool hasDiscount = discount > 0;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.activeTextIconColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          hasDiscount
              ? Row(
                  children: [
                    Text(
                      amount.toDouble().money,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.activeTextIconColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (amount - discount).toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.successColor,
                      ),
                    ),
                  ],
                )
              : Text(
                  amount.toDouble().money,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.activeTextIconColor,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(theme) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle, color: theme.deleteColor),
          onPressed: () => _changeQuantity((widget.item.quantity - 1).toInt()),
        ),
        Text(
          widget.item.quantity.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.activeTextIconColor,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle, color: theme.successColor),
          onPressed: () => _changeQuantity((widget.item.quantity + 1).toInt()),
        ),
      ],
    );
  }

  Widget _buildRemoveButton(theme) {
    return IconButton(
      icon: Icon(Icons.cancel_sharp, color: theme.deleteColor),
      onPressed: _removeItem,
    );
  }

  Widget _buildToggleButton(theme) {
    double discount = double.tryParse(widget.item.discount.toString()) ?? 0.0;
    bool hasDiscount = discount > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hasDiscount ? 'Discount: ${discount.toStringAsFixed(2)}' : '',
          style: TextStyle(color: theme.activeTextIconColor),
        ),
        IconButton(
          icon: Icon(
            showButtons ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: theme.activeTextIconColor,
          ),
          onPressed: () => setState(() => showButtons = !showButtons),
        ),
      ],
    );
  }

  Widget _buildActionButtons(theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAssignButton(theme),
        if (widget.settingsService.showDiscount) _buildDiscountButton(theme),
        _buildAddonButton(theme),
      ],
    );
  }

  Widget _buildAssignButton(theme) {
    return TextButton(
      onPressed: () async {
        final selectedAgent = await PickAgent.show(
          context,
          widget.agentsService.value ?? [],
        );
        if (selectedAgent != null) {
          widget.onTapAssign((agent: selectedAgent, savis: widget.item));
        }
      },
      style: _buttonStyle(theme.primaryBackGround, theme),
      child: const Text('Assign'),
    );
  }

  Widget _buildDiscountButton(theme) {
    return TextButton(
      onPressed: () {
        ProductDiscountEdit.show(
          context,
          discount: double.tryParse(widget.item.discount.toString()) ?? 0.0,
          remove: () {
            Navigator.pop(context);
            widget.onRemoveDiscount(widget.item);
          },
        ).then((value) {
          if (value != null &&
              value <=
                  (double.tryParse(widget.item.amount.toString()) ?? 0.0)) {
            widget.onSetDiscount((savis: widget.item, discount: value));
          }
        });
      },
      style: _buttonStyle(theme.primaryBackGround, theme),
      child: const Text('Discount'),
    );
  }

  Widget _buildAddonButton(theme) {
    return TextButton(
      onPressed: () async {
        final addons = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderAddAddon(
              orderId: 0,
              itemId: widget.item.id,
              prevAddons: widget.cartService.addons
                  .where((e) => e['mainServiceId'] == widget.item.id)
                  .toList(),
            ),
          ),
        );
        if (addons != null) {
          widget.onSetAddons((
            savis: widget.item.id,
            addons: addons as List<Map<String, dynamic>>,
          ));
        }
      },
      style: _buttonStyle(theme.primaryBackGround, theme),
      child: const Text('Addon +'),
    );
  }

  ButtonStyle _buttonStyle(Color color, theme) => TextButton.styleFrom(
    backgroundColor: color,
    foregroundColor: theme.activeTextIconColor,
  );

  void _removeItem() =>
      widget.ref.read(cartServiceProvider.notifier).remove(widget.item);

  void _changeQuantity(int newQuantity) {
    newQuantity > 0
        ? widget.ref
              .read(cartServiceProvider.notifier)
              .changeQnty(widget.item, newQuantity)
        : _removeItem();
  }
}

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    bool isSmallScreen = width < 600;

    final theme = ref.watch(themeServicesProvider);
    final cartNotifier = ref.watch(cartServiceProvider);
    final cartPhone = cartNotifier.phone;

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: isSmallScreen
          ? AppBar(
              centerTitle: true,
              title: Text(
                "Cart Items",
                style: TextStyle(color: theme.textIconPrimaryColor),
              ),
              backgroundColor: theme.secondaryBackGround,
              foregroundColor: theme.textIconPrimaryColor,
              actions: cartPhone != null && cartPhone.isNotEmpty
                  ? [
                      PopupMenuButton<_MenuActions>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: theme.textIconPrimaryColor,
                        ),
                        color: theme.primaryBackGround,
                        itemBuilder: (BuildContext context) =>
                            _MenuActions.values.map((e) {
                              return PopupMenuItem<_MenuActions>(
                                value: e,
                                child: Row(
                                  children: [
                                    Icon(
                                      e.logo(),
                                      color: theme.textIconPrimaryColor,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      e.name(),
                                      style: TextStyle(
                                        color: theme.textIconPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onSelected: (_MenuActions item) {
                          if (item == _MenuActions.customer) {
                            context.go('/customer_screen?isAgent=false');
                          } else if (item == _MenuActions.exitmode) {
                            ref.read(cartServiceProvider.notifier).clearState();
                          }
                        },
                      ),
                    ]
                  : null,
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CartSummaryWidget(height: height),
        ),
      ),
    );
  }
}

enum _MenuActions {
  customer,
  exitmode;

  String name() => switch (this) {
    _MenuActions.customer => 'Customer Portal',
    _MenuActions.exitmode => 'Exit Mode',
  };

  IconData logo() => switch (this) {
    _MenuActions.customer => Icons.co_present_outlined,
    _MenuActions.exitmode => Icons.exit_to_app_rounded,
  };
}
