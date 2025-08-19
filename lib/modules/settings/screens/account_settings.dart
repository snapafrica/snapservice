import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:snapservice/common.dart';

// SettingsDetailPage
class SettingsDetailPage extends ConsumerWidget {
  const SettingsDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServicesProvider);
    final settingsService = ref.watch(settingsServicesProvider);
    final userService = ref.watch(authenticationServiceProvider);
    final user = userService.valueOrNull?.user;

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackGround,
        foregroundColor: theme.textIconPrimaryColor,
        centerTitle: true,
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, cs) {
                final maxWidth = cs.maxWidth;
                return SizedBox(
                  width: maxWidth,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(settingsServicesProvider);
                    },
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: [
                        if (settingsService.loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: LinearProgressIndicator(),
                          ),
                        _buildSettingCard(
                          theme: theme,
                          title: 'Account privacy',
                          subtitle:
                              '${settingsService.screenLock ? 'Disable' : 'Enable'} password every time you open the app',
                          trailing: CupertinoSwitch(
                            value: settingsService.screenLock,
                            onChanged: (value) {
                              ref
                                  .read(settingsServicesProvider.notifier)
                                  .changeScreenLock();
                            },
                          ),
                        ),
                        if (user?.type == SUPERADMIN_TYPE_NAME)
                          if (user?.type == SUPERADMIN_TYPE_NAME)
                            _buildSettingCard(
                              theme: theme,
                              title: 'Discounts',
                              subtitle:
                                  '${settingsService.showDiscount ? 'Disable' : 'Enable'} discounts when creating an order',
                              trailing: CupertinoSwitch(
                                value: settingsService.showDiscount,
                                onChanged: (value) {
                                  ref
                                      .read(settingsServicesProvider.notifier)
                                      .changeShowDiscount();
                                },
                              ),
                            ),
                        if (user?.type == SUPERADMIN_TYPE_NAME)
                          if (user?.type == SUPERADMIN_TYPE_NAME)
                            _buildSettingCard(
                              theme: theme,
                              title: 'Pay first',
                              subtitle:
                                  '${settingsService.showDiscount ? 'Disable' : 'Enable'} a pay first option when creating an order',
                              trailing: CupertinoSwitch(
                                value: settingsService.payFirst,
                                onChanged: (value) {
                                  ref
                                      .read(settingsServicesProvider.notifier)
                                      .changePayFirst();
                                },
                              ),
                            ),
                        if (user?.type == SUPERADMIN_TYPE_NAME)
                          if (user?.type == SUPERADMIN_TYPE_NAME)
                            _buildSettingCard(
                              theme: theme,
                              title: 'Store Summary',
                              subtitle:
                                  '${settingsService.showSummary ? 'Disable' : 'Enable'} the Front-Office to view the store summary',
                              trailing: CupertinoSwitch(
                                value: settingsService.showSummary,
                                onChanged: (value) {
                                  ref
                                      .read(settingsServicesProvider.notifier)
                                      .changeshowSummary();
                                },
                              ),
                            ),
                        if (user?.type == SUPERADMIN_TYPE_NAME)
                          if (user?.type == SUPERADMIN_TYPE_NAME)
                            _buildSettingCard(
                              theme: theme,
                              title: 'Cash Register',
                              subtitle:
                                  '${settingsService.showCashRegister ? 'Disable' : 'Enable'} the Front-Office to view the cash register',
                              trailing: CupertinoSwitch(
                                value: settingsService.showCashRegister,
                                onChanged: (value) {
                                  ref
                                      .read(settingsServicesProvider.notifier)
                                      .changecashRegister();
                                },
                              ),
                            ),
                        if (user?.type == SUPERADMIN_TYPE_NAME)
                          if (user?.type == SUPERADMIN_TYPE_NAME)
                            _buildSettingCard(
                              theme: theme,
                              title: 'Create Agent',
                              subtitle:
                                  '${settingsService.createAttendant ? 'Disable' : 'Enable'} the Front-Office from creating an agent',
                              trailing: CupertinoSwitch(
                                value: settingsService.createAttendant,
                                onChanged: (value) {
                                  ref
                                      .read(settingsServicesProvider.notifier)
                                      .changeCreateAttendant();
                                },
                              ),
                            ),
                        if (user?.type == SUPERADMIN_TYPE_NAME)
                          if (user?.type == SUPERADMIN_TYPE_NAME)
                            _buildSettingCard(
                              theme: theme,
                              title: 'Stock Tracking',
                              subtitle:
                                  '${settingsService.trackStock ? 'Disable' : 'Enable'} stock tracking when creating an order',
                              trailing: CupertinoSwitch(
                                value: settingsService.trackStock,
                                onChanged: (value) {
                                  ref
                                      .read(settingsServicesProvider.notifier)
                                      .changeTrackStock();
                                },
                              ),
                            ),
                        _buildSettingCard(
                          theme: theme,
                          title: 'Printer',
                          subtitle:
                              (settingsService.printer == null &&
                                      settingsService.bluetoothPrinter == null)
                                  ? 'No printer selected'
                                  : 'Selected : ${settingsService.printer?.name ?? settingsService.bluetoothPrinter!.name}',

                          trailing: Icon(
                            Icons.print_outlined,
                            color: theme.activeTextIconColor,
                          ),
                          onTap: () {
                            showAvailablePrinters(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget trailing,
    required ThemeConfig theme,
    void Function()? onTap,
  }) {
    return Card(
      color: theme.primaryBackGround,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.activeTextIconColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: theme.inactiveTextIconColor),
        ),
        trailing: trailing,
      ),
    );
  }
}

void showAvailablePrinters(BuildContext context) {
  final dWidth = context.sz.width;
  final width = dWidth > 400.0 ? 400.0 : dWidth;
  showCupertinoModalPopup(
    context: context,
    useRootNavigator: SrceenType.type(context.sz).isMobile,
    builder: (_) {
      return Center(
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Consumer(
                builder: (context, ref, _) {
                  final printerServ = ref.watch(settingsServicesProvider);
                  final activePrinter = printerServ.printer;
                  final bluetoothPrinter = printerServ.bluetoothPrinter;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Printers Found',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Divider(
                        height: .5,
                        thickness: .5,
                        color: Colors.grey,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 16, top: 8),
                                child: Text(
                                  'Connected',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              FutureBuilder(
                                future: Printing.listPrinters(),
                                builder: (context, snap) {
                                  if (snap.hasError) {
                                    return const Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 24,
                                        left: 16,
                                        top: 4,
                                      ),
                                      child: Text('Unable to load printers'),
                                    );
                                  }
                                  if (snap.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (snap.hasData) {
                                    final data = snap.data ?? [];
                                    if (data.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 24,
                                          left: 24,
                                          top: 4,
                                        ),
                                        child: Text('No printers found'),
                                      );
                                    }
                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      shrinkWrap: true,
                                      itemCount: data.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final pinter = data[index];
                                        final bool active =
                                            pinter.model ==
                                            (activePrinter?.model ?? 'x');
                                        return ListTile(
                                          onTap:
                                              active
                                                  ? () async {
                                                    ref
                                                        .read(
                                                          settingsServicesProvider
                                                              .notifier,
                                                        )
                                                        .print();
                                                  }
                                                  : null,
                                          title: Text(pinter.name),
                                          subtitle:
                                              active
                                                  ? const Text(
                                                    'Tap to test print',
                                                  )
                                                  : null,
                                          trailing:
                                              active
                                                  ? const Icon(Icons.check)
                                                  : TextButton(
                                                    onPressed: () async {
                                                      ref
                                                          .read(
                                                            settingsServicesProvider
                                                                .notifier,
                                                          )
                                                          .selectPrinter(
                                                            pinter,
                                                          );
                                                    },
                                                    child: const Text('select'),
                                                  ),
                                        );
                                      },
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (Platform.isAndroid)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, top: 16),
                            child: Text(
                              'Bluetooth',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      if (Platform.isAndroid)
                        StreamBuilder(
                          stream: FlutterBluetoothPrinter.discovery,
                          builder: (context, snapshot) {
                            final data = snapshot.data;
                            if (data != null) {
                              if (data is PermissionRestrictedState) {
                                return const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 24,
                                      left: 24,
                                      top: 4,
                                    ),
                                    child: Text('Permission restricted'),
                                  ),
                                );
                              }
                              if (data is DiscoveryResult) {
                                final res = data;
                                final devices = res.devices;
                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: devices.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final pinter = devices[index];
                                    final bool active =
                                        pinter.address ==
                                        (bluetoothPrinter?.address ?? 'xx');
                                    return ListTile(
                                      title: Text(pinter.name ?? 'Unknown'),
                                      subtitle:
                                          active
                                              ? const Text('Tap to test print')
                                              : null,
                                      onTap:
                                          active
                                              ? () async {
                                                ref
                                                    .read(
                                                      settingsServicesProvider
                                                          .notifier,
                                                    )
                                                    .print();
                                              }
                                              : null,
                                      trailing:
                                          active
                                              ? const Icon(Icons.check)
                                              : TextButton(
                                                onPressed: () async {
                                                  ref
                                                      .read(
                                                        settingsServicesProvider
                                                            .notifier,
                                                      )
                                                      .selectBluetoothPrinter(
                                                        pinter,
                                                      );
                                                },
                                                child: const Text('select'),
                                              ),
                                    );
                                  },
                                );
                              }
                              // PermissionRestrictedState
                            }
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: 24,
                                  left: 24,
                                  top: 4,
                                  right: 24,
                                ),
                                child: Text(
                                  'No printers found, check if bluetooth is on',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}
