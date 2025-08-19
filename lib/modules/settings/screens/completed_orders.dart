import 'dart:async';
import 'package:intl/intl.dart';
import 'package:snapservice/common.dart';

class CompletedOrdersPage extends ConsumerStatefulWidget {
  const CompletedOrdersPage({super.key});

  static Future<void> showOrderDetails({
    required BuildContext context,
    required WidgetRef ref,
    required List<dynamic> details,
    required String bill,
    required int orderid,
    DateTime? end,
    required AsyncValue<List<Agent>> agentsService,
  }) {
    return showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        final size = context.sz;
        final maxWidth = getMaxWidth(size.width);
        final theme = ref.watch(themeServicesProvider);

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: maxWidth,
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context, bill),
                    _buildOrderList(
                      context,
                      details,
                      size,
                      agentsService,
                      ref,
                      bill,
                      end != null ? (DateTime(0), end) : null,
                      theme,
                    ),
                    _buildReassignButton(
                      ref,
                      context,
                      bill,
                      orderid,
                      agentsService,
                      theme,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildHeader(BuildContext context, String bill) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(bill, style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  static Widget _buildOrderList(
    BuildContext context,
    List<dynamic> details,
    Size size,
    AsyncValue<List<Agent>> agentsService,
    WidgetRef ref,
    String bill,
    (DateTime start, DateTime end)? range,
    ThemeConfig theme,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: size.height / 2, minHeight: 100),
      child: ListView.builder(
        itemCount: details.length,
        padding: const EdgeInsets.all(14),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final item = details[index] as Map<String, dynamic>;
          final addons = item['addons'] as List<dynamic>? ?? [];
          final orderId = item['orderid'] as int? ?? 0;
          return addons.isNotEmpty
              ? _buildAddonExpansionTile(item, addons)
              : _buildOrderCard(
                agentsService,
                context,
                ref,
                bill,
                orderId,
                item,
                range,
                theme,
              );
        },
      ),
    );
  }

  static Widget _buildAddonExpansionTile(
    Map<String, dynamic> item,
    List<dynamic> addons,
  ) {
    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['agent'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('${item['name']} x ${item['items']}'),
        ],
      ),
      subtitle: Text(
        (num.tryParse(item['price'].toString()) ?? 0).toDouble().money,
      ),
      childrenPadding: const EdgeInsets.only(left: 16),
      children: addons.map((addon) => _buildAddonCard(addon)).toList(),
    );
  }

  static Widget _buildAddonCard(Map<String, dynamic> addon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Text(addon['agent'])]),
            Text(addon['name'] ?? ''),
            Text(
              (num.tryParse(addon['price'].toString()) ?? 0).toDouble().money,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildOrderCard(
    AsyncValue<List<Agent>> agentsService,
    BuildContext context,
    WidgetRef ref,
    String bill,
    int orderid,
    Map<String, dynamic> item,
    (DateTime start, DateTime end)? range,
    ThemeConfig theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['agent'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] ?? ''),
                    Text(
                      (num.tryParse(item['price'].toString()) ?? 0)
                          .toDouble()
                          .money,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Quantity: ${item['items']}'),
                    Text('Addons: ${item['addons'].length}'),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () {
                    onReassignSingle(
                      agentsService,
                      context,
                      ref,
                      bill,
                      orderid,
                      item,
                      range,
                      theme,
                    );
                  },
                  child: const Text('Re-Assign'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildReassignButton(
    WidgetRef ref,
    BuildContext context,
    String bill,
    int orderid,
    AsyncValue<List<Agent>> agentsService,
    ThemeConfig theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 16),
      child: TextButton(
        onPressed: () {
          onReassign(agentsService, context, ref, bill, orderid, theme);
        },
        style: TextButton.styleFrom(
          foregroundColor: theme.primaryBackGround,
          side: BorderSide(color: theme.primaryBackGround),
          fixedSize: const Size(double.maxFinite, 20),
        ),
        child: const Text('Re - Assign'),
      ),
    );
  }

  static void onReassign(
    AsyncValue<List<Agent>> agentsService,
    BuildContext context,
    WidgetRef ref,
    String bill,
    int orderid,
    ThemeConfig theme,
  ) {
    if (agentsService is AsyncData) {
      final agents = agentsService.value ?? [];
      PickAgent.show(context, agents).then((value) {
        if (value != null) {
          context.loading;
          ref
              .read(completedOrderServicesProvider.notifier)
              .assignAgent(agent: value, billno: bill, orderid: orderid)
              .then((_) {
                context
                  ..pop()
                  ..pop();
                context.showToast(
                  '${value.name} assigned to order',
                  textColor: theme.textIconPrimaryColor,
                );
              })
              .onError((error, stackTrace) {
                context.pop();
              });
        }
      });
    }
  }

  static void onReassignSingle(
    AsyncValue<List<Agent>> agentsService,
    BuildContext context,
    WidgetRef ref,
    String bill,
    int orderid,
    Map<String, dynamic> item,
    (DateTime start, DateTime end)? range,
    ThemeConfig theme,
  ) {
    if (agentsService is AsyncData) {
      final agents = agentsService.value ?? [];
      final useagents =
          agents.where((element) {
            return !element.archived;
          }).toList();
      PickAgent.show(context, useagents).then((value) {
        if (value != null) {
          context.loading;
          ref
              .read(completedOrderServicesProvider.notifier)
              .assignAgentSingle(
                agent: value,
                billno: bill,
                orderid: orderid,
                cartid: '${item['cartid']}',
                range: range,
              )
              .then((_) {
                context
                  ..pop()
                  ..pop();
                context.showToast(
                  '${value.name} assigned to order',
                  textColor: theme.textIconPrimaryColor,
                );
              })
              .onError((error, stackTrace) {
                context.pop();
              });
        }
      });
    }
  }

  @override
  ConsumerState<CompletedOrdersPage> createState() =>
      _CompletedOrdersPageState();
}

class _CompletedOrdersPageState extends ConsumerState<CompletedOrdersPage> {
  TextEditingController searchController = TextEditingController();

  String dateBtn = 'Today';
  (DateTime, DateTime)? range;

  bool showDate = true;
  String sortBy = "date";
  bool ascending = true;
  DateTime? fromDate, toDate;

  @override
  void initState() {
    super.initState();
    ascending = false;
    fetchOrders();
  }

  void fetchOrders() {
    ref.read(completedOrderServicesProvider.notifier).init();
  }

  List<Map<String, dynamic>> get filteredOrders {
    final orders = ref.watch(completedOrderServicesProvider).value ?? [];
    List<Map<String, dynamic>> sortedList = List.from(
      orders.where((order) {
        bool matchesSearch = order["agentname"].toLowerCase().contains(
          searchController.text.toLowerCase(),
        );

        bool matchesDate = true;
        if (fromDate != null && toDate != null) {
          DateTime orderDate = DateTime.parse(order["date"]);
          matchesDate =
              orderDate.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
              orderDate.isBefore(toDate!.add(const Duration(days: 1)));
        }

        return matchesSearch && matchesDate;
      }),
    );

    sortedList.sort((a, b) {
      var aValue = a[sortBy];
      var bValue = b[sortBy];

      if (sortBy == "date" && aValue is String && bValue is String) {
        aValue = DateTime.parse(aValue);
        bValue = DateTime.parse(bValue);
      }

      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });

    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    bool isSmallScreen = width < 600;

    final theme = ref.watch(themeServicesProvider);
    final completedOrdersService = ref.watch(completedOrderServicesProvider);
    final agentsService = ref.watch(agentsServicesProvider);
    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackGround,
        foregroundColor: theme.textIconPrimaryColor,
        centerTitle: true,
        title: Text(
          "Completed Orders",
          style: TextStyle(color: theme.textIconPrimaryColor),
        ),
        actions: [
          if (!isSmallScreen)
            IconButton(
              onPressed: () {
                ref
                    .read(completedOrderServicesProvider.notifier)
                    .init(range: range);
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          TextButton.icon(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CompletedOrdersSearch(
                  orders: completedOrdersService.value ?? [],
                  onTap: (order) {
                    CompletedOrdersPage.showOrderDetails(
                      context: context,
                      ref: ref,
                      details: order['orderItems'],
                      bill: order['billno'],
                      orderid: order['id'] as int,
                      end: DateTime.tryParse(order['endTime'] as String? ?? ''),
                      agentsService: agentsService,
                    );
                  },
                ),
              );
            },
            icon: Icon(Icons.search_rounded, color: theme.textIconPrimaryColor),
            label: Text(
              'Search',
              style: TextStyle(color: theme.textIconPrimaryColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.datePickerColor,
                        foregroundColor: theme.activeTextIconColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        showDateRangePicker(
                          useRootNavigator: false,
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2090),
                          builder: (context, child) {
                            final isDarkTheme =
                                theme.secondaryBackGround ==
                                const Color(0xff17181f);
                            final baseTheme =
                                isDarkTheme
                                    ? ThemeData.dark()
                                    : ThemeData.light();

                            return Theme(
                              data: baseTheme.copyWith(
                                primaryColor: theme.datePickerPrimaryColor,
                                scaffoldBackgroundColor:
                                    theme.datePickerDialogBackgroundColor,
                                dialogBackgroundColor:
                                    theme.datePickerBackgroundColor,
                                colorScheme: baseTheme.colorScheme.copyWith(
                                  primary: theme.datePickerPrimaryColor,
                                  onPrimary: theme.activeTextIconColor,
                                  surface: theme.datePickerBackgroundColor,
                                  onSurface: theme.textIconPrimaryColor,
                                ),
                                textTheme: baseTheme.textTheme.copyWith(
                                  headlineMedium: TextStyle(
                                    color: theme.textIconPrimaryColor,
                                  ),
                                  titleMedium: TextStyle(
                                    color: theme.textIconPrimaryColor,
                                  ),
                                  bodyMedium: TextStyle(
                                    color: theme.textIconPrimaryColor,
                                  ),
                                ),
                                datePickerTheme: baseTheme.datePickerTheme
                                    .copyWith(
                                      rangeSelectionBackgroundColor:
                                          theme.activeBackGround,
                                      rangeSelectionOverlayColor:
                                          MaterialStateProperty.all(
                                            theme.activeBackGround.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                    ),
                              ),
                              child: child!,
                            );
                          },
                        ).then((value) {
                          if (value != null) {
                            final startStr = DateFormat.yMMMEd().format(
                              value.start,
                            );
                            final endStr = DateFormat.yMMMEd().format(
                              value.end,
                            );
                            dateBtn = '$startStr   -   $endStr';
                            range = (value.start, value.end);
                            setState(() {});
                            ref
                                .read(completedOrderServicesProvider.notifier)
                                .init(range: (value.start, value.end));
                          }
                        });
                      },
                      child: Text(dateBtn),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: sortBy,
                  onChanged: (newValue) {
                    setState(() {
                      sortBy = newValue!;
                    });
                  },
                  items:
                      ["agentname", "date", "amount"].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                            "Sort by ${value[0].toUpperCase()}${value.substring(1)}",
                            style: TextStyle(color: theme.textIconPrimaryColor),
                          ),
                        );
                      }).toList(),
                  dropdownColor: theme.secondaryBackGround,
                  focusColor: theme.secondaryBackGround,
                  iconEnabledColor: theme.textIconPrimaryColor,
                ),
                IconButton(
                  icon: Icon(
                    ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: theme.textIconPrimaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      ascending = !ascending;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(completedOrderServicesProvider);
                },
                child: completedOrdersService.when(
                  data: (orders) {
                    return orders.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                          child: ListView.builder(
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              var order = filteredOrders[index];
                              return InkWell(
                                onTap: () {
                                  CompletedOrdersPage.showOrderDetails(
                                    context: context,
                                    ref: ref,
                                    details: order['orderItems'],
                                    bill: order['billno'],
                                    orderid: order['id'] as int,
                                    end: DateTime.tryParse(
                                      order['endTime'] as String? ?? '',
                                    ),
                                    agentsService: agentsService,
                                  );
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Card(
                                  color: theme.primaryBackGround,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(
                                      "${order['billno']} ‣ ${order['agentname']}\n${(num.tryParse(order['amount'].toString()) ?? 0).toDouble().money}",
                                      style: TextStyle(
                                        color: theme.activeTextIconColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Payment: ${order['type']}\n"
                                      "Ticket: ${order['receipt']}\n"
                                      "Completed by: ${order['completed']}\n"
                                      "${showDate ? order['date'] : ''}",
                                      style: TextStyle(
                                        color: theme.inactiveTextIconColor,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            CompletedOrdersPage.showOrderDetails(
                                              context: context,
                                              ref: ref,
                                              details: order['orderItems'],
                                              bill: order['billno'],
                                              orderid: order['id'] as int,
                                              end: DateTime.tryParse(
                                                order['endTime'] as String? ??
                                                    '',
                                              ),
                                              agentsService: agentsService,
                                            );
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: theme.activeTextIconColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                  },
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  loading: () => Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedOrdersSearch extends SearchDelegate {
  CompletedOrdersSearch({required this.orders, required this.onTap});
  final List<Map<dynamic, dynamic>> orders;
  final ValueChanged<Map<dynamic, dynamic>> onTap;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final theme = container.read(themeServicesProvider);
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: theme.secondaryBackGround,
      appBarTheme: AppBarTheme(
        backgroundColor: theme.secondaryBackGround,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textIconPrimaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.secondaryBackGround,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: theme.textIconSecondaryColor),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: theme.textIconPrimaryColor),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return null;
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildOrderList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildOrderList(context);
  }

  Widget _buildOrderList(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final theme = container.read(themeServicesProvider);
    final searched =
        orders.where((element) {
          return element['agentname'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              element['billno'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              element['customer'].toString().toLowerCase().contains(
                query.toLowerCase(),
              );
        }).toList();

    return LayoutBuilder(
      builder: (context, cs) {
        return ListView.builder(
          itemCount: searched.length,
          itemBuilder: (context, index) {
            final order = searched[index];
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Card(
                color: theme.primaryBackGround,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => onTap(order),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      "${order['billno']} ‣ ${order['agentname']}",
                      style: TextStyle(color: theme.activeTextIconColor),
                    ),
                    subtitle: Text(
                      "Payment: ${order['type']}\nTicket: ${order['receipt']}\nCompleted by: ${order['completed']}",
                      style: TextStyle(color: theme.inactiveTextIconColor),
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                      color: theme.successColor,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
