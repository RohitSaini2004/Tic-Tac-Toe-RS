import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/auth_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, '');
  String playerSymbol = 'X';
  String aiSymbol = 'O';
  bool gameEnded = false;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadSymbols();
  }

  Future<void> loadSymbols() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      playerSymbol = prefs.getString('playerSymbol') ?? 'X';
      aiSymbol = prefs.getString('aiSymbol') ?? 'O';
    });
  }

  void playSound(String fileName) async {
    await player.play(AssetSource('sounds/$fileName'));
  }

  void userMove(int index) {
    if (!gameEnded && board[index] == '') {
      setState(() {
        board[index] = playerSymbol;
      });
      playSound('move.mp3');
      checkGameStatus();

      if (!gameEnded && getWinner() == null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          aiMove();
        });
      }
    }
  }

  void aiMove() {
    final emptyIndexes = <int>[];
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') emptyIndexes.add(i);
    }

    if (emptyIndexes.isNotEmpty) {
      final rand = Random();
      final move = emptyIndexes[rand.nextInt(emptyIndexes.length)];
      setState(() {
        board[move] = aiSymbol;
      });
      playSound('move.mp3');
      checkGameStatus();
    }
  }

  void checkGameStatus() async {
    if (gameEnded) return;

    final winner = getWinner();
    final prefs = await SharedPreferences.getInstance();
    int score = prefs.getInt('score') ?? 0;
    String result;

    if (winner == playerSymbol) {
      result = 'Win';
      score += 10;
      playSound('win.mp3');
    } else if (winner == aiSymbol) {
      result = 'Lose';
      score -= 10;
      playSound('lose.mp3');
    } else if (!board.contains('')) {
      result = 'Draw';
      playSound('draw.mp3');
    } else {
      return;
    }

    gameEnded = true;
    await prefs.setInt('score', score);
    final playerName = prefs.getString('playerName') ?? 'Player';
    final uid = AuthService.getUserId();

    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'history': FieldValue.arrayUnion([
          {
            'playerName': playerName,
            'result': result,
            'timestamp': Timestamp.fromDate(DateTime.now()),
          }
        ])
      }).catchError((e) {
        print("❌ Error saving game history: $e");
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Result: $result'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                board = List.filled(9, '');
                gameEnded = false;
              });
            },
            child: const Text('Start New Game'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }

  String? getWinner() {
    const winConditions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var line in winConditions) {
      String a = board[line[0]];
      String b = board[line[1]];
      String c = board[line[2]];
      if (a != '' && a == b && b == c) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => userMove(index),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.blue[50],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
