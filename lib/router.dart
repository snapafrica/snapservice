import 'package:snapservice/common.dart';

final appRouterProvider = Provider((ref) {
  final routeService = ref.watch(appRouteService);
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    initialLocation: LocalStorage.nosql.screenLock ? '/welcome_page' : '/',
    navigatorKey: rootNavigatorKey,
    refreshListenable: routeService,
    redirect: routeService.handleRedirect,
    restorationScopeId: 'ex',
    routes: [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sign_in',
        builder: (context, state) => SigninPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/welcome_page',
        builder: (context, state) => const PasswordPAge(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sign_up',
        builder: (context, state) => SignupPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/subscription',
        builder: (context, state) => SubscriptionPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/forgot_password',
        builder: (context, state) => ForgotPasswordPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/verify_password',
        builder: (context, state) => OTPVerificationPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/reset_password',
        builder: (context, state) => CreateNewPasswordPage(),
      ),
      GoRoute(
        path: '/customer_screen',
        builder: (context, state) {
          final isAgent = state.uri.queryParameters['isAgent'] == 'true';
          return CustomerAgentScreen(isAgent: isAgent);
        },
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainPage(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                fadeTransitionPage(state, const HomePage()),
            routes: [
              GoRoute(
                path: 'create_order',
                pageBuilder: (context, state) {
                  final cartItems = state.extra as List<Savis>? ?? [];
                  return fadeTransitionPage(
                    state,
                    ServiceCartPage(cartItems: cartItems),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) =>
                fadeTransitionPage(state, const OrdersPage()),
            routes: [
              GoRoute(
                path: 'complete/:oid',
                pageBuilder: (context, state) => fadeTransitionPage(
                  state,
                  CompleteOrderPage(
                    orderId: num.tryParse(state.pathParameters['oid']!) ?? 0,
                  ),
                ),
              ),
              GoRoute(
                path: 'add_service/:oid',
                pageBuilder: (context, state) => fadeTransitionPage(
                  state,
                  OrderAddService(
                    orderId: num.tryParse(state.pathParameters['oid']!) ?? 0,
                  ),
                ),
              ),
              GoRoute(
                path: 'add_addons/:oid/:tid',
                pageBuilder: (context, state) => fadeTransitionPage(
                  state,
                  OrderAddAddon(
                    orderId: num.tryParse(state.pathParameters['oid']!) ?? 0,
                    itemId: num.tryParse(state.pathParameters['tid']!) ?? 0,
                  ),
                ),
              ),
              GoRoute(
                path: 'update_order/:oid',
                pageBuilder: (context, state) => fadeTransitionPage(
                  state,
                  UpdateOrderPage(orderId: state.pathParameters['oid']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/inventory',
            pageBuilder: (context, state) =>
                fadeTransitionPage(state, const InventoryPage()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                fadeTransitionPage(state, const SettingsPage()),
            routes: [
              GoRoute(
                path: 'commission',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const CommissionPage()),
              ),
              GoRoute(
                path: 'cash_register',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const CashRegisterPage()),
              ),
              GoRoute(
                path: 'summary',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const SummaryPage()),
              ),
              GoRoute(
                path: 'completed_orders',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const CompletedOrdersPage()),
              ),
              GoRoute(
                path: 'mpesa_codes',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const MpesaCodesPage()),
              ),
              GoRoute(
                path: 'agents',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const AgentsPage()),
              ),
              GoRoute(
                path: 'branches',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const BranchesPage()),
              ),
              GoRoute(
                path: 'all_orders',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const AllOrdersPage()),
              ),
              GoRoute(
                path: 'booked_orders',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const BookedOrdersPage()),
              ),
              GoRoute(
                path: 'edit_services',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const EditServicesPage()),
              ),
              GoRoute(
                path: 'account_settings',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const SettingsDetailPage()),
              ),
              GoRoute(
                path: 'theme_settings',
                pageBuilder: (context, state) =>
                    fadeTransitionPage(state, const ColorCustomizationPage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

final appRouteService = ChangeNotifierProvider((ref) => AppRouteService());

class AppRouteService extends ChangeNotifier {
  AppRouteService() {
    user = LocalStorage.nosql.user;
  }

  ServiceUser? user;

  String? handleRedirect(BuildContext context, GoRouterState state) {
    final pathLocaton = state.fullPath ?? '';

    // if user has been deleted
    if (user == null) {
      final resetPassGroup = pathLocaton.startsWith('/sign_in');

      if (resetPassGroup) {
        return null;
      }
      return '/sign_in';
    }

    // if user is an employee dont show the services tab
    if (user?.type == EMPLOYEE_TYPE_NAME && pathLocaton == '/') {
      return '/orders';
    }
    return null; // do nothing
  }

  void refreshUser() {
    user = LocalStorage.nosql.user;

    if (user?.subscriptionStatus == 'notsubscribed') {
      return;
    } else {
      // Apparently this restarts the router and goes to the initial route eg "/" .
      // This are rumors though .
      notifyListeners();
    }
  }
}

CustomTransitionPage<T> fadeTransitionPage<T>(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      );
    },
  );
}
