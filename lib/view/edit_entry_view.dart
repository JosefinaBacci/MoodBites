import 'package:flutter/material.dart';
import '../presenter/journal_presenter.dart';

class EditEntryView extends StatefulWidget {
  final Map<String, dynamic> entry;
  const EditEntryView({required this.entry, super.key});

  @override
  _EditEntryViewState createState() => _EditEntryViewState();
}

class _EditEntryViewState extends State<EditEntryView> {
  final journalPresenter = JournalPresenter();
  late TextEditingController _textController;
  late String selectedMood;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.entry['text']);
    selectedMood = widget.entry['mood'] ?? 'neutral';
  }

  void _save() async {
    try {
      final date = DateTime.parse(widget.entry['date']);
      final entryId = widget.entry['id'];

      await journalPresenter.editEntry(
        entryId: entryId,
        date: date,
        text: _textController.text.trim(),
        mood: selectedMood,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update entry: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Entry text'),
            ),
            DropdownButton<String>(
              value: selectedMood,
              items: const [
                DropdownMenuItem(value: 'happy', child: Text('happy')),
                DropdownMenuItem(value: 'sad', child: Text('sad')),
                DropdownMenuItem(value: 'neutral', child: Text('neutral')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => selectedMood = val);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save Changes')),
          ],
        ),
      ),
    );
  }
}
