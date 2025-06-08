import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Model/Artista.dart';
import '../Service/artista_service.dart';

class ArtistaViewModel extends ChangeNotifier {
  final ArtistaService _artistaService = ArtistaService();

  List<Artista> _artistas = [];
  Artista? _artistaSeleccionado;
  Set<String> _artistasLikeados = {};
  bool _isLoading = false;
  String? _error;

  List<Artista> get artistas => _artistas;
  Artista? get artistaSeleccionado => _artistaSeleccionado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isLiked(String artistaId) => _artistasLikeados.contains(artistaId);

  Future<void> buscarArtistas(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _artistas = await _artistaService.buscarArtistas(query);
    } catch (e) {
      _error = "Error al buscar artistas";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cargarArtistasLikeados() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      final likedIds = await _artistaService.obtenerLikedArtistas(token);
      _artistasLikeados = likedIds.toSet();
      notifyListeners();
    } catch (e) {
      print("Error al cargar artistas con like: $e");
    }
  }

  Future<void> toggleLike(String artistaId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      if (_artistasLikeados.contains(artistaId)) {
        await _artistaService.quitarLike(token, artistaId);
        _artistasLikeados.remove(artistaId);
      } else {
        await _artistaService.darLike(token, artistaId);
        _artistasLikeados.add(artistaId);
      }
      notifyListeners();
    } catch (e) {
      print("Error al cambiar like del artista: $e");
    }
  }
}
