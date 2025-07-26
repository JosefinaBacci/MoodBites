import '../model/stats_model.dart';

class StatsPresenter {
  final StatsModel _sm = StatsModel();

  Map<String, int> loadStats(List<Map<String, dynamic>> entries) =>
      _sm.computeWeeklyMoodStats(entries);
}
