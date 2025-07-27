import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimeCapsuleModel {
  final _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getTimeCapsulesForUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final snapshot = await _db
        .collection('time_capsules')
        .where('userId', isEqualTo: uid)
        .orderBy('unlockAt')
        .get();

    final now = DateTime.now().toUtc();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;

      // Convertir a UTC para comparación correcta
      final unlockAt = (data['unlockAt'] as Timestamp).toDate().toUtc();
      final remaining = unlockAt.difference(now);

      data['timeRemaining'] = remaining;
      data['isUnlocked'] = remaining <= Duration.zero;

      return data;
    }).toList();
  }

  Future<void> markAsOpened(String capsuleId) async {
    final docRef = _db.collection('time_capsules').doc(capsuleId);
    await docRef.update({'isOpened': true});
  }

  Future<void> createTimeCapsule(String message, DateTime unlockAt) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final docRef = _db.collection('time_capsules').doc();
    await docRef.set({
      'userId': uid,
      'message': message,
      'unlockAt': Timestamp.fromDate(unlockAt.toUtc()), // Guardar en UTC
      'isOpened': false,
    });
  }
}
