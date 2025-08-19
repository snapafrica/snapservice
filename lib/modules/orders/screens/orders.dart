import 'package:intl/intl.dart';
import 'package:snapservice/common.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  String dateBtn = 'Today';
  bool isWaitingSelected = true;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    bool isSmallScreen = width < 600;

    final theme = ref.watch(themeServicesProvider);
    final user =
        ref.watch(authenticationServiceProvider).valueOrNull?.user ??
        LocalStorage.nosql.user;
    final oneFilter = user?.type == EMPLOYEE_TYPE_NAME
        ? 'In-Service'
        : 'Waiting';
    final twoFilter = user?.type == EMPLOYEE_TYPE_NAME
        ? 'Complete'
        : 'In-Service';
    final ordersState = ref.watch(orderServicesProvider);
    final isloading = ordersState is OrdersLoading;
    final iserror = ordersState is OrdersError;

    final waitingOrders = ordersState.orders
        .where((element) => (element['status'] ?? 'Waiting') == oneFilter)
        .map((e) => e as Map<String, dynamic>)
        .toList();
    final inServiceOrders = ordersState.orders
        .where((element) => (element['status'] ?? 'In-Service') == twoFilter)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: isSmallScreen
          ? AppBar(
              backgroundColor: theme.secondaryBackGround,
              title: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.datePickerColor,
                    foregroundColor: theme.activeTextIconColor,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                        final baseTheme = isDarkTheme
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
                            datePickerTheme: baseTheme.datePickerTheme.copyWith(
                              rangeSelectionBackgroundColor:
                                  theme.activeBackGround,
                              rangeSelectionOverlayColor:
                                  MaterialStateProperty.all(
                                    theme.activeBackGround.withOpacity(0.2),
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
                        final endStr = DateFormat.yMMMEd().format(value.end);
                        setState(() {
                          dateBtn = '$startStr   -   $endStr';
                        });
                        ref
                            .read(orderServicesProvider.notifier)
                            .init(range: (value.start, value.end));
                      }
                    });
                  },
                  child: Text(dateBtn),
                ),
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
                    showSearch(
                      context: context,
                      useRootNavigator: false,
                      delegate: OrderSearch(
                        orders: ordersState.orders,
                        user: user,
                        theme: theme,
                        ref: ref,
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          if (!isSmallScreen)
            Row(
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
                        useRootNavigator: SrceenType.type(context.sz).isMobile,
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2090),
                        builder: (context, child) {
                          final isDarkTheme =
                              theme.secondaryBackGround ==
                              const Color(0xff17181f);
                          final baseTheme = isDarkTheme
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
                          final endStr = DateFormat.yMMMEd().format(value.end);
                          setState(() {
                            dateBtn = '$startStr   -   $endStr';
                          });
                          ref
                              .read(orderServicesProvider.notifier)
                              .init(range: (value.start, value.end));
                        }
                      });
                    },
                    child: Text(dateBtn),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    showSearch(
                      context: context,
                      useRootNavigator: false,
                      delegate: OrderSearch(
                        orders: ordersState.orders,
                        user: user,
                        theme: theme,
                        ref: ref,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: theme.primaryBackGround,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.search, color: theme.searchTextIconColor),
                  ),
                ),
              ],
            ),
          SizedBox(height: 4),
          if (isloading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: context.sz.width / 2,
                child: const LinearProgressIndicator(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                color: theme.primaryBackGround,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  // "Unassigned" Badge
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isWaitingSelected = true),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isWaitingSelected
                                  ? theme.activeBackGround
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "Unassigned",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isWaitingSelected
                                      ? theme.activeTextIconColor
                                      : theme.inactiveTextIconColor,
                                ),
                              ),
                            ),
                          ),
                          // "Unassigned" Badge
                          if (!isloading && waitingOrders.isNotEmpty)
                            Positioned(
                              top: -8,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: theme.activeTextIconColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.cardShadowColor.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${waitingOrders.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // "Assigned" Badge
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isWaitingSelected = false),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: !isWaitingSelected
                                  ? theme.activeBackGround
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "Assigned",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: !isWaitingSelected
                                      ? theme.activeTextIconColor
                                      : theme.inactiveTextIconColor,
                                ),
                              ),
                            ),
                          ),
                          // "Assigned" Badge
                          if (!isloading && inServiceOrders.isNotEmpty)
                            Positioned(
                              top: -8,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: theme.activeTextIconColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.cardShadowColor.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${inServiceOrders.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isdesktop() && !iserror && !isloading)
            IconButton(
              onPressed: () {
                setState(() {
                  dateBtn = 'Today';
                });
                ref.invalidate(orderServicesProvider);
              },
              icon: Icon(Icons.refresh, color: theme.textIconPrimaryColor),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 900
                      ? 3
                      : constraints.maxWidth > 600
                      ? 2
                      : 1;
                  double aspectRatio = constraints.maxWidth > 900
                      ? 1.6
                      : constraints.maxWidth > 600
                      ? 1.4
                      : 1.3;

                  List<Map<String, dynamic>> ordersToShow;
                  String emptyStateText = "";

                  if (isloading) {
                    return SizedBox();
                  }

                  if (isWaitingSelected) {
                    ordersToShow = waitingOrders;
                    emptyStateText = "No Unassigned Orders";
                  } else {
                    ordersToShow = inServiceOrders;
                    emptyStateText = "No Assigned Orders";
                  }

                  String? errorMessage;
                  if (ordersState is OrdersError) {
                    errorMessage = (ordersState).error;
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(orderServicesProvider);
                    },
                    child: ordersToShow.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: 100),
                              emptyState(
                                ref,
                                text: errorMessage ?? emptyStateText,
                                onRefresh: () =>
                                    ref.invalidate(orderServicesProvider),
                              ),
                            ],
                          )
                        : GridView.builder(
                            padding: EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: aspectRatio,
                                ),
                            itemCount: ordersToShow.length,
                            itemBuilder: (context, index) {
                              final order = ordersToShow[index];
                              return _buildOrderCard(
                                order,
                                context,
                                false,
                                false,
                                isWaitingSelected,
                                ref.watch(agentsServicesProvider),
                                ref,
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order,
    BuildContext context,
    bool readonly,
    bool insearch,
    bool isWaitingSelected,
    AsyncValue<List<Agent>> agentsService,
    WidgetRef ref,
  ) {
    final theme = ref.watch(themeServicesProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: theme.primaryBackGround,
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.cardGradientStart, theme.cardGradientEnd],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.cardShadowColor.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bill No: ${(order['billno'] ?? 'Unknown').split('(').first}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.activeTextIconColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Amount: ${(num.tryParse(order['amount'].toString()) ?? 0).toDouble().money}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.inactiveTextIconColor,
                  ),
                ),
                if (order['agentname'] != null &&
                    order['agentname'].toString().isNotEmpty)
                  Text(
                    "Agent: ${order['agentname']}",
                    style: TextStyle(color: theme.inactiveTextIconColor),
                  ),
                Text(
                  "Receipt: ${order['receipt'] ?? 'N/A'}",
                  style: TextStyle(color: theme.inactiveTextIconColor),
                ),
                Text(
                  order['date'] != null
                      ? DateFormat.yMMMEd().format(
                          DateTime.tryParse(order['date']) ?? DateTime.now(),
                        )
                      : "No Date",
                  style: TextStyle(color: theme.inactiveTextIconColor),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          OrderView.show(
                            context,
                            order['id'],
                            readonly: readonly,
                            insearch: insearch,
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: theme.secondaryBackGround,
                          foregroundColor: theme.textIconPrimaryColor,
                        ),
                        child: const Text("View"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!readonly)
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (isWaitingSelected) {
                              // Assign Agent Flow
                              if (agentsService is AsyncData) {
                                final theme = ref.watch(themeServicesProvider);
                                final agents = (agentsService.value ?? [])
                                    .where((element) => !element.archived)
                                    .toList();
                                PickAgent.show(context, agents).then((value) {
                                  if (value != null) {
                                    context.loading;
                                    ref
                                        .read(orderServicesProvider.notifier)
                                        .assignAgent(
                                          agent: value,
                                          billno: order['billno'],
                                          orderid: order['id'],
                                        )
                                        .then((_) {
                                          context.pop();
                                          context.showToast(
                                            '${value.name} assigned to order',
                                            textColor:
                                                theme.textIconPrimaryColor,
                                          );
                                        })
                                        .onError((error, stackTrace) {
                                          context.pop();
                                          context.showToast(
                                            'Failed to assign agent',
                                            error: true,
                                            textColor:
                                                theme.textIconPrimaryColor,
                                          );
                                        });
                                  }
                                });
                              }
                            } else {
                              // Complete Order Flow
                              if (insearch) context.pop();
                              context.push('/orders/complete/${order['id']}');
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: isWaitingSelected
                                ? theme.secondaryBackGround
                                : theme.secondaryBackGround,
                            foregroundColor: theme.textIconPrimaryColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isWaitingSelected ? "Assign" : "Complete",
                                maxLines: 1,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isWaitingSelected
                                    ? Icons.person_add_alt_1_rounded
                                    : Icons.check_circle_outline,
                                size: 16,
                                color: theme.textIconPrimaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
