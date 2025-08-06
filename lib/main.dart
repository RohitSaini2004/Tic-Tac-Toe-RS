import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/enter_name_screen.dart'; // ✅ Add this
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/history_screen.dart';
import 'screens/symbol_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Tic Tac Toe RS',
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
    ),
    debugShowCheckedModeBanner: false,
    initialRoute: '/', // 👈 Start from splash screen
    routes: {
      '/': (context) => const SplashScreen(), // ✅ Splash screen
      '/login': (context) => const LoginScreen(),
      '/otp': (context) => const OTPScreen(),
      '/enter-name': (context) => const EnterNameScreen(),
      '/home': (context) => const HomeScreen(),
      '/game': (context) => const GameScreen(),
      '/history': (context) => const HistoryScreen(),
      '/select-symbol': (context) => const SymbolSelectionScreen(),
    },
  );
}
}