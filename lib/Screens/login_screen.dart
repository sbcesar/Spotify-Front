import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spotify_tfg_flutter/Service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget  {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> _login() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text);

      String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        final response = await _authService.login(idToken);

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          try {
            final Map<String, dynamic> body = jsonDecode(response.body);
            final errorMessage = body['message'] ?? "Error desconocido";
            _showErrorDialog(errorMessage);
          } catch (_) {
            _showErrorDialog("Error: ${response.statusCode}");
          }
        }
      }
    } catch (e) {
      _showErrorDialog("Error al iniciar sesión: $e");
    }
  }

    void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Aceptar"),
          )
        ],
      ),
    );
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log in"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Iniciar sesión"),
            )
          ],
        ),
      ),
    );
  }
}
