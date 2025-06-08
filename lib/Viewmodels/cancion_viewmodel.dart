import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../Model/Cancion.dart';
import '../Service/cancion_service.dart';

class CancionViewModel extends ChangeNotifier {
  final CancionService _cancionService = CancionService();

  List<Cancion> _canciones = [];
  Set<String> _cancionesLikeadas = {};
  Cancion? _cancionSeleccionada;

  List<Cancion> _demoCanciones = [];
  List<Cancion> get demoCanciones => _demoCanciones;

  bool _isLoading = false;
  String? _error;

  List<Cancion> get canciones => _canciones;
  Cancion? get cancionSeleccionada => _cancionSeleccionada;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isLiked(String cancionId) => _cancionesLikeadas.contains(cancionId);

  Future<void> cargarCancionesDemo() async {
    _isLoading = true;
    notifyListeners();

    try {
      _demoCanciones = await _cancionService.cargarCancionesDemo();
      _error = null;
    } catch (e) {
      _error = "Error al cargar canciones demo";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cargarCancionesLikeadas() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      final likedIds = await _cancionService.obtenerLikedSongs(token);
      _cancionesLikeadas = likedIds.toSet();
      notifyListeners();
    } catch (e) {
      print("Error al cargar canciones con like: $e");
    }
  }

  Future<void> buscarCanciones(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _canciones = await _cancionService.buscarCanciones(query);
    } catch (e) {
      _error = "Error al buscar canciones";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> obtenerCancionPorId(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cancionSeleccionada = await _cancionService.obtenerCancionPorId(id);
    } catch (e) {
      _error = "Error al obtener la canción";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(String cancionId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      if (_cancionesLikeadas.contains(cancionId)) {
        await _cancionService.quitarLike(token, cancionId);
        _cancionesLikeadas.remove(cancionId);
      } else {
        await _cancionService.darLike(token, cancionId);
        _cancionesLikeadas.add(cancionId);
      }
      notifyListeners();
    } catch (e) {
      print("Error al cambiar like de la canción: $e");
    }
  }
}
