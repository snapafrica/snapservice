import 'package:intl/intl.dart';
import 'package:snapservice/common.dart';

class CashRegisterPage extends ConsumerStatefulWidget {
  const CashRegisterPage({super.key});

  @override
  ConsumerState<CashRegisterPage> createState() => _CashRegisterPageState();
}

class _CashRegisterPageState extends ConsumerState<CashRegisterPage> {
  String dateBtn = 'Today';
  String selectedBranch = 'All';
  String selectedType = 'all';
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final expenses = ref.watch(expenseServicesProvider);
    final user = ref.watch(authenticationServiceProvider).valueOrNull?.user;
    final branchesService = ref.watch(branchesServicesProvider);
    final expenseCategories = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: AppBar(
        title: const Text('Cash Register'),
        backgroundColor: theme.secondaryBackGround,
        foregroundColor: theme.textIconPrimaryColor,
        centerTitle: true,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.add, color: theme.textIconPrimaryColor),
            label: Text(
              'Add',
              style: TextStyle(color: theme.textIconPrimaryColor),
            ),
            onPressed: () {
              AddExpense.show(context).then((value) {
                if (value == '200') {
                  ref.invalidate(expenseServicesProvider);
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
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
                          final endStr = DateFormat.yMMMEd().format(value.end);
                          setState(() {
                            dateBtn = '$startStr   -   $endStr';
                          });
                          ref
                              .read(expenseServicesProvider.notifier)
                              .init(range: (value.start, value.end));
                        }
                      });
                    },
                    child: Text(dateBtn),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                bool isSmallScreen = constraints.maxWidth <= 600;
                if (isSmallScreen) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (user?.type == SUPERADMIN_TYPE_NAME)
                          branchesService.when(
                            loading: () => const CircularProgressIndicator(),
                            error:
                                (_, __) => Text(
                                  'Error loading branches',
                                  style: TextStyle(
                                    color: theme.textIconPrimaryColor,
                                  ),
                                ),
                            data: (branches) {
                              return _buildDropdown(
                                label: 'Select Shop',
                                value: selectedBranch,
                                items: [
                                  'All',
                                  ...branches.map((b) => b['name']),
                                ],
                                onChanged:
                                    (value) =>
                                        setState(() => selectedBranch = value!),
                                theme: theme,
                              );
                            },
                          ),
                        const SizedBox(width: 10),
                        expenseCategories.when(
                          loading: () => const CircularProgressIndicator(),
                          error:
                              (_, __) => Text(
                                'Error loading categories',
                                style: TextStyle(
                                  color: theme.textIconPrimaryColor,
                                ),
                              ),
                          data: (categories) {
                            return _buildDropdown(
                              label: 'Category',
                              value: selectedCategory,
                              items: [
                                'All',
                                ...categories.map((c) => c['expense']),
                              ],
                              onChanged:
                                  (value) =>
                                      setState(() => selectedCategory = value!),
                              theme: theme,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (user?.type == SUPERADMIN_TYPE_NAME)
                        Expanded(
                          child: branchesService.when(
                            loading:
                                () => const Center(
                                  child: LinearProgressIndicator(),
                                ),
                            error:
                                (_, __) => Text(
                                  'Error loading branches',
                                  style: TextStyle(
                                    color: theme.textIconPrimaryColor,
                                  ),
                                ),
                            data: (branches) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: _buildDropdown(
                                  label: 'Select Shop',
                                  value: selectedBranch,
                                  items: [
                                    'All',
                                    ...branches.map((b) => b['name']),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBranch = value!;
                                    });
                                  },
                                  theme: theme,
                                ),
                              );
                            },
                          ),
                        ),
                      Expanded(
                        child: expenseCategories.when(
                          loading:
                              () => const Center(
                                child: LinearProgressIndicator(),
                              ),
                          error:
                              (_, __) => Text(
                                'Error loading categories',
                                style: TextStyle(
                                  color: theme.textIconPrimaryColor,
                                ),
                              ),
                          data: (categories) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: _buildDropdown(
                                label: 'Category',
                                value: selectedCategory,
                                items: [
                                  'All',
                                  ...categories.map((c) => c['expense']),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value!;
                                  });
                                },
                                theme: theme,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: Text(
                    'All',
                    style: TextStyle(
                      color:
                          selectedType == 'all'
                              ? theme.activeTextIconColor
                              : theme.defultColor,
                    ),
                  ),
                  checkmarkColor: theme.activeTextIconColor,
                  disabledColor: theme.defultColor,
                  selected: selectedType == 'all',
                  selectedColor: theme.primaryBackGround,
                  onSelected:
                      (selected) => setState(() => selectedType = 'all'),
                ),
                ChoiceChip(
                  label: Text(
                    'Debit',
                    style: TextStyle(
                      color:
                          selectedType == 'debit'
                              ? theme.activeTextIconColor
                              : theme.defultColor,
                    ),
                  ),
                  checkmarkColor: theme.activeTextIconColor,
                  disabledColor: theme.defultColor,
                  selected: selectedType == 'debit',
                  selectedColor: theme.deleteColor,
                  onSelected:
                      (selected) => setState(() => selectedType = 'debit'),
                ),
                ChoiceChip(
                  label: Text(
                    'Credit',
                    style: TextStyle(
                      color:
                          selectedType == 'credit'
                              ? theme.activeTextIconColor
                              : theme.defultColor,
                    ),
                  ),
                  checkmarkColor: theme.activeTextIconColor,
                  disabledColor: theme.defultColor,
                  selected: selectedType == 'credit',
                  selectedColor: theme.successColor,
                  onSelected:
                      (selected) => setState(() => selectedType = 'credit'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(expenseServicesProvider);
                },
                child: expenses.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (_, __) => Center(
                        child: Text(
                          'Error loading expenses',
                          style: TextStyle(color: theme.activeTextIconColor),
                        ),
                      ),
                  data: (expenseData) {
                    final filteredExpenses =
                        expenseData['data']
                            .where(
                              (expense) =>
                                  (selectedBranch == 'All' ||
                                      expense['shop'] == selectedBranch) &&
                                  (selectedType == 'all' ||
                                      expense['type'] == selectedType) &&
                                  (selectedCategory == 'All' ||
                                      expense['category'] == selectedCategory),
                            )
                            .toList();

                    return filteredExpenses.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.money_off,
                                size: 60,
                                color: theme.textIconPrimaryColor,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No expenses available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: theme.textIconSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: filteredExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = filteredExpenses[index];
                            final isDebit = expense['type'] == 'debit';

                            return InkWell(
                              onTap: () {
                                AddExpense.show(context, expense: expense).then(
                                  (value) {
                                    if (value == '200') {
                                      ref.invalidate(expenseServicesProvider);
                                    }
                                  },
                                );
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              child: Card(
                                color: theme.primaryBackGround,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    bool isSmallScreen =
                                        constraints.maxWidth <= 600;

                                    return Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            expense['category'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: theme.activeTextIconColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Date: ${expense['date_added']}',
                                                      style: TextStyle(
                                                        color:
                                                            theme
                                                                .activeTextIconColor,
                                                      ),
                                                    ),
                                                    if (user?.type ==
                                                        SUPERADMIN_TYPE_NAME)
                                                      Text(
                                                        'Shop: ${expense['shop']}',
                                                        style: TextStyle(
                                                          color:
                                                              theme
                                                                  .inactiveTextIconColor,
                                                        ),
                                                      ),
                                                    Text(
                                                      'Source: ${expense['source']}',
                                                      style: TextStyle(
                                                        color:
                                                            theme
                                                                .inactiveTextIconColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (!isSmallScreen)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'Amount: ${expense['amount']}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            isDebit
                                                                ? theme
                                                                    .deleteColor
                                                                : theme
                                                                    .successColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Shop Balance: ${expense['shop_balance']}',
                                                      style: TextStyle(
                                                        color:
                                                            theme
                                                                .activeTextIconColor,
                                                      ),
                                                    ),
                                                    if (user?.type ==
                                                        SUPERADMIN_TYPE_NAME)
                                                      Text(
                                                        'Company Balance: ${expense['company_balance']}',
                                                        style: TextStyle(
                                                          color:
                                                              theme
                                                                  .activeTextIconColor,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          if (isSmallScreen)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Divider(
                                                  color:
                                                      theme.inactiveBackGround,
                                                ),
                                                Text(
                                                  'Amount: ${expense['amount']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        isDebit
                                                            ? theme.deleteColor
                                                            : theme
                                                                .successColor,
                                                  ),
                                                ),
                                                Text(
                                                  'Shop Balance: ${expense['shop_balance']}',
                                                  style: TextStyle(
                                                    color:
                                                        theme
                                                            .activeTextIconColor,
                                                  ),
                                                ),
                                                if (user?.type ==
                                                    SUPERADMIN_TYPE_NAME)
                                                  Text(
                                                    'Company Balance: ${expense['company_balance']}',
                                                    style: TextStyle(
                                                      color:
                                                          theme
                                                              .activeTextIconColor,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                        ],
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
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeConfig theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.textIconPrimaryColor,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButton<String>(
          value: value,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(color: theme.textIconPrimaryColor),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          dropdownColor: theme.secondaryBackGround,
        ),
      ],
    );
  }
}

class AddExpense extends ConsumerStatefulWidget {
  const AddExpense({super.key, this.expense});
  final Map<dynamic, dynamic>? expense;

  static Future<String?> show(
    BuildContext context, {
    Map<dynamic, dynamic>? expense,
  }) {
    return showDialog<String>(
      context: context,
      useRootNavigator: SrceenType.type(context.sz).isMobile,
      builder: (_) {
        return AddExpense(expense: expense);
      },
    );
  }

  @override
  ConsumerState<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends ConsumerState<AddExpense> {
  bool isUpdating = false;
  final GlobalKey<FormState> _form = GlobalKey();

  late final TextEditingController _cReason = TextEditingController(
    text: widget.expense == null ? '' : widget.expense!['reason'],
  );
  late final TextEditingController _cAmount = TextEditingController(
    text: widget.expense == null ? '' : widget.expense!['amount'],
  );
  late final TextEditingController _cShopName = TextEditingController();

  final List<Map<String, String>> eTypes = [
    {'value': 'debit', 'name': 'Reduce Cash'},
    {'value': 'credit', 'name': 'Add Cash'},
  ];

  late String? selectedType =
      widget.expense == null
          ? eTypes.first['value']
          : widget.expense!['type'] as String?;
  late String? selectedCategory =
      widget.expense == null ? null : widget.expense!['category'] as String?;
  String? shopId;

  @override
  Widget build(BuildContext context) {
    final dWidth = context.sz.width;
    final width = dWidth > 400.0 ? 400.0 : dWidth;
    final theme = ref.watch(themeServicesProvider);
    final expenseCategories = ref.watch(expenseCategoriesProvider);
    final branchesService = ref.watch(branchesServicesProvider);
    final user = ref.watch(authenticationServiceProvider).valueOrNull?.user;
    return Center(
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (user?.type == SUPERADMIN_TYPE_NAME) ...[
                            branchesService.when(
                              loading:
                                  () => const Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Select shop',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      LinearProgressIndicator(),
                                    ],
                                  ),
                              error:
                                  (error, stackTrace) => Text(
                                    'Unable to load shops',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.deleteColor,
                                    ),
                                  ),
                              data: (data) {
                                return TextFormField(
                                  controller: _cShopName,
                                  readOnly: true,
                                  validator:
                                      (value) =>
                                          (value?.isEmpty ?? true) ? '' : null,
                                  onTap: () {
                                    SelectShop.show(context, data).then((
                                      value,
                                    ) {
                                      if (value != null) {
                                        shopId = value['id'].toString();
                                        _cShopName.text = value['name'];
                                      }
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Select shop',
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                          const Text(
                            'Expense type',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          DropdownButtonFormField(
                            value: selectedType,
                            validator:
                                (value) => (value?.isEmpty ?? true) ? '' : null,
                            items:
                                eTypes
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e['value'],
                                        child: Text(e['name'] as String),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Category',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          expenseCategories.when(
                            loading: () => const LinearProgressIndicator(),
                            error:
                                (error, stackTrace) => const SizedBox.shrink(),
                            data: (data) {
                              return DropdownButtonFormField<String>(
                                value: selectedCategory,
                                validator:
                                    (value) =>
                                        (value?.isEmpty ?? true) ? '' : null,
                                items:
                                    data
                                        .map(
                                          (e) => DropdownMenuItem<String>(
                                            value: e['expense'],
                                            child: Text(e['expense'] as String),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                              );
                            },
                          ),
                          TextFormField(
                            controller: _cReason,
                            validator:
                                (value) => (value?.isEmpty ?? true) ? '' : null,
                            minLines: 1,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              labelText: 'Reason',
                            ),
                          ),
                          TextFormField(
                            controller: _cAmount,
                            readOnly: widget.expense != null,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator:
                                (value) => (value?.isEmpty ?? true) ? '' : null,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: .5,
                    thickness: .5,
                    color: theme.inactiveBackGround,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Consumer(
                      builder: (context, ref, _) {
                        return TextButton(
                          onPressed:
                              isUpdating
                                  ? null
                                  : () {
                                    if (_form.currentState!.validate()) {
                                      setState(() {
                                        isUpdating = true;
                                      });
                                      _update(ref);
                                    }
                                  },
                          style: TextButton.styleFrom(
                            backgroundColor: theme.primaryBackGround,
                            foregroundColor: theme.activeTextIconColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            fixedSize: const Size(double.maxFinite, 20),
                          ),
                          child:
                              isUpdating
                                  ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: theme.activeTextIconColor,
                                    ),
                                  )
                                  : Text(
                                    widget.expense == null ? 'ADD' : 'UPDATE',
                                  ),
                        );
                      },
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

  void _update(WidgetRef ref) async {
    final user = ref.read(authenticationServiceProvider).value?.user;
    final details = (
      reason: _cReason.text,
      type: selectedType as String,
      amount: _cAmount.text,
      category: selectedCategory as String,
      prevAmount: widget.expense?['amount'].toString() ?? '',
      id: widget.expense?['id'].toString() ?? '',
      store:
          user?.type == SUPERADMIN_TYPE_NAME
              ? (shopId ?? '')
              : (user?.storeId ?? ''),
    );
    try {
      await ref
          .read(expenseServicesProvider.notifier)
          .add(details: details, isUpdate: widget.expense != null);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop('200');
    } catch (e) {
      print(e);
      setState(() {
        isUpdating = false;
      });
    }
  }
}
