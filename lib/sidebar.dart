import 'dart:async';
import 'dart:io';
import 'package:snapservice/common.dart';
import 'package:flutter/cupertino.dart';

class MainPage extends ConsumerStatefulWidget {
  final Widget child;
  const MainPage({super.key, required this.child});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
    onesignalPermission();
    unawaited(configureOnesignal(ref.read(appRouterProvider)));
    if ((Platform.isAndroid || Platform.isIOS)) {
      ref.read(quickActionsServiceProvider);
    }
    checkUpdate();
  }

  checkUpdate() async {
    if (Platform.isAndroid) {
      InAppUpdateManager manager = InAppUpdateManager();
      AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();
      if (appUpdateInfo == null) {
        return;
      }
      if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        ///If an in-app update is already running, resume the update.

        await manager.startAnUpdate(type: AppUpdateType.immediate);

        ///message return null when run update success
      } else if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        ///Update available
        if (appUpdateInfo.immediateAllowed) {
          await manager.startAnUpdate(type: AppUpdateType.immediate);

          ///message return null when run update success
        } else if (appUpdateInfo.flexibleAllowed) {
          debugPrint('Start an flexible update');
          await manager.startAnUpdate(type: AppUpdateType.flexible);

          ///message return null when run update success
        } else {
          debugPrint(
            'Update available. Immediate & Flexible Update Flow not allow',
          );
        }
      }
    }
  }

  @override
  dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> onesignalPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      OneSignal.Notifications.requestPermission(true).then((accepted) {
        Logger('ONESIGNAL').finest('Accepted permission: $accepted');
      });
    }
  }

  Future<void> configureOnesignal(GoRouter router) async {
    if (Platform.isAndroid || Platform.isIOS) {
      OneSignal.Notifications.addClickListener((event) {
        final page = event.notification.additionalData?['page'].toString();
        if (page != null) {
          router.go(page);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);

    final bool isDesktop = MediaQuery.of(context).size.width > 800;
    final currentRoute = GoRouterState.of(context).uri.toString();
    final route = currentRoute;

    ServiceUser? user =
        ref.watch(authenticationServiceProvider).valueOrNull?.user ??
        LocalStorage.nosql.user;

    final destinations = _destinations(user?.type);

    return Scaffold(
      backgroundColor: theme.primaryBackGround,
      body: isDesktop
          ? Row(
              children: [
                Container(
                  width: 70,
                  padding: const EdgeInsets.only(top: 24, right: 12, left: 12),
                  height: MediaQuery.of(context).size.height,
                  child: _sideMenu(
                    context,
                    theme,
                    route,
                    currentRoute,
                    destinations,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 24, right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      color: theme.secondaryBackGround,
                    ),
                    child: widget.child,
                  ),
                ),
              ],
            )
          : widget.child,
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              backgroundColor: theme.primaryBackGround,
              selectedItemColor: theme.activeBackGround,
              unselectedItemColor: theme.inactiveBackGround,
              type: BottomNavigationBarType.fixed,
              currentIndex: _getSelectedIndex(currentRoute, destinations),

              onTap: (idx) {
                setState(() {
                  context.go(destinations[idx]['page'] as String);
                });
              },
              items: destinations.map((dest) {
                bool isActive = _isRouteActive(
                  dest['page'] as String,
                  currentRoute,
                );
                return BottomNavigationBarItem(
                  icon: Icon(
                    isActive
                        ? dest['active_icon'] as IconData
                        : dest['icon'] as IconData,
                    size: 30,
                  ),
                  label: dest['name'] as String,
                );
              }).toList(),
            )
          : null,
    );
  }

  bool _isRouteActive(String route, String currentRoute) {
    // Check if it's the "Services" route ("/") and exactly matches the path
    if (route == '/') {
      return currentRoute == '/'; // Only active when you're exactly on "/"
    }
    // For other routes, check if the currentRoute starts with the destination's route
    return currentRoute.startsWith(route);
  }

  int _getSelectedIndex(
    String currentRoute,
    List<Map<String, Object>> destinations,
  ) {
    for (int i = 0; i < destinations.length; i++) {
      if (_isRouteActive(destinations[i]['page'] as String, currentRoute)) {
        return i;
      }
    }
    return 0;
  }

  Widget _sideMenu(
    BuildContext context,
    ThemeConfig theme,
    String route,
    String currentRoute,
    List<Map<String, Object>> destinations,
  ) {
    return Column(
      children: [
        _logo(theme, route, currentRoute),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: destinations
                .map(
                  (dest) => _itemMenu(
                    menu: dest['name'] as String,
                    icon: dest['icon'] as IconData,
                    activeIcon: dest['active_icon'] as IconData,
                    route: dest['page'] as String,
                    context: context,
                    theme: theme,
                    currentRoute: currentRoute,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _itemMenu({
    required String menu,
    required IconData icon,
    required IconData activeIcon,
    required String route,
    required BuildContext context,
    required ThemeConfig theme,
    required String currentRoute,
  }) {
    bool isActive = _isRouteActive(route, currentRoute);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: GestureDetector(
        onTap: () => context.go(route),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive ? theme.activeBackGround : Colors.transparent,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.slowMiddle,
            child: Column(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? theme.activeTextIconColor
                      : theme.inactiveTextIconColor,
                ),
                const SizedBox(height: 5),
                Text(
                  menu,
                  style: TextStyle(
                    color: isActive
                        ? theme.activeTextIconColor
                        : theme.inactiveTextIconColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo(theme, route, currentRoute) {
    bool isActive = _isRouteActive(route, currentRoute);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: theme.activeBackGround,
          ),
          child: Icon(
            Icons.fastfood,
            color: theme.activeTextIconColor,
            size: 14,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Snap',
          style: TextStyle(
            color: isActive
                ? theme.inactiveTextIconColor
                : theme.activeTextIconColor,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void onWindowClose() {
    final theme = ref.watch(themeServicesProvider);

    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: theme.brightness,
            primaryColor: theme.deleteColor,
          ),
          child: CupertinoAlertDialog(
            title: Text(
              'Close Snapservice?',
              style: TextStyle(color: theme.textIconPrimaryColor),
            ),
            content: Text(
              'Are you sure you want to close this window?',
              style: TextStyle(color: theme.textIconPrimaryColor),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: Text('No', style: TextStyle(color: theme.successColor)),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  exit(0); // Force quit the app instantly
                },
                child: Text('Yes', style: TextStyle(color: theme.deleteColor)),
              ),
            ],
          ),
        );
      },
    );
  }
}

List<Map<String, Object>> _destinations(String? userType) => [
  if (userType == SUPERADMIN_TYPE_NAME || userType == FRONTOFFICE_TYPE_NAME)
    {
      'name': 'Services',
      'icon': Icons.build_circle_outlined,
      'active_icon': Icons.build_circle,
      'page': '/',
    },
  {
    'name': 'Queue',
    'icon': Icons.receipt_long_outlined,
    'active_icon': Icons.receipt_long,
    'page': '/orders',
  },
  {
    'name': 'Stock',
    'icon': Icons.storefront_outlined,
    'active_icon': Icons.storefront,
    'page': '/inventory',
  },
  {
    'name': 'Settings',
    'icon': Icons.settings_outlined,
    'active_icon': Icons.settings,
    'page': '/settings',
  },
];
