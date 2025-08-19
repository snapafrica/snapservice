import 'package:snapservice/common.dart';

class CompleteOrderPage extends ConsumerStatefulWidget {
  const CompleteOrderPage({super.key, required this.orderId});
  final num orderId;

  @override
  ConsumerState<CompleteOrderPage> createState() => _CompleteOrderPageState();
}

class _CompleteOrderPageState extends ConsumerState<CompleteOrderPage> {
  bool loading = false;
  final TextEditingController _cCash = TextEditingController();
  final TextEditingController _cMpesaRef = TextEditingController();
  final TextEditingController _cMpesaRef2 = TextEditingController();
  final TextEditingController _cMpesaRef3 = TextEditingController();
  final TextEditingController _cBankRefNum = TextEditingController();
  late final TextEditingController _cStkNumPush = TextEditingController(
    text: () {
      String? text = ref
          .read(orderServicesProvider)
          .orders
          .where((element) => element['id'] == widget.orderId)
          .firstOrNull?['customer'];
      return text?.replaceFirst('+254', '0');
    }(),
  );

  var paymentMethods = [
    {'name': 'Cash', 'state': false, 'enabled': true},
    {'name': 'Mpesa', 'state': false, 'enabled': true},
    {'name': 'Bank', 'state': false, 'enabled': true},
    {'name': 'STK Push', 'state': false, 'enabled': true},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final allorders = ref.watch(orderServicesProvider);
    final order = allorders.orders
        .where((element) => element['id'] == widget.orderId)
        .firstOrNull;

    if (order != null) {
      final orderAmt = (order['amount'] as num).toDouble();
      final amtPaid = (order['amount_paid'] as num).toDouble();

      return Scaffold(
        backgroundColor: theme.secondaryBackGround,
        appBar: AppBar(
          title: Text('Complete Order - ${order['billno']}'),
          centerTitle: true,
          backgroundColor: theme.secondaryBackGround,
          foregroundColor: theme.textIconPrimaryColor,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.textIconPrimaryColor,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final selected = await PickMpesaCode.show(context);
                if (selected != null) {
                  context.loading;
                  context.showToast(
                    'Code selected: ${selected['transcode']}',
                    textColor: theme.textIconPrimaryColor,
                  );
                }
              },
              child: const Text('Use M-Pesa Code'),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        color: theme.primaryBackGround,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      color: theme.inactiveTextIconColor,
                                    ),
                                  ),
                                  Text(
                                    orderAmt.money,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: theme.activeTextIconColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (amtPaid > 0)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Paid',
                                      style: TextStyle(
                                        color: theme.inactiveTextIconColor,
                                      ),
                                    ),
                                    Text(
                                      amtPaid.money,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                        color: theme.activeTextIconColor,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: theme.primaryBackGround,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: theme.activeTextIconColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              paymentWidgets(theme),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (showPayments)
                        Card(
                          color: theme.primaryBackGround,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (paymentMethods[0]['state'] as bool) ...[
                                  cashPayment(theme),
                                  const SizedBox(height: 8),
                                ],
                                if (paymentMethods[2]['state'] as bool) ...[
                                  bankPayment(theme),
                                  const SizedBox(height: 8),
                                ],
                                if (paymentMethods[1]['state'] as bool) ...[
                                  ...mpesaRefWidgets(theme),
                                  const SizedBox(height: 8),
                                ],
                                if (paymentMethods[3]['state'] as bool) ...[
                                  TextFormField(
                                    controller: _cStkNumPush,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: phoneValidation,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      labelText: 'Phone number',
                                      labelStyle: TextStyle(
                                        color: theme.inactiveTextIconColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: theme.inactiveTextIconColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: theme.successColor,
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: theme.inactiveTextIconColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextButton(
                          onPressed: (!loading)
                              ? () {
                                  if (completeIt) {
                                    setState(() {
                                      loading = true;
                                    });
                                    completeOrder(order)
                                        .then((value) {
                                          context.pop();
                                          context.showToast(
                                            'Order completed',
                                            textColor:
                                                theme.textIconPrimaryColor,
                                          );
                                          ref.invalidate(orderServicesProvider);
                                        })
                                        .onError((error, stackTrace) {
                                          context.showToast(
                                            'Unable to complete order',
                                            error: true,
                                            textColor:
                                                theme.textIconPrimaryColor,
                                          );
                                          setState(() {
                                            loading = false;
                                          });
                                        });
                                  }
                                }
                              : null,
                          style: TextButton.styleFrom(
                            backgroundColor: theme.primaryBackGround,
                            foregroundColor: theme.activeTextIconColor,
                            fixedSize: const Size(double.maxFinite, 50),
                          ),
                          child: loading
                              ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: theme.activeTextIconColor,
                                  ),
                                )
                              : Text(
                                  'COMPLETE',
                                  style: TextStyle(
                                    color: theme.activeTextIconColor,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [Expanded(child: emptyState(ref, text: 'Order not found'))],
    );
  }

  get showPayments {
    final hasPush = (paymentMethods[3]['state'] as bool);
    final hasbank = (paymentMethods[2]['state'] as bool);
    final hasMpesa = (paymentMethods[1]['state'] as bool);
    final hasCash = (paymentMethods[0]['state'] as bool);
    return hasPush || hasbank || hasMpesa || hasCash;
  }

  TextField cashPayment(theme) {
    return TextField(
      readOnly: true,
      controller: _cCash,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: theme.activeTextIconColor),
      decoration: InputDecoration(
        labelText: 'Cash Amount',
        labelStyle: TextStyle(color: theme.inactiveTextIconColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.inactiveTextIconColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  TextField bankPayment(theme) {
    return TextField(
      autofocus: true,
      readOnly: true,
      controller: _cBankRefNum,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      style: TextStyle(color: theme.activeTextIconColor),
      decoration: InputDecoration(
        labelText: 'Bank Reference Number',
        labelStyle: TextStyle(color: theme.inactiveTextIconColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.inactiveTextIconColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  Future<void> completeOrder(Map<dynamic, dynamic> order) async {
    final cash = paymentMethods[0]['state'] as bool;
    final mpesa = paymentMethods[1]['state'] as bool;
    final bank = paymentMethods[2]['state'] as bool;
    final stkpush = paymentMethods[3]['state'] as bool;

    if (cash && !mpesa && !bank) {
      return ref
          .read(orderServicesProvider.notifier)
          .completeOrder(
            order: order,
            orderType: 'Cash',
            type: 'cash',
            url: 'request.php',
          );
    } else if (bank || (cash && !mpesa)) {
      return ref
          .read(orderServicesProvider.notifier)
          .completeOrder(
            order: order,
            orderType: 'Equity',
            type: 'equity',
            reference: _cBankRefNum.text.trim(),
            url: 'request.php',
            cashAdd: double.tryParse(_cCash.text),
          );
    } else if (mpesa && !cash && !bank) {
      return ref
          .read(orderServicesProvider.notifier)
          .completeOrder(
            order: order,
            orderType: 'code',
            code: [
              if (_cMpesaRef.text.trim().isNotEmpty) _cMpesaRef.text,
              if (_cMpesaRef2.text.trim().isNotEmpty) _cMpesaRef2.text,
              if (_cMpesaRef3.text.trim().isNotEmpty) _cMpesaRef3.text,
            ],
            url: 'request.php',
          );
    } else if (cash && mpesa && !bank) {
      final cashAmt = double.tryParse(_cCash.text);
      return ref
          .read(orderServicesProvider.notifier)
          .completeOrder(
            order: order,
            orderType: 'code',
            reference: _cMpesaRef.text.trim(),
            code: [
              if (_cMpesaRef.text.trim().isNotEmpty) _cMpesaRef.text,
              if (_cMpesaRef2.text.trim().isNotEmpty) _cMpesaRef2.text,
              if (_cMpesaRef3.text.trim().isNotEmpty) _cMpesaRef3.text,
            ],
            url: 'request.php',
            cashAdd: cashAmt,
          );
    } else if (stkpush) {
      return ref
          .read(orderServicesProvider.notifier)
          .completeOrder(
            order: order,
            orderType: 'stkpush',
            phonestk: _cStkNumPush.text.trim(),
            url: 'request.php',
          );
    }
  }

  bool get completeIt {
    final cash = paymentMethods[0]['state'] as bool;
    final mpesa = paymentMethods[1]['state'] as bool;
    final bank = paymentMethods[2]['state'] as bool;
    final stkpush = paymentMethods[3]['state'] as bool;
    final haspayment = cash || mpesa || bank || stkpush;
    bool mpesaok = true;
    bool cashok = true;
    bool bankok = true;
    bool stkok = true;

    if (mpesa) {
      mpesaok = _cMpesaRef.text.isNotEmpty;
    }
    if (mpesa && cash) {
      cashok = _cCash.text.isNotEmpty;
    }
    if (bank) {
      bankok = _cBankRefNum.text.isNotEmpty && _cBankRefNum.text.length > 4;
    }
    if (stkpush) {
      stkok = _cStkNumPush.text.isNotEmpty && _cStkNumPush.text.length == 10;
    }

    final validated = mpesaok && cashok && bankok && stkok && haspayment;
    return validated;
  }

  List<Widget> mpesaRefWidgets(theme) {
    return [
      TextFormField(
        controller: _cMpesaRef,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(color: theme.activeTextIconColor),
        decoration: InputDecoration(
          labelText: 'Mpesa Reference',
          labelStyle: TextStyle(color: theme.inactiveTextIconColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.inactiveTextIconColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _cMpesaRef2,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(color: theme.activeTextIconColor),
        decoration: InputDecoration(
          labelText: 'Mpesa Reference 2',
          labelStyle: TextStyle(color: theme.inactiveTextIconColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.inactiveTextIconColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _cMpesaRef3,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(color: theme.activeTextIconColor),
        decoration: InputDecoration(
          labelText: 'Mpesa Reference 3',
          labelStyle: TextStyle(color: theme.inactiveTextIconColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.inactiveTextIconColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
        ),
      ),
    ];
  }

  Widget paymentWidgets(theme) {
    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: theme.checkboxBorderColor, width: 2),
          ),
          side: BorderSide(color: theme.checkboxBorderColor, width: 2),
        ),
      ),
      child: Column(
        children: paymentMethods
            .map<Widget>(
              (method) => CheckboxListTile(
                title: Text(
                  method['name'] as String,
                  style: TextStyle(color: theme.inactiveTextIconColor),
                ),
                value: method['state'] as bool,
                onChanged: (val) {
                  setState(() {
                    method['state'] = val!;
                  });
                },
                activeColor: theme.successColor,
                checkColor: theme.activeTextIconColor,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            )
            .toList(),
      ),
    );
  }
}
