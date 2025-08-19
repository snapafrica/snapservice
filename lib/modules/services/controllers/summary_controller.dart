import 'package:snapservice/common.dart';

final summaryServicesProvider =
    StateNotifierProvider<SummaryServiceNotifier, ServiceSummary>((ref) {
      final authService = ref.watch(authenticationServiceProvider);
      return SummaryServiceNotifier(authService: authService.value);
    });

class SummaryServiceNotifier extends StateNotifier<ServiceSummary> {
  SummaryServiceNotifier({required this.authService})
    : super(ServiceSummary.loading()) {
    if (authService != null) init();
  }

  final AuthData? authService;
  final _apiService = ApiProvider();

  Future<void> init() async {
    await getStoreSales();
    await getStoreSummary();
  }

  Future<void> getStoreSales({
    (DateTime start, DateTime end)? range,
    bool isRefresh = false,
  }) async {
    if (range != null || isRefresh) {
      state = state.copyWith(storesales: const AsyncLoading());
    }
    final user = authService!.user;
    final body = {
      'merchant': user.merchant,
      'storenumber': '',
      'shop': user.shop,
      'id': '${user.id}',
      'usertype': '',
      'store': user.storeName,
      'type': user.type,
      'start_date': sDate(range?.$1 ?? DateTime.now()),
      'end_date': sDate(range?.$2 ?? DateTime.now()),
      'start': sDate(range?.$1 ?? DateTime.now()),
      'end': sDate(range?.$2 ?? DateTime.now()),
    };
    final dynamic response = await _apiService.post(
      '/pesafy/storesales.php',
      body: body,
    );
    final responseData = response['data'];
    final data = List<Map>.from(responseData.map((e) => e as Map));
    state = state.copyWith(storesales: AsyncData(data));
    // }
  }

  Future<void> getStoreSummary({
    (DateTime start, DateTime end)? range,
    bool isRefresh = false,
  }) async {
    if (range != null || isRefresh) {
      state = state.copyWith(storesummary: const AsyncLoading());
    }
    final user = authService!.user;
    final body = {
      'merchant': user.merchant,
      'storenumber': '',
      'shop': user.shop,
      'id': '${user.id}',
      'usertype': '',
      'store': user.storeName,
      'type': user.type,
      'start_date': sDate(range?.$1 ?? DateTime.now()),
      'end_date': sDate(range?.$2 ?? DateTime.now()),
      'start': sDate(range?.$1 ?? DateTime.now()),
      'end': sDate(range?.$2 ?? DateTime.now()),
    };
    final dynamic response = await _apiService.post(
      '/fetch_summary.php',
      body: body,
    );
    final data = List<Map>.from((response).map((e) => e as Map));
    final summ = <String, Map<String, num>>{};
    for (var i in data) {
      // if the store data is not in the map, add it
      final completed = summ[i['store']]?['completed'];
      if (completed == null) {
        summ[i['store']] = {
          'completed': 0,
          'service': 0,
          'waiting': 0,
          'completed_booked': 0,
          'service_booked': 0,
          'waiting_booked': 0,
        };
      }

      final inservice = summ[i['store']]!['service']!;
      final waiting = summ[i['store']]!['waiting']!;

      // separate the data based on the order type
      if (i['ordertype'] == 'shop') {
        if (i['status'] == 'Complete') {
          summ[i['store']]!['completed'] = 1 + (completed ?? 0);
        }
        if (i['status'] == 'In-Service') {
          summ[i['store']]!['service'] = 1 + inservice;
        }
        if (i['status'] == 'Waiting') {
          summ[i['store']]!['waiting'] = 1 + waiting;
        }
      } else if (i['ordertype'] == 'booking') {
        final completed = summ[i['store']]!['completed_booked']!;
        final inservice = summ[i['store']]!['service_booked']!;
        final waiting = summ[i['store']]!['waiting_booked']!;
        if (i['status'] == 'Complete') {
          summ[i['store']]!['completed_booked'] = 1 + completed;
        }
        if (i['status'] == 'In-Service') {
          summ[i['store']]!['service_booked'] = 1 + inservice;
        }
        if (i['status'] == 'Waiting') {
          summ[i['store']]!['waiting_booked'] = 1 + waiting;
        }
      }
    }
    final ttsum =
        summ.keys
            .map(
              (e) => {
                'name': e,
                'completed': summ[e]!['completed'],
                'service': summ[e]!['service'],
                'waiting': summ[e]!['waiting'],
                'completed_booked': summ[e]!['completed_booked'],
                'service_booked': summ[e]!['service_booked'],
                'waiting_booked': summ[e]!['waiting_booked'],
              },
            )
            .toList();
    state = state.copyWith(storesummary: AsyncData(ttsum));
  }
}
