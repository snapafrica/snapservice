import 'package:intl/intl.dart';
import 'package:snapservice/common.dart';

class MpesaCodesPage extends ConsumerStatefulWidget {
  const MpesaCodesPage({super.key});

  @override
  ConsumerState<MpesaCodesPage> createState() => _MpesaCodesPageState();
}

class _MpesaCodesPageState extends ConsumerState<MpesaCodesPage> {
  String dateBtn = 'Today';
  (DateTime, DateTime)? range;
  bool? isUsed;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final mpesaCodesService = ref.watch(mpesaCodesServicesProvider);

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackGround,
        foregroundColor: theme.textIconPrimaryColor,
        centerTitle: true,
        title: Text(
          "Mpesa Codes",
          style: TextStyle(color: theme.textIconPrimaryColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              if (mpesaCodesService is AsyncData) {
                showSearch(
                  context: context,
                  delegate: MpesaCodesSearch(
                    codes:
                        (mpesaCodesService.value ?? [])
                            .map((e) => Map<String, dynamic>.from(e))
                            .toList(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.datePickerColor,
                      foregroundColor: theme.activeTextIconColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => _selectDateRange(),
                    child: Text(dateBtn),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: mpesaCodesService.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => Center(
                    child: Text(
                      'Failed to load data',
                      style: TextStyle(color: theme.textIconPrimaryColor),
                    ),
                  ),
              data:
                  (data) =>
                      data.isEmpty
                          ? Center(
                            child: Text(
                              'No Mpesa Codes Found',
                              style: TextStyle(
                                color: theme.textIconPrimaryColor,
                              ),
                            ),
                          )
                          : RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(mpesaCodesServicesProvider);
                            },
                            child: ListView.builder(
                              itemCount: data.length,
                              padding: const EdgeInsets.all(8),
                              itemBuilder:
                                  (context, index) => _buildMpesaCard(
                                    Map<String, dynamic>.from(data[index]),
                                    theme,
                                  ),
                            ),
                          ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primaryBackGround,
        foregroundColor: theme.activeTextIconColor,
        elevation: 6,
        icon: const Icon(Icons.filter_list, size: 24),
        label: Text(
          isUsed == null
              ? 'All Codes'
              : (isUsed! ? 'Used Codes' : 'Unused Codes'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          SelectItem.show(context, [
            'ALL CODES',
            'USED CODES',
            'UNUSED CODES',
          ]).then((value) {
            if (value != null) {
              ref.read(mpesaCodesServicesProvider.notifier).filter(value);
              setState(() {
                isUsed =
                    value == 'USED CODES'
                        ? true
                        : value == 'UNUSED CODES'
                        ? false
                        : null;
              });
            }
          });
        },
      ),
    );
  }

  /// **Date Range Picker**
  void _selectDateRange() async {
    final theme = ref.watch(themeServicesProvider);
    final picked = await showDateRangePicker(
      useRootNavigator: false,
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2090),
      builder: (context, child) {
        final isDarkTheme =
            theme.secondaryBackGround == const Color(0xff17181f);
        final baseTheme = isDarkTheme ? ThemeData.dark() : ThemeData.light();

        return Theme(
          data: baseTheme.copyWith(
            primaryColor: theme.datePickerPrimaryColor,
            scaffoldBackgroundColor: theme.datePickerDialogBackgroundColor,
            dialogBackgroundColor: theme.datePickerBackgroundColor,
            colorScheme: baseTheme.colorScheme.copyWith(
              primary: theme.datePickerPrimaryColor,
              onPrimary: theme.activeTextIconColor,
              surface: theme.datePickerBackgroundColor,
              onSurface: theme.textIconPrimaryColor,
            ),
            textTheme: baseTheme.textTheme.copyWith(
              headlineMedium: TextStyle(color: theme.textIconPrimaryColor),
              titleMedium: TextStyle(color: theme.textIconPrimaryColor),
              bodyMedium: TextStyle(color: theme.textIconPrimaryColor),
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
    );

    if (picked != null) {
      final startStr = DateFormat.yMMMEd().format(picked.start);
      final endStr = DateFormat.yMMMEd().format(picked.end);
      setState(() {
        dateBtn = '$startStr   -   $endStr';
      });

      ref
          .read(mpesaCodesServicesProvider.notifier)
          .init(range: (picked.start, picked.end));
    }
  }

  /// **Build Mpesa Code Card**
  Widget _buildMpesaCard(Map<String, dynamic> tn, theme) {
    bool used = tn['used'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [theme.cardGradientStart, theme.cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.cardShadowColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(3, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            if (used)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.activeBackGround,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'USED',
                    style: TextStyle(
                      color: theme.activeTextIconColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (used)
              Banner(
                message: 'USED',
                location: BannerLocation.topEnd,
                color: theme.activeBackGround,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat(
                      'MMM d, y • hh:mm a',
                    ).format(DateTime.parse(tn['date'])),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.activeTextIconColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customer: ${tn['username']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.inactiveTextIconColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Phone: ${tn['phone']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.inactiveTextIconColor,
                    ),
                  ),
                  Text(
                    'Amount: ${(num.tryParse(tn['amount'].toString()) ?? 0).toDouble().money}',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.inactiveTextIconColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction Code: ${tn['transcode']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: used ? theme.deleteColor : theme.successColor,
                          decoration: used ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      used
                          ? const SizedBox()
                          : IconButton(
                            icon: Icon(
                              Icons.copy,
                              color: theme.inactiveBackGround,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: tn['transcode']),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transaction Code Copied!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                  if (used) Divider(color: theme.inactiveBackGround),
                  if (used)
                    Text(
                      'Bill No. ${tn['bill_no']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.activeTextIconColor,
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
}

class MpesaCodesSearch extends SearchDelegate {
  final List<Map<String, dynamic>> codes;

  MpesaCodesSearch({required this.codes});

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
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final theme = container.read(themeServicesProvider);
    List<Map<String, dynamic>> searched =
        codes.where((tn) {
          return tn['username'].toLowerCase().contains(query.toLowerCase()) ||
              tn['phone'].contains(query) ||
              tn['transcode'].toLowerCase().contains(query.toLowerCase());
        }).toList();

    return Container(
      color: theme.secondaryBackGround,
      child:
          searched.isEmpty
              ? Center(
                child: Text(
                  'No results found',
                  style: TextStyle(color: theme.textIconPrimaryColor),
                ),
              )
              : ListView.builder(
                itemCount: searched.length,
                padding: const EdgeInsets.all(8),
                itemBuilder:
                    (context, index) =>
                        _buildMpesaCard(context, searched[index]),
              ),
    );
  }

  Widget _buildMpesaCard(BuildContext context, Map<String, dynamic> tn) {
    final container = ProviderScope.containerOf(context);
    final theme = container.read(themeServicesProvider);
    bool used = tn['used'];
    return Card(
      color: theme.primaryBackGround,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          if (used)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.activeBackGround,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'USED',
                  style: TextStyle(
                    color: theme.activeTextIconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (used)
            Banner(
              message: 'USED',
              location: BannerLocation.topEnd,
              color: theme.activeBackGround,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat(
                    'MMM d, y • hh:mm a',
                  ).format(DateTime.parse(tn['date'])),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.activeTextIconColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Customer: ${tn['username']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.inactiveTextIconColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Phone: ${tn['phone']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.inactiveTextIconColor,
                  ),
                ),
                Text(
                  'Amount: ${(num.tryParse(tn['amount'].toString()) ?? 0).toDouble().money}',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.inactiveTextIconColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction Code: ${tn['transcode']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: used ? theme.deleteColor : theme.successColor,
                        decoration: used ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (!used)
                      IconButton(
                        icon: Icon(Icons.copy, color: theme.inactiveBackGround),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: tn['transcode']),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaction Code Copied!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                  ],
                ),
                if (used) Divider(color: theme.inactiveBackGround),
                if (used)
                  Text(
                    'Bill No. ${tn['bill_no']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.activeTextIconColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
