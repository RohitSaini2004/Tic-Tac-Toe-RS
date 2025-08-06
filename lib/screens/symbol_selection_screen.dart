import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SymbolSelectionScreen extends StatefulWidget {
  const SymbolSelectionScreen({super.key});

  @override
  State<SymbolSelectionScreen> createState() => _SymbolSelectionScreenState();
}

class _SymbolSelectionScreenState extends State<SymbolSelectionScreen> {
  final List<String> allSymbols = ['X', 'O', '🙂', '😎', '❤️', '⭐', '🎯', '🔥'];

  String? selectedPlayerSymbol;
  String? selectedAiSymbol;

  List<String> get availableAiSymbols {
    return allSymbols.where((symbol) => symbol != selectedPlayerSymbol).toList();
  }

  void autoSelectAiSymbol() {
    final options = availableAiSymbols;
    if (options.isNotEmpty) {
      selectedAiSymbol = options[Random().nextInt(options.length)];
    } else {
      selectedAiSymbol = null;
    }
  }

  Future<void> saveSymbols() async {
    if (selectedPlayerSymbol == null || selectedAiSymbol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both symbols')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerSymbol', selectedPlayerSymbol!);
    await prefs.setString('aiSymbol', selectedAiSymbol!);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Symbols')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Player Symbol', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedPlayerSymbol,
              hint: const Text('Choose your symbol'),
              isExpanded: true,
              items: allSymbols.map((symbol) {
                return DropdownMenuItem(
                  value: symbol,
                  child: Text(symbol, style: const TextStyle(fontSize: 24)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPlayerSymbol = value;
                  autoSelectAiSymbol(); // 🎯 Auto-select AI symbol
                });
              },
            ),
            const SizedBox(height: 24),
            const Text('AI Symbol (Auto-selected)', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                selectedAiSymbol ?? 'Not selected',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: saveSymbols,
                child: const Text('Save and Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
