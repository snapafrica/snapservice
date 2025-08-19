import 'package:intl/intl.dart';
import 'package:snapservice/common.dart';

class BookedOrdersPage extends ConsumerStatefulWidget {
  const BookedOrdersPage({super.key});

  static Widget orderDetails(
    Map<dynamic, dynamic> order, {
    VoidCallback? onTap,
    bool showDate = true,
    required ThemeConfig theme,
  }) {
    return Card(
      color: theme.primaryBackGround,
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
        child: ListTile(
          onTap: onTap,
          title: Text.rich(
            TextSpan(
              text: order['billno'],
              style: TextStyle(color: theme.activeTextIconColor),
              children: [
                TextSpan(
                  text:
                      '\nAmount :${(order['amount'] as num).toDouble().money}',
                  style: TextStyle(color: theme.activeTextIconColor),
                ),
              ],
            ),
          ),
          subtitle: Text.rich(
            TextSpan(
              text: 'Payment : ${order['type']}',
              style: TextStyle(color: theme.inactiveTextIconColor),
              children: [
                TextSpan(text: '\nTicket : ${order['receipt']}'),
                TextSpan(text: '\nCompleted By : ${order['agentname']}'),
                if (showDate)
                  TextSpan(
                    text:
                        '\nCompleted On : ${DateFormat.yMMMd().format(DateTime.tryParse(order['endTime'] ?? '') ?? DateTime.now())}',
                    style: TextStyle(color: theme.activeTextIconColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<BookedOrdersPage> createState() => _BookedOrdersPageState();
}

class _BookedOrdersPageState extends ConsumerState<BookedOrdersPage> {
  String dateBtn = 'Today';
  (DateTime, DateTime)? range;
  bool showDate = true;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final bookedOrdersService = ref.watch(bookedOrderServicesProvider);
    final agentsService = ref.watch(agentsServicesProvider);

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackGround,
        foregroundColor: theme.textIconPrimaryColor,
        centerTitle: true,
        title: const Text('Booked Orders'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                showSearch(
                  context: context,
                  useRootNavigator: false,
                  delegate: BookedOrdersSearch(
                    orders: bookedOrdersService.value ?? [],
                  ),
                );
              },
              icon: const Icon(Icons.search_rounded),
              label: const Text('Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondaryBackGround,
                foregroundColor: theme.textIconPrimaryColor,
                iconColor: theme.textIconPrimaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _filterButton(theme),
          Expanded(
            child: bookedOrdersService.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => SizedBox.fromSize(),
              data: (data) {
                if (data.isEmpty) {
                  return emptyState(
                    ref,
                    text: 'No Booked Orders',
                    onRefresh:
                        () => ref.invalidate(bookedOrderServicesProvider),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(bookedOrderServicesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final order = data[index];
                      return BookedOrdersPage.orderDetails(
                        order,
                        showDate: true,
                        onTap:
                            () => showOrderDetails(
                              order['orderItems'],
                              order['billno'],
                              order['id'] as int,
                              DateTime.tryParse(
                                order['endTime'] as String? ?? '',
                              ),
                              agentsService,
                            ),
                        theme: theme,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Filter button for date range selection
  Widget _filterButton(theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.datePickerColor,
                foregroundColor: theme.activeTextIconColor,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              onPressed: () {
                showDateRangePicker(
                  useRootNavigator: SrceenType.type(context.sz).isMobile,
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2090),
                  builder: (context, child) {
                    final isDarkTheme =
                        theme.secondaryBackGround == const Color(0xff17181f);
                    final baseTheme =
                        isDarkTheme ? ThemeData.dark() : ThemeData.light();

                    return Theme(
                      data: baseTheme.copyWith(
                        primaryColor: theme.datePickerPrimaryColor,
                        scaffoldBackgroundColor:
                            theme.datePickerDialogBackgroundColor,
                        dialogBackgroundColor: theme.datePickerBackgroundColor,
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
                          rangeSelectionBackgroundColor: theme.activeBackGround,
                          rangeSelectionOverlayColor: MaterialStateProperty.all(
                            theme.activeBackGround.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                ).then((value) {
                  if (value != null) {
                    final startStr = DateFormat.yMMMEd().format(value.start);
                    final endStr = DateFormat.yMMMEd().format(value.end);
                    dateBtn = '$startStr   -   $endStr';
                    range = (value.start, value.end);
                    setState(() {});
                    ref
                        .read(bookedOrderServicesProvider.notifier)
                        .init(range: (value.start, value.end));
                  }
                });
              },
              child: Text(dateBtn),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showOrderDetails(
    List<dynamic> details,
    String bill,
    int orderid,
    DateTime? end,
    AsyncValue<List<Agent>> agentsService,
  ) {
    return showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        final size = context.sz;
        final maxWidth = getMaxWidth(size.width);
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
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bill,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: size.height / 2,
                        minHeight: 100,
                      ),
                      child: ListView.builder(
                        itemCount: details.length,
                        padding: const EdgeInsets.all(14),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final item = details[index] as Map<String, dynamic>;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['agent'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name']),
                                          Text(
                                            (num.tryParse(
                                                      item['price'].toString(),
                                                    ) ??
                                                    0)
                                                .toDouble()
                                                .money,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text('Quantity: ${item['items']}'),
                                          const Text('Addons: 0'),
                                        ],
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
                    // Padding(
                    //   padding: const EdgeInsets.only(
                    //       left: 14, right: 14, bottom: 16),
                    //   child: TextButton(
                    //     onPressed: () {},
                    //     style: TextButton.styleFrom(
                    //       foregroundColor: AppTheme.darkGreen,
                    //       side: const BorderSide(
                    //         color: AppTheme.darkGreen,
                    //       ),
                    //       fixedSize: const Size(double.maxFinite, 20),
                    //     ),
                    //     child: const Text('PAY'),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BookedOrdersSearch extends SearchDelegate {
  BookedOrdersSearch({required this.orders});
  final List<Map<dynamic, dynamic>> orders;

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
    return _buildOutput(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildOutput(context);
  }

  // Build search results output
  Widget _buildOutput(BuildContext context) {
    final searched = orders.where(
      (element) => element['agentname'].toString().toLowerCase().contains(
        query.toLowerCase(),
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, cs) {
                  final maxWidth = cs.maxWidth;
                  return Consumer(
                    builder: (context, ref, _) {
                      final theme = ref.watch(themeServicesProvider);
                      return Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: maxWidth,
                          child: ListView.builder(
                            itemCount: searched.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: theme.primaryBackGround,
                                child: BookedOrdersPage.orderDetails(
                                  searched.elementAt(index),
                                  theme: theme,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
