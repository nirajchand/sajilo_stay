import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final dashboardTabIndexProvider = NotifierProvider<DashboardTabNotifier, int>(
  () => DashboardTabNotifier(),
);
