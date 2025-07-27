import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../presenter/entry_presenter.dart';
import '../presenter/login_presenter.dart';
import 'login_view.dart';
import 'entries_view.dart';
import 'crumbot_view.dart';
import 'time_capsule_view.dart';
import 'calendar_view.dart';
import 'entry_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final EntryPresenter presenter = EntryPresenter();
  final LoginPresenter loginPresenter = LoginPresenter();

  List<Map<String, dynamic>> entries = [];
  bool _isLoading = true;

  final Map<String, String> emotionToEmoji = {
    'Happy': '😊',
    'Sad': '😢',
    'Angry': '😡',
    'Hopeful': '🥺',
    'Crying': '😭',
    'Thoughtful': '🤔',
  };

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final loaded = await presenter.loadEntries();
    setState(() {
      entries = loaded;
      _isLoading = false;
    });
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) throw Exception('Date is null');
    if (date is DateTime) return date;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    throw Exception('Unknown date type: ${date.runtimeType}');
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFD3DBDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B4D65),
        title: Text(
          formattedDate,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
            color: Color.fromARGB(255, 238, 236, 232),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Color.fromARGB(255, 238, 236, 232),
            tooltip: 'Logout',
            onPressed: () async {
              await loginPresenter.logout;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginView()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Your Mood Journal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF011C45)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : entries.isEmpty
                  ? const Center(
                      child: Text(
                        'No entries yet 📝',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final moodText = entry['mood'] ?? '';
                        final moodEmoji = emotionToEmoji[moodText] ?? '📝';
                        final dynamic rawDate = entry['date'];
                        final DateTime date = _parseDate(rawDate);
                        final String dateStr = DateFormat.yMMMd().format(date);
                        final String preview = (entry['text'] as String)
                            .split('\n')
                            .first;

                        return GestureDetector(
                          onTap: () async {
                            final didUpdate = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JournalEntryDetailView(
                                  date: date,
                                  content: entry['text'] as String,
                                  mood: entry['mood'] as String,
                                  fullEntry: entry,
                                ),
                              ),
                            );

                            if (didUpdate == true) {
                              _loadEntries();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 238, 236, 232),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF011C45),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF011C45),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  moodEmoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dateStr,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF011C45),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        preview,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildFAB(
              icon: Icons.add,
              tag: 'add',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EntryView()),
                ).then((_) => _loadEntries());
              },
            ),
            buildFAB(
              icon: Icons.chat_bubble,
              tag: 'crumbot',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatBotView()),
                );
              },
            ),
            buildFAB(
              icon: Icons.mail_lock,
              tag: 'timecapsule',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TimeCapsuleScreen()),
                );
              },
            ),
            buildFAB(
              icon: Icons.calendar_month,
              tag: 'calendar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CalendarWrapper(entries: entries),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildFAB({
    required IconData icon,
    required String tag,
    required VoidCallback onTap,
  }) {
    return FloatingActionButton(
      heroTag: tag,
      onPressed: onTap,
      backgroundColor: const Color(0xFF3B4D65),
      foregroundColor: const Color.fromARGB(255, 238, 236, 232),
      child: Icon(icon),
    );
  }
}
