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
  final _repeatPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  String? _nombreError;
  String? _emailError;
  String? _passwordError;
  String? _repeatPasswordError;

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  bool _validateFields() {
    setState(() {
      _nombreError = _nombreController.text.isEmpty ? 'El nombre no puede estar vacío' : null;

      if (_emailController.text.isEmpty) {
        _emailError = 'El email no puede estar vacío';
      } else if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
        _emailError = 'El email no es válido';
      } else {
        _emailError = null;
      }

      _passwordError = _passwordController.text.length < 6
          ? 'La contraseña debe tener al menos 6 caracteres'
          : null;

      _repeatPasswordError = _passwordController.text != _repeatPasswordController.text
          ? 'Las contraseñas no coinciden'
          : null;
    });

    return [_nombreError, _emailError, _passwordError, _repeatPasswordError].every((e) => e == null);
  }

  Future<void> _registerUser(AuthViewModel vm) async {
    if (!_validateFields()) return;

    final usuario = UsuarioRegisterDTO(
      nombre: _nombreController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    final success = await vm.register(usuario);
    if (success) {
      _showSnackBar("Registro exitoso", color: Colors.green);
      Navigator.pushReplacementNamed(context, '/main');
    } else if (vm.error != null) {
      _showSnackBar(vm.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D1C2F),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D1C2F),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFFB1D1EC)),
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

                  // Nombre
                  _buildField(
                    controller: _nombreController,
                    label: "Name",
                    errorText: _nombreError,
                  ),

                  const SizedBox(height: 20),

                  // Email
                  _buildField(
                    controller: _emailController,
                    label: "Email",
                    errorText: _emailError,
                  ),

                  const SizedBox(height: 20),

                  // Contraseña
                  _buildField(
                    controller: _passwordController,
                    label: "Password",
                    errorText: _passwordError,
                    obscureText: _obscurePassword,
                    toggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),

                  const SizedBox(height: 20),

                  // Repetir contraseña
                  _buildField(
                    controller: _repeatPasswordController,
                    label: "Repeat Password",
                    errorText: _repeatPasswordError,
                    obscureText: _obscureRepeatPassword,
                    toggleObscure: () =>
                        setState(() => _obscureRepeatPassword = !_obscureRepeatPassword),
                  ),

                  const SizedBox(height: 40),

                  // Botón de registro
                  ElevatedButton(
                    onPressed: vm.isLoading ? null : () => _registerUser(vm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7495B4),
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.black.withOpacity(0.3),
                      elevation: 5,
                    ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Create", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? errorText,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFFB1D1EC)),
            filled: true,
            fillColor: const Color(0xFF2C698D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            suffixIcon: toggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
