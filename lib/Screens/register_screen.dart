import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:spotify_tfg_flutter/Service/auth_service.dart';
import '../DTO/usuario_register_dto.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Método para mostrar SnackBar con mensaje
  void _showSnackBar(String message, [Color color = Colors.red]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Método para validar los campos antes de registrar
  bool _validateFields() {
    if (_nombreController.text.isEmpty) {
      _showSnackBar("El nombre no puede estar vacío");
      return false;
    }
    if (_emailController.text.isEmpty ||
        !_emailController.text.contains('@') ||
        !_emailController.text.contains('.')) {
      _showSnackBar("El email no es válido");
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar("La contraseña debe tener al menos 6 caracteres");
      return false;
    }
    return true;
  }

  // Método para registrar el usuario
  Future<void> _registerUser() async {
    if (!_validateFields()) {
      print("❌ Validación fallida");
      return;
    }

    final usuario = UsuarioRegisterDTO(
      nombre: _nombreController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    try {
      print("➡ Intentando registrar usuario...");
      final response = await _authService.register(usuario);
      print("⬅ Respuesta recibida del backend: ${response.statusCode}");

      if (response.statusCode == 200) {
        _showSnackBar("Registro exitoso", Colors.green);

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Error desconocido';
        _showSnackBar(errorMessage);
      }
    } catch (e) {
      _showSnackBar("Error al registrar usuario");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "What's your name?"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "What's your email?"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Create a password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
