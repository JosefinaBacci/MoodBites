import '../model/journal_model.dart';

class JournalPresenter {
  final JournalModel _jm = JournalModel();

  Future<void> saveEntry(DateTime date, String text, String mood) async {
    await _jm.storeEntry(text: text, mood: mood, date: date);
  }

  Future<void> editEntry({
    required String entryId,
    required String text,
    required String mood,
    required DateTime date,
  }) async {
    await _jm.updateEntry(entryId: entryId, text: text, mood: mood, date: date);
  }

  Future<String> analyzeAndGetFood(String text, String mood) =>
      _jm.analyzeAndGetFood(text, mood);

  Future<List<Map<String, dynamic>>> getAllEntries() => _jm.getAllEntries();
}
