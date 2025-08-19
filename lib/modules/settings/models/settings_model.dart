import 'package:snapservice/common.dart';

class SettingsConfig {
  final bool showDiscount;
  final bool payFirst;
  final bool screenLock;
  final Printer? printer;
  final BluetoothDevice? bluetoothPrinter;
  final bool loading;
  final bool showSummary;
  final bool showCashRegister;
  final bool createAttendant;
  final bool trackStock;

  SettingsConfig({
    required this.showDiscount,
    required this.payFirst,
    required this.loading,
    required this.showSummary,
    required this.showCashRegister,
    required this.createAttendant,
    required this.trackStock,
    this.printer,
    this.bluetoothPrinter,
    this.screenLock = false,
  });

  factory SettingsConfig.initial() {
    final db = LocalStorage.nosql;
    return SettingsConfig(
      showDiscount: db.showDiscount,
      payFirst: db.payFirst,
      screenLock: db.screenLock,
      showSummary: db.showSummary,
      showCashRegister: db.showCashRegister,
      loading: true,
      createAttendant: db.createAttendant,
      trackStock: db.trackStock,
    );
  }

  SettingsConfig copyWith({
    bool? showDiscount,
    bool? payFirst,
    bool? screenLock,
    Printer? printer,
    bool? showSummary,
    bool? showCashRegister,
    bool? loading,
    BluetoothDevice? bluetoothPrinter,
    bool? createAttendant,
    bool? trackStock,
  }) {
    return SettingsConfig(
      showDiscount: showDiscount ?? this.showDiscount,
      payFirst: payFirst ?? this.payFirst,
      printer: (bluetoothPrinter == null) ? (printer ?? this.printer) : null,
      screenLock: screenLock ?? this.screenLock,
      showSummary: showSummary ?? this.showSummary,
      showCashRegister: showCashRegister ?? this.showCashRegister,
      loading: loading ?? this.loading,
      bluetoothPrinter:
          (printer == null)
              ? (bluetoothPrinter ?? this.bluetoothPrinter)
              : null,
      createAttendant: createAttendant ?? this.createAttendant,
      trackStock: trackStock ?? this.trackStock,
    );
  }
}
