import 'package:flutter/material.dart';
import '../presenter/journal_presenter.dart';
import 'edit_entry_view.dart';

class EntriesView extends StatefulWidget {
  const EntriesView({super.key});

  @override
  _EntriesViewState createState() => _EntriesViewState();
}

class _EntriesViewState extends State<EntriesView> {
  final journalPresenter = JournalPresenter();
  bool loading = true;
  List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final loaded = await journalPresenter.getAllEntries();
      setState(() {
        entries = loaded;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load entries: $e')));
    }
  }

  void _openEditEntry(Map<String, dynamic> entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditEntryView(entry: entry)),
    ).then((_) => _loadEntries());
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (entries.isEmpty) {
      return const Center(child: Text('No entries found.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Journal Entries')),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final e = entries[index];
          final date = DateTime.parse(e['date']);
          final formattedDate =
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          return ListTile(
            title: Text(formattedDate),
            subtitle: Text(e['text']),
            trailing: Text(e['mood']),
            onTap: () => _openEditEntry(e),
          );
        },
      ),
    );
  }
}
