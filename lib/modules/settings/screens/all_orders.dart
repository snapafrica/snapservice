import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;
import 'package:snapservice/common.dart';

class AllOrdersPage extends ConsumerStatefulWidget {
  const AllOrdersPage({super.key});

  @override
  ConsumerState<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends ConsumerState<AllOrdersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final ordersState = ref.watch(orderServicesProvider);
    final isLoading = ordersState is OrdersLoading;
    final hasError = ordersState is OrdersError;

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackGround,
        foregroundColor: theme.textIconPrimaryColor,
        centerTitle: true,
        title: const Text('Orders By Branch'),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: theme.textIconPrimaryColor,
                ),
              )
              : hasError
              ? Center(
                child: Text(
                  'Failed to load orders',
                  style: TextStyle(color: theme.textIconPrimaryColor),
                ),
              )
              : _buildOrdersContent(ordersState, theme),
    );
  }

  Widget _buildOrdersContent(dynamic ordersState, theme) {
    final orders = ordersState.orders.cast<Map<String, dynamic>>();
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No orders available',
          style: TextStyle(color: theme.textIconPrimaryColor),
        ),
      );
    }

    Map<String, List<Map<String, dynamic>>> ordersByBranch = {};
    for (var order in orders) {
      final branch = order['store'] as String? ?? 'Unknown Branch';
      ordersByBranch[branch] = [...(ordersByBranch[branch] ?? []), order];
    }

    List<Map<String, dynamic>> allOrders =
        ordersByBranch.values.expand((x) => x).toList();

    final branches = ordersByBranch.keys.toList();
    _tabController = TabController(length: branches.length + 1, vsync: this);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicator: BoxDecoration(),
            labelColor: theme.textIconPrimaryColor,
            unselectedLabelColor: theme.textIconSecondaryColor,
            tabs: [
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: badges.Badge(
                  badgeContent: Text(
                    allOrders.length.toString(),
                    style: TextStyle(color: theme.activeTextIconColor),
                  ),
                  badgeStyle: badges.BadgeStyle(badgeColor: theme.successColor),
                  position: badges.BadgePosition.topEnd(top: -15, end: -20),
                  child: const Text('All Orders'),
                ),
              ),
              ...branches.map((branch) {
                final branchOrders = ordersByBranch[branch];
                return Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: badges.Badge(
                    badgeContent: Text(
                      (branchOrders?.length ?? 0).toString(),
                      style: TextStyle(color: theme.inactiveTextIconColor),
                    ),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: theme.successColor,
                    ),
                    position: badges.BadgePosition.topEnd(top: -15, end: -20),
                    child: Text(branch),
                  ),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(orderServicesProvider);
                },
                child: OrderListView(orders: allOrders, theme: theme),
              ),
              ...branches.map((branch) {
                final branchOrders = ordersByBranch[branch]!;
                return branchOrders.isNotEmpty
                    ? OrderListView(orders: branchOrders, theme: theme)
                    : Center(
                      child: Text(
                        'No Orders for this branch',
                        style: TextStyle(color: theme.textIconPrimaryColor),
                      ),
                    );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class OrderListView extends StatelessWidget {
  const OrderListView({super.key, required this.orders, required this.theme});
  final List<Map<String, dynamic>> orders;
  final ThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No Orders',
          style: TextStyle(color: theme.textIconPrimaryColor),
        ),
      );
    }
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderItemCard(order: order, theme: theme);
      },
    );
  }
}

class OrderItemCard extends StatelessWidget {
  const OrderItemCard({super.key, required this.order, required this.theme});
  final Map<String, dynamic> order;
  final ThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.primaryBackGround,
      child: ListTile(
        title: Text.rich(
          TextSpan(
            text: order['billno'] ?? 'Unknown Bill No',
            style: TextStyle(color: theme.activeTextIconColor),
            children: [
              TextSpan(
                text:
                    '\nAmount : ${(order['amount'] as num?)?.toDouble().money ?? 'N/A'}',
                style: TextStyle(color: theme.activeTextIconColor),
              ),
            ],
          ),
        ),
        subtitle: Text.rich(
          TextSpan(
            text: 'Payment : ${order['type'] ?? 'Unknown Payment Type'}',
            style: TextStyle(color: theme.inactiveTextIconColor),
            children: [
              TextSpan(
                text: '\nTicket : ${order['receipt'] ?? 'Unknown Receipt'}',
              ),
              TextSpan(
                text:
                    '\nCompleted By : ${order['agentname'] ?? 'Unknown Agent'}',
              ),
              TextSpan(
                text:
                    '\nCompleted On : ${DateFormat.yMMMd().format(DateTime.tryParse(order['endTime'] ?? '') ?? DateTime.now())}',
                style: TextStyle(color: theme.activeTextIconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
