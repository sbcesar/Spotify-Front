import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Service/auth_service.dart';
import '../DTO/usuario_register_dto.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final idToken = await credential.user?.getIdToken();
      if (idToken == null) throw Exception('No se pudo obtener el token');

      final response = await _authService.login(idToken);

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        _setError(body['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      _setError('Error al iniciar sesión: $e');
    }

    _setLoading(false);
    return false;
  }

  Future<bool> register(UsuarioRegisterDTO usuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(usuario);
      _isLoading = false;

      if (response.statusCode == 200) {
        return true;
      } else {
        final body = response.body;
        _error = body.isNotEmpty
            ? body
            : 'Error desconocido al registrar usuario';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error de red al registrar usuario';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
