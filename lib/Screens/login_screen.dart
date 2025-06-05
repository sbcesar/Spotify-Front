import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:spotify_tfg_flutter/Service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
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
          Navigator.pushReplacementNamed(context, '/main');
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
      backgroundColor: const Color(0xFF0D1C2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1C2F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFB1D1EC), // Color de la flecha
          onPressed: () {
            Navigator.pop(context); // Volver atrás
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                "Log in to Your Account",
                style: TextStyle(
                  color: Color(0xFFB1D1EC),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 100),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Color(0xFFB1D1EC)),
                  filled: true,
                  fillColor: const Color(0xFF2C698D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Color(0xFFB1D1EC)),
                  filled: true,
                  fillColor: const Color(0xFF2C698D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7495B4),
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadowColor: Colors.black.withOpacity(0.3),
                  elevation: 5,
                ),
                child: const Text(
                  "Iniciar sesión",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
