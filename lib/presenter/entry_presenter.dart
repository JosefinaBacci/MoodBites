import '../model/journal_model.dart';

class EntryPresenter {
  final JournalModel _jm = JournalModel();

  Future<List<Map<String, dynamic>>> loadEntries() => _jm.getAllEntries();
}
