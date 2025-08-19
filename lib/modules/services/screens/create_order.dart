import 'package:snapservice/common.dart';

class ServiceCartPage extends ConsumerStatefulWidget {
  final List<Savis> cartItems;

  const ServiceCartPage({super.key, required this.cartItems});

  static double calculateTotalPrice(List<Savis> cartitems) {
    final tt = cartitems.fold(0.0, (previousValue, element) {
      final discount = num.tryParse(element.discount) ?? 0;
      final hasdiscount = discount > 0;
      if (hasdiscount) {
        return ((element.amount - discount) * element.quantity) + previousValue;
      }
      return (element.amount * element.quantity) + previousValue;
    });
    return tt;
  }

  static Future<bool> createOrder({
    required BuildContext context,
    required WidgetRef ref,
    bool isPayFirst = false,
    PayFirstPayload? payload,
  }) async {
    if (!isPayFirst) context.loading;
    final ttp = ServiceCartPage.calculateTotalPrice(
      ref.read(cartServiceProvider).items,
    );
    return await ref
        .read(cartServiceProvider.notifier)
        .createOrder(
          totalPrice: ttp,
          orderType: payload?.orderType,
          reference: payload?.reference,
          code: payload?.code,
          type: payload?.type,
          cashAdd: payload?.cashAdd,
        )
        .then((value) {
          ref.read(cartServiceProvider.notifier).clearState();
          if (!isPayFirst) context.pop();
          return true;
        })
        .onError((error, stackTrace) {
          context.pop();
          return false;
        });
  }

  @override
  ConsumerState<ServiceCartPage> createState() => _ServiceCartPageState();
}

class _ServiceCartPageState extends ConsumerState<ServiceCartPage> {
  late final stateData = ref.read(cartServiceProvider);
  late final TextEditingController _cAgentName = TextEditingController(
    text: stateData.mainAgent?.name,
  );
  late final TextEditingController _cShopName = TextEditingController(
    text: stateData.shop?['name'],
  );
  late final TextEditingController _cPhoneClient = TextEditingController(
    text: stateData.phone,
  );
  final GlobalKey<FormState> formKey = GlobalKey();
  bool isAbooking = false;
  bool _isCreatingOrder = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final cartService = ref.watch(cartServiceProvider);
    final agentsService = ref.watch(agentsServicesProvider);
    final branchesService = ref.watch(branchesServicesProvider);
    final settingsService = ref.watch(settingsServicesProvider);
    final user = ref.watch(authenticationServiceProvider).valueOrNull?.user;
    final cartitems = cartService.items;

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: AppBar(
        leading: context.backIcon(ref, context.pop),
        backgroundColor: theme.secondaryBackGround,
        foregroundColor: theme.activeTextIconColor,
        elevation: 0,
        actions: [
          if (cartitems.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartServiceProvider.notifier).clearState();
                context.go('/');
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child:
              cartitems.isNotEmpty
                  ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.primaryBackGround,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.cardShadowColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: theme.inactiveTextIconColor,
                                  ),
                                ),
                                Text(
                                  ServiceCartPage.calculateTotalPrice(
                                    cartitems,
                                  ).toDouble().money,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.activeTextIconColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        CartClientSection(
                          theme: theme,
                          formKey: formKey,
                          cPhoneClient: _cPhoneClient,
                          user: user,
                          cShopName: _cShopName,
                          cAgentName: _cAgentName,
                          branchesService: branchesService,
                          agentsService: agentsService,
                          isAbooking: isAbooking,
                          bookingDate: cartService.bookingDate,
                          onPhoneChanged: (value) {
                            ref.read(cartServiceProvider.notifier).clientPhone =
                                value;
                          },
                          onBranchTap: (data) {
                            SelectShop.show(context, data).then((value) {
                              if (value != null) {
                                ref
                                    .read(cartServiceProvider.notifier)
                                    .mainShop = value;
                                _cShopName.text = value['name'];
                              }
                            });
                          },
                          onAgentTap: (data) {
                            PickAgent.show(context, data).then((value) {
                              if (value != null) {
                                ref
                                    .read(cartServiceProvider.notifier)
                                    .mainAgent = value;
                                _cAgentName.text = value.name;
                              }
                            });
                          },
                          onBookingStatusChange: () {
                            if (isAbooking) {
                              ref
                                  .read(cartServiceProvider.notifier)
                                  .clearBookingDate();
                              isAbooking = false;
                            } else {
                              isAbooking = true;
                            }
                            setState(() {});
                          },
                          onBookingDateSelected: (value) {
                            ref.read(cartServiceProvider.notifier).bookingDate =
                                value;
                            setState(() {});
                          },
                        ),
                        ElevatedButton(
                          onPressed:
                              _isCreatingOrder
                                  ? null
                                  : () =>
                                      onCreateOrder(settingsService.payFirst),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: theme.activeTextIconColor,
                            backgroundColor: theme.activeBackGround,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 6,
                            shadowColor: theme.activeBackGround.withOpacity(
                              0.2,
                            ),
                          ),
                          child:
                              _isCreatingOrder && !settingsService.payFirst
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.activeTextIconColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Creating...',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ],
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.receipt_long,
                                        size: 20,
                                        color: theme.activeTextIconColor,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Create Order',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  )
                  : emptyState(ref, text: 'No items in cart'),
        ),
      ),
    );
  }

  reateOrder({required bool payFirst}) {
    if (formKey.currentState!.validate() && validBooking) {
      context.loading;
      final theme = ref.watch(themeServicesProvider);
      final ttp = ServiceCartPage.calculateTotalPrice(
        ref.read(cartServiceProvider).items,
      );
      ref
          .read(cartServiceProvider.notifier)
          .createOrder(totalPrice: ttp)
          .then((value) {
            ref.read(cartServiceProvider.notifier).clearState();
            context.pop();
            context.showToast(
              'Order created succesfully',
              textColor: theme.textIconPrimaryColor,
            );
          })
          .onError((error, stackTrace) {
            context.pop();
          });
    }
  }

  void onCreateOrder(bool payFirst) async {
    final theme = ref.watch(themeServicesProvider);
    if (formKey.currentState!.validate() && validBooking) {
      if (!payFirst) setState(() => _isCreatingOrder = true);

      final bool orderCreated;
      if (payFirst) {
        orderCreated = await CartPayFirst.show(context: context) ?? false;
      } else {
        orderCreated = await ServiceCartPage.createOrder(
          context: context,
          ref: ref,
        );
      }

      if (mounted && (!payFirst || orderCreated)) context.pop();
      if (orderCreated && mounted) {
        context.showToast(
          'Order created succesfully',
          textColor: theme.textIconPrimaryColor,
        );
      }

      if (!payFirst && mounted) setState(() => _isCreatingOrder = false);
    }
  }

  bool get validBooking {
    final theme = ref.watch(themeServicesProvider);
    if (isAbooking) {
      if (ref.read(cartServiceProvider).bookingDate == null) {
        context.showToast(
          'Please select booking date',
          error: true,
          textColor: theme.textIconPrimaryColor,
        );
        return false;
      }
    }
    return true;
  }
}
