import 'package:intl/intl.dart';
import 'package:snapservice/common.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? dateRange;
  String productSearch = "";
  String distributedSearch = "";

  final List<Map<String, dynamic>> allProducts = [
    {
      "name": "Shampoo",
      "variants": ["500ml", "1L"],
      "branches": {
        "Branch 1": {"500ml": 10, "1L": 15},
        "Branch 2": {"500ml": 8, "1L": 5},
      },
      "warehouse": {"500ml": 30, "1L": 20},
    },
    {
      "name": "Conditioner",
      "variants": ["250ml", "500ml"],
      "branches": {
        "Branch 1": {"250ml": 5, "500ml": 10},
        "Branch 2": {"250ml": 3, "500ml": 7},
      },
      "warehouse": {"250ml": 15, "500ml": 10},
    },
  ];

  final List<Map<String, dynamic>> branches = [
    {
      "name": "Branch 1",
      "products": [
        {
          "name": "Shampoo",
          "variants": {"500ml": 10, "1L": 15},
        },
        {
          "name": "Conditioner",
          "variants": {"250ml": 5, "500ml": 10},
        },
      ],
    },
    {
      "name": "Branch 2",
      "products": [
        {
          "name": "Face Cream",
          "variants": {"100ml": 20, "200ml": 12},
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    bool isSmallScreen = width < 600;

    final theme = ref.watch(themeServicesProvider);
    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar:
          isSmallScreen
              ? AppBar(
                backgroundColor: theme.secondaryBackGround,
                title: _buildTabBar(theme),
              )
              : null,
      body: Column(
        children: [
          if (!isSmallScreen) _buildTabBarContainer(theme),
          _buildDateRangePicker(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAllProducts(), _buildDistributedProducts()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(theme) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
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
          tabs: const [
            Tab(text: "All Products"),
            Tab(text: "Distributed Products"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarContainer(theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.3,
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
            tabs: const [
              Tab(text: "All Products"),
              Tab(text: "Distributed Products"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryBackGround,
                foregroundColor: theme.activeTextIconColor,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              onPressed: () async {
                DateTimeRange? picked = await showDateRangePicker(
                  useRootNavigator: false,
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
                );

                if (picked != null) {
                  setState(() {
                    dateRange = picked;
                  });
                }
              },
              child: Text(
                dateRange == null
                    ? "Today"
                    : "${DateFormat.yMMMd().format(dateRange!.start)} - ${DateFormat.yMMMd().format(dateRange!.end)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.activeTextIconColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    String hint = "Search products...",
    Function(String)? onChanged,
    theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: TextField(
        readOnly: true,
        style: TextStyle(color: theme.activeTextIconColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: theme.inactiveTextIconColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.activeTextIconColor,
            size: 18,
          ),
          filled: true,
          fillColor: theme.primaryBackGround,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAllProducts() {
    final theme = ref.watch(themeServicesProvider);
    var filteredProducts =
        allProducts.where((product) {
          String productName = product["name"] as String;
          if (productName.toLowerCase().contains(productSearch)) return true;

          List<String> variants = List<String>.from(product["variants"]);
          if (variants.any(
            (variant) => variant.toLowerCase().contains(productSearch),
          )) {
            return true;
          }

          var branches = product["branches"] as Map<String, Map<String, int>>;
          bool branchMatchFound = branches.entries.any((branchEntry) {
            if (branchEntry.key.toLowerCase().contains(productSearch)) {
              return true;
            }

            return branchEntry.value.entries.any(
              (variantEntry) =>
                  variantEntry.key.toLowerCase().contains(productSearch) ||
                  variantEntry.value.toString().contains(productSearch),
            );
          });

          return branchMatchFound;
        }).toList();

    return Column(
      children: [
        _buildSearchField(
          hint: "Search products....",
          onChanged: (query) {
            setState(() {
              productSearch = query.toLowerCase();
            });
          },
          theme: theme,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              var product = filteredProducts[index];
              return Card(
                color: theme.primaryBackGround,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ExpansionTile(
                  leading: Icon(Icons.inventory, color: theme.activeBackGround),
                  title: Text(
                    product["name"],
                    style: TextStyle(color: theme.activeTextIconColor),
                  ),
                  children: [
                    ...product["branches"].entries.map((branchEntry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              branchEntry.key,
                              style: TextStyle(
                                color: theme.activeTextIconColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...branchEntry.value.entries.map((variantEntry) {
                            return ListTile(
                              title: Text(
                                "${variantEntry.key} (${variantEntry.value} units)",
                                style: TextStyle(
                                  color: theme.inactiveTextIconColor,
                                ),
                              ),
                              leading: Icon(
                                Icons.label,
                                color: theme.successColor,
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                    ListTile(
                      title: Text(
                        "Warehouse Stock:",
                        style: TextStyle(
                          color: theme.activeTextIconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...product["warehouse"].entries.map((variantEntry) {
                      return ListTile(
                        title: Text(
                          "${variantEntry.key}: ${variantEntry.value} units",
                          style: TextStyle(color: theme.inactiveTextIconColor),
                        ),
                        leading: Icon(
                          Icons.warehouse,
                          color: theme.deleteColor,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDistributedProducts() {
    final theme = ref.watch(themeServicesProvider);
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: branches.length,
      itemBuilder: (context, index) {
        var branch = branches[index];
        var filteredProducts =
            branch["products"].where((productentry) {
              String productName = productentry["name"].toLowerCase();
              bool productMatchesSearch = productName.contains(
                distributedSearch,
              );

              bool variantMatchesSearch = productentry["variants"].entries.any((
                variantEntry,
              ) {
                return variantEntry.key.toLowerCase().contains(
                      distributedSearch,
                    ) ||
                    variantEntry.value.toString().contains(distributedSearch);
              });

              return productMatchesSearch || variantMatchesSearch;
            }).toList();

        return Card(
          color: theme.primaryBackGround,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                leading: Icon(Icons.store, color: theme.activeBackGround),
                title: Text(
                  branch["name"],
                  style: TextStyle(color: theme.activeTextIconColor),
                ),
                children: [
                  _buildSearchField(
                    hint: "Search products in ${branch["name"]}...",
                    onChanged: (query) {
                      setState(() {
                        distributedSearch = query.toLowerCase();
                      });
                    },
                    theme: theme,
                  ),
                  // Only show filtered products
                  if (filteredProducts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "No products found",
                        style: TextStyle(color: theme.inactiveTextIconColor),
                      ),
                    ),
                  ...filteredProducts.map((productentry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            productentry["name"],
                            style: TextStyle(
                              color: theme.activeTextIconColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...productentry["variants"].entries.map((variantEntry) {
                          return ListTile(
                            title: Text(
                              "${variantEntry.key} (${variantEntry.value} units)",
                              style: TextStyle(
                                color: theme.inactiveTextIconColor,
                              ),
                            ),
                            leading: Icon(
                              Icons.label,
                              color: theme.successColor,
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
