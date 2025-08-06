import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String verificationId = '';

  static Future<void> sendOtp(String phone, BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        await _postLogin(context); // ✅ await here
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed: ${e.message}")));
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        Navigator.pushNamed(context, '/otp');
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  static Future<void> verifyOtp(String otp, BuildContext context) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _postLogin(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("OTP Failed: $e")));
    }
  }

  static Future<void> _postLogin(BuildContext context) async {
    final uid = getUserId();
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists && doc.data()?['name'] != null) {
      final name = doc.data()?['name'];
      await prefs.setString('playerName', name);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/enter-name');
    }
  }

  static Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  static String? getUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static String? getUserPhone() {
    return FirebaseAuth.instance.currentUser?.phoneNumber;
  }
}
