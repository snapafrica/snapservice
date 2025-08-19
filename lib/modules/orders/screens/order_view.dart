import 'package:snapservice/common.dart';

class OrderView extends ConsumerWidget {
  const OrderView({
    super.key,
    required this.id,
    required this.readonly,
    required this.insearch,
  });
  final num id;
  final bool readonly;
  final bool insearch;

  static show(
    BuildContext context,
    num id, {
    bool readonly = false,
    bool insearch = false,
  }) {
    return showDialog(
      context: context,
      useRootNavigator: SrceenType.type(context.sz).isMobile,
      builder: (_) {
        return OrderView(id: id, readonly: readonly, insearch: insearch);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServicesProvider);
    final allorders = ref.watch(orderServicesProvider);
    final order =
        allorders.orders.where((element) => element['id'] == id).firstOrNull;
    if (order != null) {
      final size = context.sz;
      final maxWidth = getMaxWidth(size.width);
      final items = List.from(order['orderItems']);
      final agentsService = ref.watch(agentsServicesProvider);
      bool showReassign = order['status'] == 'In-Service' && !readonly;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: maxWidth,
            child: Container(
              decoration: BoxDecoration(
                color: theme.activeTextIconColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              order['billno'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.defultColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.close, color: theme.defultColor),
                          ),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: size.height / 2,
                        minHeight: 100,
                      ),
                      child:
                          items.isNotEmpty
                              ? ListView.builder(
                                itemCount: items.length,
                                padding: const EdgeInsets.all(14),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return Card(
                                    color: theme.inactiveTextIconColor,
                                    clipBehavior: Clip.hardEdge,
                                    child: ExpansionTile(
                                      title: _orderTitle(item, theme),
                                      children: [
                                        if ((item['addons'] as List).isNotEmpty)
                                          Container(
                                            margin: const EdgeInsets.all(16),
                                            alignment: Alignment.centerLeft,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  width: 2,
                                                  color:
                                                      theme
                                                          .inactiveTextIconColor,
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ...(item['addons'] as List).map(
                                                  (e) => ListTile(
                                                    title: Text(
                                                      '${e['name']} ~> ${e['agent']}',
                                                    ),
                                                    subtitle: Text(
                                                      (num.tryParse(
                                                                e['price']
                                                                    .toString(),
                                                              ) ??
                                                              0)
                                                          .toDouble()
                                                          .money,
                                                    ),
                                                    trailing: IconButton(
                                                      onPressed: () {
                                                        // context.loading;
                                                        ref
                                                            .read(
                                                              orderServicesProvider
                                                                  .notifier,
                                                            )
                                                            .removeAddon(
                                                              order:
                                                                  order['billno'],
                                                              cartid:
                                                                  item['cartid']
                                                                      .toString(),
                                                              addonid:
                                                                  e['id']
                                                                      .toString(),
                                                            )
                                                            .then((_) {
                                                              context.pop();
                                                              context.pop();
                                                              ref.invalidate(
                                                                orderServicesProvider,
                                                              );
                                                            });
                                                      },
                                                      icon: const Icon(
                                                        Icons.close,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    if (agentsService
                                                        is AsyncData) {
                                                      final agents =
                                                          agentsService.value ??
                                                          [];
                                                      PickAgent.show(
                                                        context,
                                                        agents,
                                                      ).then((value) {
                                                        if (value != null) {
                                                          // context.loading;
                                                          ref
                                                              .read(
                                                                orderServicesProvider
                                                                    .notifier,
                                                              )
                                                              .assignSingleAgent(
                                                                agent: value,
                                                                order:
                                                                    order['billno'],
                                                                cartid:
                                                                    item['cartid']
                                                                        .toString(),
                                                              )
                                                              .then((_) {
                                                                if (insearch) {
                                                                  context.pop();
                                                                }
                                                                context.pop();
                                                                Fluttertoast.showToast(
                                                                  msg:
                                                                      '${value.name} assigned to order',
                                                                  gravity:
                                                                      ToastGravity
                                                                          .BOTTOM,
                                                                  textColor:
                                                                      theme
                                                                          .activeTextIconColor,
                                                                );
                                                                ref.invalidate(
                                                                  orderServicesProvider,
                                                                );
                                                              })
                                                              .onError((
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                context.pop();
                                                              });
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Text(
                                                    'Assign',
                                                    style: TextStyle(
                                                      color: theme.defultColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    if (insearch) {
                                                      context.pop();
                                                    }
                                                    Navigator.of(context).pop();
                                                    context.push(
                                                      '/orders/add_addons/${order['id']}/${item['id']}',
                                                    );
                                                  },
                                                  child: Text(
                                                    'Addon +',
                                                    style: TextStyle(
                                                      color: theme.defultColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                              : Center(
                                child: Text(
                                  'No Items for this order',
                                  style: TextStyle(color: theme.defultColor),
                                ),
                              ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 14,
                        right: 14,
                        bottom: showReassign ? 0 : 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                context
                                  ..pop()
                                  ..push('/orders/update_order/${order['id']}');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: theme.primaryBackGround,
                                side: BorderSide(
                                  color: theme.primaryBackGround,
                                ),
                                fixedSize: const Size(double.maxFinite, 20),
                              ),
                              child: const Text('UPDATE'),
                            ),
                          ),
                          if (showReassign) const SizedBox(width: 10),
                          if (showReassign)
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  if (agentsService is AsyncData) {
                                    final agents = agentsService.value ?? [];
                                    PickAgent.show(context, agents).then((
                                      value,
                                    ) {
                                      if (value != null) {
                                        ref
                                            .read(
                                              orderServicesProvider.notifier,
                                            )
                                            .assignAgent(
                                              agent: value,
                                              billno: order['billno'],
                                              orderid: order['id'],
                                            )
                                            .then((_) {
                                              if (insearch) context.pop();
                                              context
                                                ..pop()
                                                ..pop();
                                              Fluttertoast.showToast(
                                                msg:
                                                    '${value.name} assigned to order',
                                                gravity: ToastGravity.BOTTOM,
                                                textColor:
                                                    theme.activeTextIconColor,
                                              );
                                            })
                                            .onError((error, stackTrace) {
                                              context.pop();
                                            });
                                      }
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.primaryBackGround,
                                  side: BorderSide(
                                    color: theme.primaryBackGround,
                                  ),
                                  fixedSize: const Size(double.maxFinite, 20),
                                ),
                                child: const Text('RE-ASSIGN'),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 16,
                      ),
                      child: TextButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            initialDate: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                            lastDate: DateTime(2030),
                          ).then((date) {
                            if (date != null) {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((time) {
                                if (time != null) {
                                  final newDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  ref
                                      .read(orderServicesProvider.notifier)
                                      .rescheduleOrder(
                                        date: newDate,
                                        order: order['billno'],
                                      )
                                      .then((_) {
                                        context
                                          ..pop()
                                          ..pop();
                                        Fluttertoast.showToast(
                                          msg:
                                              'Order rescheduled to ${sDate3(newDate)}',
                                          gravity: ToastGravity.BOTTOM,
                                          textColor: theme.activeTextIconColor,
                                        );
                                      })
                                      .onError((error, stackTrace) {
                                        context.pop();
                                        Fluttertoast.showToast(
                                          msg: 'Error rescheduling',
                                          gravity: ToastGravity.BOTTOM,
                                          textColor: theme.activeTextIconColor,
                                        );
                                      });
                                }
                              });
                            }
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryBackGround,
                          side: BorderSide(color: theme.primaryBackGround),
                          fixedSize: const Size(double.maxFinite, 20),
                        ),
                        child: const Text('Re - Schedule'),
                      ),
                    ),
                    if (order['status'] == 'In-Service' && !readonly)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: TextButton(
                          onPressed: () {
                            if (insearch) context.pop();
                            Navigator.of(context).pop();
                            context.push('/orders/add_service/${order['id']}');
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: theme.primaryBackGround,
                            foregroundColor: theme.activeTextIconColor,
                            fixedSize: const Size(double.maxFinite, 20),
                          ),
                          child: const Text('Add Service'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return noorder(ref, theme);
  }

  Column _orderTitle(item, theme) {
    final agentName =
        item['agent'].toString().isNotEmpty ? item['agent'] : '___ ___';
    final addons = item['addons'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '👤 $agentName',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    maxLines: 3,
                    style: TextStyle(color: theme.defultColor),
                  ),
                  Text(
                    (num.tryParse(item['price'].toString()) ?? 0)
                        .toDouble()
                        .money,
                    style: TextStyle(color: theme.defultColor),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Quantity: ${item['items']}',
                  style: TextStyle(color: theme.defultColor),
                ),
                Text(
                  'Addons: ${addons.length}',
                  style: TextStyle(color: theme.defultColor),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget noorder(WidgetRef ref, ThemeConfig theme) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                child: emptyState(ref, text: 'No orders found'),
              ),
              const SizedBox(height: 16),
              Text(
                'Order Unavailable',
                style: TextStyle(color: theme.defultColor),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
