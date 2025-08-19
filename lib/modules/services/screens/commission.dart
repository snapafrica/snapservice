import 'package:intl/intl.dart';
import 'package:snapservice/common.dart';

class CommissionPage extends ConsumerStatefulWidget {
  const CommissionPage({super.key});

  @override
  ConsumerState<CommissionPage> createState() => _CommissionPageState();
}

class _CommissionPageState extends ConsumerState<CommissionPage> {
  String dateBtn = 'Today';
  String selectedBranch = 'All Shops';

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final commissions = ref.watch(commissionServicesProvider);
    final branchesService = ref.watch(branchesServicesProvider);
    final user =
        ref.watch(authenticationServiceProvider).valueOrNull?.user ??
        LocalStorage.nosql.user;

    List<String> branchNames = ['All Shops'];
    if (branchesService is AsyncData) {
      branchNames.addAll(
        branchesService.value?.map((branch) => branch['name'].toString()) ?? [],
      );
    }

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackGround,
        foregroundColor: theme.textIconPrimaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (user?.type != EMPLOYEE_TYPE_NAME)
              IntrinsicWidth(
                child: _buildDropdown(
                  value: selectedBranch,
                  items: branchNames,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedBranch = value);
                      ref
                          .read(commissionServicesProvider.notifier)
                          .filter(value);
                    }
                  },
                  theme: theme,
                ),
              ),
            if (commissions is AsyncData)
              IconButton(
                icon: Icon(Icons.search, color: theme.textIconPrimaryColor),
                onPressed: () {
                  showSearch(
                    context: context,
                    useRootNavigator: false,
                    delegate: CommissionSearch(
                      commissions:
                          (commissions.value ?? [])
                              .map((e) => Map<String, dynamic>.from(e))
                              .toList(),
                      ref: ref,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDateSelector(theme),
          Expanded(
            child: commissions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const SizedBox.shrink(),
              data: (data) {
                if (data.isEmpty) {
                  return emptyState(
                    ref,
                    text: 'No commissions available',
                    onRefresh: () => ref.invalidate(commissionServicesProvider),
                  );
                }
                data.sort(
                  (a, b) => (double.tryParse(b['amount'].toString()) ?? 0.0)
                      .compareTo(
                        (double.tryParse(a['amount'].toString()) ?? 0.0),
                      ),
                );
                return _buildGridView(
                  data.map((e) => Map<String, dynamic>.from(e)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeConfig theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackGround,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: theme.textIconPrimaryColor,
        ),
        items:
            items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(color: theme.textIconPrimaryColor),
                ),
              );
            }).toList(),
        onChanged: onChanged,
        dropdownColor: theme.secondaryBackGround,
      ),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount =
            constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 600
                ? 3
                : constraints.maxWidth > 400
                ? 2
                : 1;
        double aspectRatio =
            constraints.maxWidth > 900
                ? 1.8
                : constraints.maxWidth > 600
                ? 1.3
                : constraints.maxWidth > 400
                ? 1.5
                : 2.2;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(commissionServicesProvider);
            return Future.delayed(const Duration());
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return CommissionCard(
                data: data[index],
                width: constraints.maxWidth / crossAxisCount - 20,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDateSelector(theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        children: [
          Row(
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
                            theme.secondaryBackGround ==
                            const Color(0xff17181f);
                        final baseTheme =
                            isDarkTheme ? ThemeData.dark() : ThemeData.light();

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
                            .read(commissionServicesProvider.notifier)
                            .init(range: (value.start, value.end));
                      }
                    });
                  },
                  child: Text(dateBtn),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommissionCard extends ConsumerWidget {
  final Map<String, dynamic> data;
  final double width;

  const CommissionCard({super.key, required this.data, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServicesProvider);
    return Container(
      width: width,
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.activeTextIconColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Divider(color: theme.activeTextIconColor.withOpacity(0.3)),
              const SizedBox(height: 10),
              _buildInfoRow(
                "Amount",
                (num.tryParse(data['amount'].toString()) ?? 0).toDouble().money,
                theme,
              ),
              const SizedBox(height: 5),
              _buildInfoRow(
                "Commission",
                (num.tryParse(data['commission'].toString()) ?? 0)
                    .toDouble()
                    .money,
                theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.activeTextIconColor.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.activeTextIconColor,
          ),
        ),
      ],
    );
  }
}

class CommissionSearch extends SearchDelegate {
  final List<Map<String, dynamic>> commissions;
  final WidgetRef ref;
  CommissionSearch({required this.commissions, required this.ref});

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
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildOutput(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildOutput(context);

  Widget _buildOutput(BuildContext context) {
    final searched =
        commissions
            .where(
              (e) => e['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();

    return searched.isEmpty
        ? Center(child: emptyState(ref, text: 'No commission found'))
        : LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount =
                constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 600
                    ? 3
                    : constraints.maxWidth > 400
                    ? 2
                    : 1;

            double aspectRatio =
                constraints.maxWidth > 900
                    ? 1.8
                    : constraints.maxWidth > 600
                    ? 1.3
                    : constraints.maxWidth > 400
                    ? 1.5
                    : 2.2;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: searched.length,
              itemBuilder: (context, index) {
                return CommissionCard(
                  data: searched[index],
                  width: constraints.maxWidth / crossAxisCount - 20,
                );
              },
            );
          },
        );
  }
}
