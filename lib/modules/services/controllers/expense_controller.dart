import 'package:snapservice/common.dart';

final expenseServicesProvider =
    StateNotifierProvider<ExpenseServiceNotifier, AsyncValue<Map>>((ref) {
      final authService = ref.watch(authenticationServiceProvider);
      return ExpenseServiceNotifier(authService: authService.value);
    });

class ExpenseServiceNotifier extends StateNotifier<AsyncValue<Map>> {
  ExpenseServiceNotifier({required this.authService})
    : super(const AsyncLoading()) {
    if (authService != null) init();
  }

  final AuthData? authService;
  final _apiService = ApiProvider();

  Future<void> init({(DateTime start, DateTime end)? range}) async {
    if (range != null) {
      state = const AsyncLoading();
    }
    final user = authService!.user;
    final body = {
      'store': user.storeId ?? '',
      'shop': user.shop,
      'utype': user.type,
      'start': sDate(range?.$1 ?? DateTime.now()),
      'end': sDate(range?.$2 ?? DateTime.now()),
    };
    final dynamic response = await _apiService.post(
      '/cash_register.php',
      body: body,
    );
    // final responseData = response['data'];
    // final comms = List<Map>.from((responseData as List).map((e) => e as Map));
    state = AsyncData(response);
  }

  Future<void> add({
    required ({
      String reason,
      String type,
      String amount,
      String category,
      String store,
      String prevAmount,
      String id,
    })
    details,
    bool isUpdate = false,
  }) async {
    if (authService != null) {
      final user = authService!.user;
      final body =
          isUpdate
              ? {
                'id': details.id,
                'original_amount': details.prevAmount,
                'amount': details.amount,
                'type': details.type,
                'category': details.category,
                'description': details.reason,
                'user_id': user.id.toString(),
                'store': details.store,
                'shop': user.shop,
              }
              : {
                'amount': details.amount,
                'type': details.type,
                'category': details.category,
                'description': details.reason,
                'user_id': user.id.toString(),
                'store': details.store,
                'shop': user.shop,
              };
      await _apiService.post(
        isUpdate ? '/cash_register_update.php' : '/cash_register_adjust.php',
        body: body,
      );
    }
  }
}

final expenseCategoriesProvider = FutureProvider((ref) async {
  final dynamic response = await ApiProvider().post(
    '/fetch_category_expense.php',
    body: {'shop': ref.read(authenticationServiceProvider).value?.user.shop},
  );
  return List<Map>.from((response as List).map((e) => e as Map));
});
