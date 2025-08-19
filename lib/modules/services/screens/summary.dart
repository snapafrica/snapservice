import 'package:intl/intl.dart';
import 'package:snapservice/common.dart';

class SummaryPage extends ConsumerStatefulWidget {
  const SummaryPage({super.key});

  @override
  ConsumerState<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends ConsumerState<SummaryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  String dateBtn = 'Today';
  (DateTime, DateTime)? rangeSales;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final summaryService = ref.watch(summaryServicesProvider);
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackGround,
        foregroundColor: theme.textIconPrimaryColor,
        centerTitle: true,
        title: const Text("Summary"),
        bottom:
            isSmallScreen
                ? PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Center(
                    child: TabBar(
                      controller: _tabController,
                      labelColor: theme.textIconPrimaryColor,
                      unselectedLabelColor: theme.textIconSecondaryColor,
                      indicatorColor: theme.textIconPrimaryColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'Store Sales'),
                        Tab(text: 'Store Summary'),
                      ],
                    ),
                  ),
                )
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            if (!isSmallScreen)
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 3, color: Colors.transparent),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.textIconPrimaryColor,
                  unselectedLabelColor: theme.textIconSecondaryColor,
                  indicatorColor: theme.textIconPrimaryColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Store Sales'),
                    Tab(text: 'Store Summary'),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
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
                          useRootNavigator:
                              SrceenType.type(context.sz).isMobile,
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
                            setState(() {
                              dateBtn = '$startStr - $endStr';
                              rangeSales = (value.start, value.end);
                            });
                            ref
                                .read(summaryServicesProvider.notifier)
                                .getStoreSales(range: rangeSales);
                            ref
                                .read(summaryServicesProvider.notifier)
                                .getStoreSummary(range: rangeSales);
                          }
                        });
                      },
                      child: Text(dateBtn),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  summaryService.storesales.when(
                    data:
                        (data) => _storeSalesWg(
                          data.cast<Map<String, dynamic>>(),
                          theme,
                        ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (err, _) => Center(
                          child: Text(
                            "Error: $err",
                            style: TextStyle(color: theme.deleteColor),
                          ),
                        ),
                  ),
                  summaryService.storesummary.when(
                    data:
                        (data) => _storeSummary(
                          data.cast<Map<String, dynamic>>(),
                          theme,
                        ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (err, _) => Center(
                          child: Text(
                            "Error: $err",
                            style: TextStyle(color: theme.deleteColor),
                          ),
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

  Widget _storeSalesWg(List<Map<String, dynamic>> data, theme) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(summaryServicesProvider);
      },
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return _summaryCard(item['store'], item, theme);
        },
      ),
    );
  }

  Widget _storeSummary(List<Map<String, dynamic>> data, theme) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(summaryServicesProvider);
      },
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return _storeSummaryCard(item, theme);
        },
      ),
    );
  }

  Widget _storeSummaryCard(Map<String, dynamic> item, theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.cardGradientStart, theme.cardGradientEnd],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(
            item['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.activeTextIconColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _summaryRow('Completed', item['completed'].toString(), theme),
              _summaryRow('In-Service', item['service'].toString(), theme),
              _summaryRow('In-Waiting', item['waiting'].toString(), theme),
              const SizedBox(height: 10),
              Text(
                'Bookings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.activeTextIconColor,
                ),
              ),
              _summaryRow(
                'Completed',
                item['completed_booked'].toString(),
                theme,
              ),
              _summaryRow(
                'In-Service',
                item['service_booked'].toString(),
                theme,
              ),
              _summaryRow(
                'In-Waiting',
                item['waiting_booked'].toString(),
                theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, Map<String, dynamic> item, theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.cardGradientStart, theme.cardGradientEnd],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.activeTextIconColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _summaryRow('Cash', item['cash'], theme),
              _summaryRow('Mpesa', item['mpesa'], theme),
              _summaryRow('Bank', item['bank'], theme),
              const Divider(),
              _summaryRow('Total', item['total'], theme, bold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, theme, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.activeTextIconColor)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: theme.activeTextIconColor,
            ),
          ),
        ],
      ),
    );
  }
}
