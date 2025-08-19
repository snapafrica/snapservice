import 'package:intl/intl.dart';
import 'package:snapservice/common.dart';

class PickMpesaCode extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onPick;
  final ScrollController? scrollController;

  const PickMpesaCode({super.key, required this.onPick, this.scrollController});

  static Future<Map<String, dynamic>?> show(BuildContext context) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        maxChildSize: 0.98,
        minChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: PickMpesaCode(
              onPick: (code) => Navigator.pop(context, code),
              scrollController: scrollController,
            ),
          );
        },
      ),
    );
  }

  @override
  ConsumerState<PickMpesaCode> createState() => _PickMpesaCodeState();
}

class _PickMpesaCodeState extends ConsumerState<PickMpesaCode> {
  String dateBtn = 'Today';
  (DateTime, DateTime)? range;
  String search = '';

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final codesState = ref.watch(mpesaCodesServicesProvider);

    List<Map<String, dynamic>> data = (codesState.value ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    if (search.isNotEmpty) {
      data = data.where((code) {
        return code['transcode'].toString().toLowerCase().contains(
              search.toLowerCase(),
            ) ||
            code['username'].toString().toLowerCase().contains(
              search.toLowerCase(),
            ) ||
            code['phone'].toString().toLowerCase().contains(
              search.toLowerCase(),
            );
      }).toList();
    }

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.datePickerColor,
                        foregroundColor: theme.activeTextIconColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _selectDateRange,
                      child: Text(dateBtn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.textIconPrimaryColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                autofocus: true,
                readOnly: true,
                onChanged: (val) => setState(() => search = val),
                style: TextStyle(color: theme.activeTextIconColor),
                decoration: InputDecoration(
                  hintText: 'Search code...',
                  hintStyle: TextStyle(color: theme.activeTextIconColor),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.activeTextIconColor,
                  ),
                  filled: true,
                  fillColor: theme.primaryBackGround,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: codesState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Failed to load data',
                    style: TextStyle(color: theme.textIconPrimaryColor),
                  ),
                ),
                data: (_) => data.isEmpty
                    ? Center(
                        child: Text(
                          'No Mpesa Codes Found',
                          style: TextStyle(color: theme.textIconPrimaryColor),
                        ),
                      )
                    : ListView.builder(
                        controller: widget.scrollController,
                        itemCount: data.length,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        itemBuilder: (_, index) =>
                            _buildCodeCard(context, data[index], theme),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeCard(
    BuildContext context,
    Map<String, dynamic> code,
    dynamic theme,
  ) {
    final used = code['used'] == true;

    return GestureDetector(
      onTap: () => widget.onPick(code),
      child: Card(
        color: theme.primaryBackGround,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat(
                  'MMM d, y  •  hh:mm a',
                ).format(DateTime.parse(code['date'])),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.activeTextIconColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customer: ${code['username']}',
                style: TextStyle(color: theme.inactiveTextIconColor),
              ),
              Text(
                'Phone: ${code['phone']}',
                style: TextStyle(color: theme.inactiveTextIconColor),
              ),
              Text(
                'Amount: ${(num.tryParse(code['amount'].toString()) ?? 0).toDouble().money}',
                style: TextStyle(color: theme.inactiveTextIconColor),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Code: ${code['transcode']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: used ? theme.deleteColor : theme.successColor,
                        decoration: used ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (!used)
                    IconButton(
                      icon: Icon(Icons.copy, color: theme.inactiveBackGround),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: code['transcode']),
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
            ],
          ),
        ),
      ),
    );
  }

  void _selectDateRange() async {
    final theme = ref.watch(themeServicesProvider);
    final picked = await showDateRangePicker(
      useRootNavigator: SrceenType.type(context.sz).isMobile,
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = theme.secondaryBackGround == const Color(0xff17181f);
        final base = isDark ? ThemeData.dark() : ThemeData.light();
        return Theme(
          data: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: theme.datePickerPrimaryColor,
              onPrimary: theme.activeTextIconColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateBtn =
            '${DateFormat('yMMMd').format(picked.start)} - ${DateFormat('yMMMd').format(picked.end)}';
        range = (picked.start, picked.end);
      });
      ref.read(mpesaCodesServicesProvider.notifier).init(range: range);
    }
  }
}
