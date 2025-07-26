class StatsModel {
  Map<String, int> computeWeeklyMoodStats(List<Map<String, dynamic>> entries) {
    final stats = <String, int>{};
    for (final e in entries) {
      final mood = e['mood'] as String;
      stats[mood] = (stats[mood] ?? 0) + 1;
    }
    return stats;
  }
}
