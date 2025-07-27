import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class JournalModel {
  final _db = FirebaseFirestore.instance;

  Future<void> storeEntry({
    required String text,
    required String mood,
    required DateTime date,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final startOfDay = DateTime.utc(date.year, date.month, date.day);
    final start = Timestamp.fromDate(startOfDay);
    final end = Timestamp.fromDate(startOfDay.add(Duration(days: 1)));

    final query = await _db
        .collection('journal_entries')
        .where('userId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .get();

    if (query.docs.isNotEmpty) {
      throw Exception('Entry for this date already exists');
    }

    await _db.collection('journal_entries').add({
      'userId': uid,
      'text': text,
      'mood': mood,
      'date': start,
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
    if (date != null) updatedData['date'] = Timestamp.fromDate(date.toUtc());

    if (updatedData.isEmpty) return; // Nothing to update

    final docRef = _db.collection('journal_entries').doc(entryId);
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) throw Exception('Entry not found');
    if (docSnapshot.data()?['userId'] != uid) {
      throw Exception('Not authorized to update this entry');
    }

    await docRef.update(updatedData);
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

      if (data['date'] is Timestamp) {
        data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
      }

      return data;
    }).toList();
  }

  Future<String> analyzeAndGetFood(String text, String mood) async {
    final rnd = Random();

    final Map<String, List<String>> moodFoods = {
      'happy': [
        'Egyptian Mahshi',
        'Pakistan’s Chicken Biryani',
        'Rasmalai (India)',
        'Patishapta Pitha (Bangladesh)',
        'Argentinian Asado',
      ],
      'calm': [
        'Dal and Rice',
        'Foul and Ta3meya (fafa beans and falafel)',
        'Khichuri',
        'Garlic chicken salad',
        'Medialunas',
      ],
      'angry': [
        'Okra (Ladyfinger)',
        'Koshary (rice, lentils, and chickpea mix)',
        'Gulab Jamun',
        'Chocolate',
        'Pasta with vegetables',
      ],
      'sad': [
        'Maggie (Noodles)',
        'Basbousa (syrup soaked semolina dessert)',
        'Patishapta Pitha',
        'Ramen',
        'Milanesas with mashed potatoes',
      ],
      'tired': [
        'Matcha',
        'Coffee',
        'Om Ali (puff pastry w nuts and milk)',
        'Tea',
        'Khichuri',
      ],
    };

    final moodKey = mood.toLowerCase();

    if (moodFoods.containsKey(moodKey)) {
      final options = moodFoods[moodKey]!;
      return options[rnd.nextInt(options.length)];
    } else {
      return 'Unknown';
    }
  }
}
