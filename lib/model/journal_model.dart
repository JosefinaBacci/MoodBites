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

    final start = Timestamp.fromDate(
      DateTime(date.year, date.month, date.day).toUtc(),
    );
    final end = Timestamp.fromDate(
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toUtc(),
    );

    final query = await _db
        .collection('journal_entries')
        .where('userId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    if (query.docs.isNotEmpty) {
      throw Exception('Entry for this date already exists');
    }

    await _db.collection('journal_entries').add({
      'userId': uid,
      'text': text,
      'mood': mood,
      'date': Timestamp.fromDate(date.toUtc()),
    });
  }

  Future<void> updateEntry({
    required String entryId,
    String? text,
    String? mood,
    DateTime? date,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final Map<String, dynamic> updatedData = {};

    if (text != null) updatedData['text'] = text;
    if (mood != null) updatedData['mood'] = mood;
    if (date != null) updatedData['date'] = date.toIso8601String();

    if (updatedData.isEmpty) return; // Nothing to update

    final docRef = _db.collection('journal_entries').doc(entryId);
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) throw Exception('Entry not found');
    if (docSnapshot.data()?['userId'] != uid) {
      throw Exception('Not authorized to update this entry');
    }

    await docRef.update(updatedData);
  }

  String _formatDateKey(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }

  Future<List<Map<String, dynamic>>> getAllEntries() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    final snapshot = await _db
        .collection('journal_entries')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}
