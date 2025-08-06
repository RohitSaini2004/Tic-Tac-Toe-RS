import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String get _uid => AuthService.getUserId() ?? 'unknown';

  /// Save or update the user's current score
  static Future<void> updateScore(int score) async {
    await _db.collection('users').doc(_uid).set(
      {'score': score},
      SetOptions(merge: true),
    );
  }

  /// Get the user's score (default 0 if not set)
  static Future<int> getScore() async {
    final doc = await _db.collection('users').doc(_uid).get();
    if (doc.exists && doc.data()!.containsKey('score')) {
      return doc['score'];
    }
    return 0;
  }

  /// Add a new game result to the user's history
  static Future<void> addGameResult(String result, String timestamp) async {
    await _db.collection('users').doc(_uid).collection('history').add({
      'result': result,
      'timestamp': timestamp,
    });
  }

  /// Fetch all past game results
  static Future<List<Map<String, dynamic>>> getGameHistory() async {
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
