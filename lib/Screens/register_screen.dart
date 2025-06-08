import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../DTO/usuario_register_dto.dart';
import '../Viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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

  void _showSnackBar(String message, [Color color = Colors.red]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _registerUser(AuthViewModel authViewModel) async {
    if (!_validateFields()) return;

    final usuario = UsuarioRegisterDTO(
      nombre: _nombreController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    final success = await authViewModel.register(usuario);
    if (success) {
      _showSnackBar("Registro exitoso", Colors.green);
      Navigator.pushReplacementNamed(context, '/main');
    } else if (authViewModel.error != null) {
      _showSnackBar(authViewModel.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D1C2F),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D1C2F),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: const Color(0xFFB1D1EC),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    "Create an Account",
                    style: TextStyle(
                      color: Color(0xFFB1D1EC),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 100),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: "Name",
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
                    onPressed: authViewModel.isLoading
                        ? null
                        : () => _registerUser(authViewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7495B4),
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.black.withOpacity(0.3),
                      elevation: 5,
                    ),
                    child: authViewModel.isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            "Create",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
