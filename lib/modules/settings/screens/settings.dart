import 'package:snapservice/common.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = MediaQuery.of(context).size.width;
    bool isSmallScreen = width < 600;
    final theme = ref.watch(themeServicesProvider);
    final userService = ref.watch(authenticationServiceProvider);
    final settingsService = ref.watch(settingsServicesProvider);
    final user = userService.valueOrNull?.user;

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar:
          isSmallScreen
              ? AppBar(
                backgroundColor: theme.secondaryBackGround,
                foregroundColor: theme.textIconPrimaryColor,
                elevation: 0,
                iconTheme: IconThemeData(color: theme.activeTextIconColor),
                title: _ResponsiveProfileHeader(isSmallScreen: true),
              )
              : null,
      body: Column(
        children: [
          if (!isSmallScreen) _ResponsiveProfileHeader(isSmallScreen: false),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: userService.when(
                loading:
                    () => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                error: (error, stackTrace) => const SizedBox.shrink(),
                data: (userData) {
                  final actions = _getCategorizedActions(settingsService, user);
                  return ListView(
                    padding: EdgeInsets.zero,
                    children:
                        actions.entries
                            .map(
                              (entry) => _CollapsibleSettingsCategory(
                                title: entry.key,
                                items:
                                    entry.value
                                        .where(
                                          (action) =>
                                              (action['show'] as List<String>)
                                                  .contains(user?.type),
                                        )
                                        .toList(),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveProfileHeader extends ConsumerWidget {
  final bool isSmallScreen;
  const _ResponsiveProfileHeader({required this.isSmallScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServicesProvider);
    final userService = ref.watch(authenticationServiceProvider);
    final user = userService.valueOrNull?.user;

    final textColor =
        isSmallScreen ? theme.textIconPrimaryColor : theme.activeTextIconColor;
    final bgColor =
        isSmallScreen ? Colors.transparent : theme.primaryBackGround;

    final avatar = CircleAvatar(
      radius: 20,
      backgroundColor: theme.activeBackGround,
      child: Icon(Icons.person, size: 24, color: theme.activeTextIconColor),
    );

    final userDetails = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user?.name != null && user!.name!.isNotEmpty)
          Text(user.name!, style: TextStyle(fontSize: 12, color: textColor)),
        Text(
          user?.email ?? 'Email',
          style: TextStyle(fontSize: 12, color: textColor),
        ),
        if (user?.phone != null && user!.phone!.isNotEmpty)
          Text(user.phone!, style: TextStyle(fontSize: 12, color: textColor)),
        if (user?.type != null && user!.type!.isNotEmpty)
          Text(user.type!, style: TextStyle(fontSize: 12, color: textColor)),
      ],
    );

    final popup = PopupMenuButton<_MenuActions>(
      icon: Icon(Icons.more_vert_rounded, color: textColor),
      color: theme.primaryBackGround,
      itemBuilder:
          (context) =>
              _MenuActions.values.map((e) {
                return PopupMenuItem<_MenuActions>(
                  value: e,
                  child: Row(
                    children: [
                      Icon(e.logo(), color: theme.activeTextIconColor),
                      const SizedBox(width: 16),
                      Text(
                        e.name(),
                        style: TextStyle(color: theme.activeTextIconColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
      onSelected: (item) {
        if (item == _MenuActions.logout) {
          ref.read(authenticationServiceProvider.notifier).logout();
        } else if (item == _MenuActions.customer) {
          context.go('/customer_screen?isAgent=false');
        } else if (item == _MenuActions.agentCustomer) {
          context.go('/customer_screen?isAgent=true');
        }
      },
    );

    final content = Row(
      children: [
        avatar,
        const SizedBox(width: 12),
        Expanded(child: userDetails),
        popup,
      ],
    );

    if (isSmallScreen) {
      return content;
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.cardShadowColor.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: content,
      );
    }
  }
}

class _CollapsibleSettingsCategory extends ConsumerStatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const _CollapsibleSettingsCategory({
    required this.title,
    required this.items,
  });

  @override
  ConsumerState<_CollapsibleSettingsCategory> createState() =>
      _CollapsibleSettingsCategoryState();
}

class _CollapsibleSettingsCategoryState
    extends ConsumerState<_CollapsibleSettingsCategory> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    return Card(
      color: theme.primaryBackGround,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.activeTextIconColor,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: theme.activeTextIconColor,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Column(
              children:
                  widget.items
                      .map(
                        (action) => _SettingsTile(
                          title: action['name'],
                          icon: action['icon'],
                          route: action['page'],
                          theme: theme,
                        ),
                      )
                      .toList(),
            ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final ThemeConfig theme;

  const _SettingsTile({
    required this.title,
    required this.icon,
    required this.route,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: theme.inactiveBackGround),
      title: Text(title, style: TextStyle(color: theme.activeTextIconColor)),
      onTap: () => context.go('/settings/$route'),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: theme.inactiveBackGround,
        size: 16,
      ),
    );
  }
}

enum _MenuActions {
  logout,
  customer,
  agentCustomer;

  String name() => switch (this) {
    _MenuActions.logout => 'Log out',
    _MenuActions.customer => 'Customer Portal',
    _MenuActions.agentCustomer => 'Agents Portal',
  };

  IconData logo() => switch (this) {
    _MenuActions.logout => Icons.logout_rounded,
    _MenuActions.customer => Icons.co_present_outlined,
    _MenuActions.agentCustomer => Icons.group_outlined,
  };
}

Map<String, List<Map<String, dynamic>>> _getCategorizedActions(
  SettingsConfig st,
  ServiceUser? user,
) {
  bool userHasPermission(List<Map<String, dynamic>> actions) {
    return actions.any((action) {
      return action['show'].contains(user?.type);
    });
  }

  final categories = {
    'Finance': [
      {
        'name': 'Commission',
        'page': 'commission',
        'icon': Icons.money,
        'show': [
          SUPERADMIN_TYPE_NAME,
          FRONTOFFICE_TYPE_NAME,
          EMPLOYEE_TYPE_NAME,
        ],
      },
      if ((!st.loading && st.showCashRegister) ||
          user?.type == SUPERADMIN_TYPE_NAME)
        {
          'name': 'Cash Register',
          'page': 'cash_register',
          'icon': Icons.attach_money,
          'show': [SUPERADMIN_TYPE_NAME, FRONTOFFICE_TYPE_NAME],
        },
      if ((!st.loading && st.showSummary) || user?.type == SUPERADMIN_TYPE_NAME)
        {
          'name': 'Summary',
          'page': 'summary',
          'icon': Icons.bar_chart_rounded,
          'show': [SUPERADMIN_TYPE_NAME, FRONTOFFICE_TYPE_NAME],
        },
      {
        'name': 'Mpesa Codes',
        'page': 'mpesa_codes',
        'icon': Icons.sms_outlined,
        'show': [SUPERADMIN_TYPE_NAME, FRONTOFFICE_TYPE_NAME],
      },
    ],
    'Orders Management': [
      {
        'name': 'Completed Orders',
        'page': 'completed_orders',
        'icon': Icons.check_circle_outline,
        'show': [
          SUPERADMIN_TYPE_NAME,
          FRONTOFFICE_TYPE_NAME,
          EMPLOYEE_TYPE_NAME,
        ],
      },
      {
        'name': 'Orders by Branch',
        'page': 'all_orders',
        'icon': Icons.sort,
        'show': [SUPERADMIN_TYPE_NAME],
      },
      {
        'name': 'Manage Bookings',
        'page': 'booked_orders',
        'icon': Icons.bookmark_added_outlined,
        'show': [SUPERADMIN_TYPE_NAME, FRONTOFFICE_TYPE_NAME],
      },
    ],
    'Agent Management': [
      {
        'name': 'Agents',
        'page': 'agents',
        'icon': Icons.groups_outlined,
        'show': [SUPERADMIN_TYPE_NAME],
      },
      {
        'name': 'Branches',
        'page': 'branches',
        'icon': Icons.apartment,
        'show': [SUPERADMIN_TYPE_NAME],
      },
    ],
    'Settings': [
      {
        'name': 'Edit Services & Addons',
        'page': 'edit_services',
        'icon': Icons.edit_note_rounded,
        'show': [SUPERADMIN_TYPE_NAME, FRONTOFFICE_TYPE_NAME],
      },
      {
        'name': 'Settings',
        'page': 'account_settings',
        'icon': Icons.settings_suggest_outlined,
        'show': [SUPERADMIN_TYPE_NAME, FRONTOFFICE_TYPE_NAME],
      },
      {
        'name': 'Color Customization',
        'page': 'theme_settings',
        'icon': Icons.color_lens,
        'show': [
          SUPERADMIN_TYPE_NAME,
          FRONTOFFICE_TYPE_NAME,
          EMPLOYEE_TYPE_NAME,
        ],
      },
    ],
  };

  Map<String, List<Map<String, dynamic>>> filteredCategories = {};

  categories.forEach((category, actions) {
    if (userHasPermission(actions)) {
      filteredCategories[category] = actions;
    }
  });

  return filteredCategories;
}
