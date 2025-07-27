import '../model/journal_model.dart';

class EntryPresenter {
  final JournalModel _jm = JournalModel();

  Future<void> saveEntry(DateTime date, String text, String mood) {
    return _jm.storeEntry(text: text, mood: mood, date: date);
  }

  Future<String> getFoodSuggestion(String text, String mood) {
    return _jm.analyzeAndGetFood(text, mood);
  }

  Future<List<Map<String, dynamic>>> loadEntries() => _jm.getAllEntries();
}
