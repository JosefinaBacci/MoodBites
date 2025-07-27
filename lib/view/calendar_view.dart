import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'entry_detail_view.dart';

class CalendarWrapper extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  const CalendarWrapper({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DBDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B4D65),
        title: const Text(
          'Mood Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 238, 236, 232),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 238, 236, 232),
        ),
      ),
      body: MoodCalendar(entries: entries),
    );
  }
}

class MoodCalendar extends StatefulWidget {
  final List<Map<String, dynamic>> entries;
  const MoodCalendar({super.key, required this.entries});

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  DateTime _focusedMonth = DateTime.now();
  late Map<int, Map<String, dynamic>> _entriesByDay;

  final Map<String, Color> emotionColors = {
    'Happy': Colors.amber,
    'Sad': Colors.blue,
    'Angry': Colors.redAccent,
    'Tired': Colors.green,
    'Calm': Colors.indigo,
    'Thoughtful': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _groupEntriesByDay();
  }

  void _groupEntriesByDay() {
    Map<int, Map<String, dynamic>> temp = {};
    for (var entry in widget.entries) {
      final dateDynamic = entry['date'];
      DateTime date;
      if (dateDynamic is Timestamp) {
        date = dateDynamic.toDate();
      } else if (dateDynamic is DateTime) {
        date = dateDynamic;
      } else if (dateDynamic is String) {
        date = DateTime.parse(dateDynamic);
      } else {
        continue;
      }

      if (date.year == _focusedMonth.year &&
          date.month == _focusedMonth.month) {
        temp[date.day] = entry;
      }
    }
    _entriesByDay = temp;
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _groupEntriesByDay();
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _groupEntriesByDay();
    });
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😡';
      case 'tired':
        return '🥱';
      case 'calm':
        return '😌';
      case 'thoughtful':
        return '😌';
      default:
        return '';
    }
  }

  Map<String, int> _calculateWeeklyStats() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // lunes
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    Map<String, int> stats = {
      'Happy': 0,
      'Sad': 0,
      'Angry': 0,
      'Tired': 0,
      'Calm': 0,
      'Thoughtful': 0,
    };

    for (var entry in widget.entries) {
      final dateDynamic = entry['date'];
      DateTime date;
      if (dateDynamic is Timestamp) {
        date = dateDynamic.toDate();
      } else if (dateDynamic is DateTime) {
        date = dateDynamic;
      } else if (dateDynamic is String) {
        date = DateTime.parse(dateDynamic);
      } else {
        continue;
      }

      if (!date.isBefore(startOfWeek) && !date.isAfter(endOfWeek)) {
        String moodRaw = entry['mood'] ?? 'Other';
        if (moodRaw.isEmpty) moodRaw = 'Other';
        String moodCap =
            moodRaw[0].toUpperCase() + moodRaw.substring(1).toLowerCase();

        if (!stats.containsKey(moodCap)) {
          moodCap = 'Other';
        }
        stats[moodCap] = (stats[moodCap] ?? 0) + 1;
      }
    }

    // DEBUG: para chequear que contemos bien
    debugPrint('Weekly Stats: $stats');

    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstWeekday = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    ).weekday;
    final daysBefore = firstWeekday % 7;

    final weeklyStats = _calculateWeeklyStats();
    final maxCount = weeklyStats.values.fold<int>(
      0,
      (prev, e) => e > prev ? e : prev,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousMonth,
                color: const Color(0xFF011C45),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF011C45),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextMonth,
                color: const Color(0xFF011C45),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Limitar altura para evitar overflow y dar espacio a estadísticas
          SizedBox(
            height: 280, // Ajusta a tu gusto para que no sea tan alto
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 238, 236, 232),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daysInMonth + daysBefore,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  if (index < daysBefore) return const SizedBox();
                  final day = index - daysBefore + 1;
                  final entry = _entriesByDay[day];
                  final mood = entry?['mood'] ?? '';
                  final emoji = _getMoodEmoji(mood);
                  final date = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month,
                    day,
                  );

                  return GestureDetector(
                    onTap: () {
                      if (entry != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JournalEntryDetailView(
                              date: date,
                              content: entry['text'] ?? '',
                              mood: entry['mood'] ?? '',
                              fullEntry: entry,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: entry != null
                            ? const Color(0xFFE3F2FD)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: entry != null
                            ? Border.all(
                                color: const Color(0xFF011C45),
                                width: 1,
                              )
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (emoji.isNotEmpty)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 238, 236, 232),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Mood Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF011C45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: weeklyStats.entries.map((e) {
                              final mood = e.key;
                              final count = e.value;
                              final color = emotionColors[mood] ?? Colors.grey;

                              double barWidthFactor = maxCount > 0
                                  ? count / maxCount
                                  : 0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        mood,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: barWidthFactor,
                                            child: Container(
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      count.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            if (maxCount == 0) {
                              return const Text(
                                'No mood data this week',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF011C45),
                                ),
                              );
                            }

                            final maxMood = weeklyStats.entries
                                .firstWhere((e) => e.value == maxCount)
                                .key;

                            return Text(
                              'This week you have felt mostly: $maxMood',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF011C45),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
