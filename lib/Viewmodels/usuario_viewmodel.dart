import 'package:flutter/material.dart';
import '../DTO/UsuarioDTO.dart';
import '../DTO/UsuarioBibliotecaMostrableDTO.dart';
import '../Service/usuario_service.dart';

class UsuarioViewModel extends ChangeNotifier {
  final UsuarioService _usuarioService = UsuarioService();

  UsuarioDTO? _usuarioActual;
  UsuarioBibliotecaMostrableDTO? _biblioteca;
  bool _isLoading = false;
  String? _error;

  UsuarioDTO? get usuarioActual => _usuarioActual;
  UsuarioBibliotecaMostrableDTO? get usuarioBiblioteca => _biblioteca;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarUsuarioActual() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usuarioActual = await _usuarioService.obtenerUsuarioActual();
    } catch (e) {
      _error = 'Error al cargar usuario: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cargarBiblioteca() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _biblioteca = await _usuarioService.obtenerBibliotecaMostrable();
    } catch (e) {
      _error = 'Error al cargar biblioteca: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

}
