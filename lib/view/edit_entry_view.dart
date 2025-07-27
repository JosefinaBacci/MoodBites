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

  final List<String> moodOptions = ['😊', '😢', '😡', '🥱', '😌', '🤔'];

  final Map<String, String> moodMap = {
    '😊': 'Happy',
    '😢': 'Sad',
    '😡': 'Angry',
    '🥱': 'Tired',
    '😌': 'Calm',
    '🤔': 'Thoughtful',
  };

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.entry['text']);

    // El mood que viene es nombre, por ejemplo "Happy"
    String moodName = widget.entry['mood'] ?? 'Happy';

    // Busco el emoji que corresponde al nombre para seleccionarlo en el dropdown
    selectedMood = moodMap.entries
        .firstWhere(
          (entry) => entry.value == moodName,
          orElse: () => MapEntry('😊', 'Happy'),
        )
        .key;
  }

  void _save() async {
    try {
      final date = DateTime.parse(widget.entry['date']);
      final entryId = widget.entry['id'];

      // Obtengo el nombre del mood según el emoji seleccionado para guardar
      final moodName = moodMap[selectedMood] ?? 'Happy';

      await journalPresenter.editEntry(
        entryId: entryId,
        date: date,
        text: _textController.text.trim(),
        mood: moodName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update entry: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DBDD),
      appBar: AppBar(
        title: const Text(
          'Edit Entry',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 238, 236, 232),
          ),
        ),
        backgroundColor: const Color(0xFF3B4D65),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 238, 236, 232),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFE8E2DA),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF011C45),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Modify your entry below',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF011C45),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                minLines: 8,
                maxLines: null,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Write your thoughts...',
                  hintStyle: const TextStyle(color: Color(0xFF011C45)),
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFFF6F6F6),
                value: selectedMood,
                items: moodOptions
                    .map(
                      (emoji) => DropdownMenuItem(
                        value: emoji,
                        child: Text('$emoji ${moodMap[emoji]}'),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedMood = val);
                },
                decoration: InputDecoration(
                  labelText: 'Select Mood',
                  labelStyle: const TextStyle(color: Color(0xFF3B4D65)),
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B4D65),
                    foregroundColor: Color(0xFFE8E2DA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
