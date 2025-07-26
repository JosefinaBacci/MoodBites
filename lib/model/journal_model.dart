import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalModel {
  final _db = FirebaseFirestore.instance;

  Future<void> storeEntry({
    required String text,
    required String mood,
    required DateTime date,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    await _db.collection('journal_entries').add({
      'userId': uid,
      'text': text,
      'mood': mood,
      'date': date.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllEntries() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    final snapshot = await _db
        .collection('journal_entries')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }
}
