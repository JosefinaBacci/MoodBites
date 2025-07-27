import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../presenter/entry_presenter.dart';

class EntryView extends StatefulWidget {
  const EntryView({super.key});

  @override
  State<EntryView> createState() => _JournalEntryViewState();
}

class _JournalEntryViewState extends State<EntryView> {
  final TextEditingController _controller = TextEditingController();
  final EntryPresenter presenter = EntryPresenter();

  final DateTime entryDate = DateTime.now();
  String selectedMood = '😊';

  final List<String> moodOptions = ['😊', '😢', '😡', '🥱', '😌', '🤔'];

  final Map<String, String> moodMap = {
    '😊': 'Happy',
    '😢': 'Sad',
    '😡': 'Angry',
    '🥱': 'Tired',
    '😌': 'Calm',
    '🤔': 'Thoughtful',
  };

  String foodSuggestion = '';

  Future<void> _saveEntry() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final dateToSave = DateTime(
        entryDate.year,
        entryDate.month,
        entryDate.day,
      ); // Hora local 00:00
      final moodText = moodMap[selectedMood] ?? 'Neutral';

      await presenter.saveEntry(dateToSave, text, moodText);
      final suggestion = await presenter.getFoodSuggestion(text, moodText);

      setState(() {
        foodSuggestion = suggestion;
        _controller.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved entry and got food suggestion!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd().format(entryDate);

    return Scaffold(
      backgroundColor: const Color(0xFFD3DBDD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 7, 17, 59)),
        title: const Text(
          'New Entry',
          style: TextStyle(
            color: Color.fromARGB(255, 7, 17, 59),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: moodOptions.map((mood) {
                final isSelected = mood == selectedMood;
                return GestureDetector(
                  onTap: () => setState(() => selectedMood = mood),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF3B4D65)
                          : const Color.fromARGB(255, 255, 243, 188),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Text(mood, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 238, 236, 232),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _controller,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: Color.fromARGB(255, 7, 17, 59),
                  ),
                  decoration: const InputDecoration(
                    hintText: "Write your thoughts...",
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saveEntry,
              icon: const Icon(Icons.save),
              label: const Text('Save Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B4D65),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            if (foodSuggestion.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '🍽️ Food Suggestion: $foodSuggestion',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 7, 17, 59),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
