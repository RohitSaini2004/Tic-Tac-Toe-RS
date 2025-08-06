import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> gameHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFirestoreHistory();
  }

  Future<void> loadFirestoreHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data != null && data['history'] != null) {
        final List<dynamic> rawHistory = data['history'];
        setState(() {
          gameHistory = rawHistory.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error loading history: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : gameHistory.isEmpty
              ? const Center(child: Text("No history found"))
              : ListView.builder(
                  itemCount: gameHistory.length,
                  itemBuilder: (context, index) {
                    final entry = gameHistory[index];
                    final timestamp = entry['timestamp'];
                    String formattedTime = '';

                    if (timestamp != null && timestamp is Timestamp) {
                      final dateTime = timestamp.toDate();
                      formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                    }

                    return ListTile(
                      leading: Icon(
                        entry['result'] == 'Win'
                            ? Icons.emoji_events
                            : entry['result'] == 'Lose'
                                ? Icons.close
                                : Icons.handshake,
                        color: entry['result'] == 'Win'
                            ? Colors.green
                            : entry['result'] == 'Lose'
                                ? Colors.red
                                : Colors.grey,
                      ),
                      title: Text(entry['result'] ?? 'Unknown'),
                      subtitle: Text(formattedTime),
                    );
                  },
                ),
    );
  }
}
