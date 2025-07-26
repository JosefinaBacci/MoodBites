import 'package:flutter/material.dart';
import '../presenter/journal_presenter.dart';
import '../presenter/chat_presenter.dart';
import '../presenter/entry_presenter.dart';
import '../presenter/login_presenter.dart';
import 'login_view.dart';
import 'entries_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final loginPresenter = LoginPresenter();
  final journalPresenter = JournalPresenter();
  final entryPresenter = EntryPresenter();
  final chatPresenter = ChatPresenter();

  final entryController = TextEditingController();
  String selectedMood = 'neutral';
  String aiResponse = '';
  String foodSuggestion = '';

  void _submitEntry() async {
    final text = entryController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    try {
      await journalPresenter.saveEntry(now, text, selectedMood);
      final suggestion = await journalPresenter.analyzeAndGetFood(text);

      setState(() {
        foodSuggestion = suggestion;
        entryController.clear();
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

  void _sendChat() async {
    await chatPresenter.sendMessage(entryController.text);
    setState(() {});
  }

  void _logout() {
    loginPresenter.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapy Journal'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: entryController,
              decoration: const InputDecoration(labelText: 'Write your entry'),
            ),
            DropdownButton<String>(
              value: selectedMood,
              items: const [
                DropdownMenuItem(value: 'happy', child: Text('happy')),
                DropdownMenuItem(value: 'sad', child: Text('sad')),
                DropdownMenuItem(value: 'neutral', child: Text('neutral')),
              ],
              onChanged: (val) => setState(() => selectedMood = val!),
            ),
            ElevatedButton(
              onPressed: _submitEntry,
              child: const Text('Save & Get Food Suggestion'),
            ),
            if (foodSuggestion.isNotEmpty)
              Text(
                '🍽️ Food Suggestion: $foodSuggestion',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EntriesView()),
                );
              },
              child: const Text('View My Entries'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _sendChat,
              child: const Text('Chat with Therapist Bot'),
            ),
            ...chatPresenter.messages.map(
              (m) => ListTile(
                title: Text(m.text),
                tileColor: m.isUser ? Colors.blue[100] : Colors.green[100],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
