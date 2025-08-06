import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_result.dart';
import '../services/auth_service.dart';

class LocalStorage {
  static const _historyKey = 'game_history';

  // Save to both SharedPreferences and Firestore
  static Future<void> saveGameResult(GameResult result) async {
    // 🔹 Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final history = await getGameHistory();
    history.add(result);
    final encoded = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, encoded);

    // 🔹 Save to Firestore
    final uid = AuthService.getUserId();
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('game_history')
          .doc(uid)
          .collection('games')
          .add(result.toJson());
    }
  }

  // Load from SharedPreferences
  static Future<List<GameResult>> getGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => GameResult.fromJson(e)).toList();
  }

  // Optional: Load from Firestore (if you want)
  static Future<List<GameResult>> getGameHistoryFromFirestore() async {
    final uid = AuthService.getUserId();
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('game_history')
        .doc(uid)
        .collection('games')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GameResult.fromJson(doc.data()))
        .toList();
  }
}
