import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Model/Album.dart';
import '../Service/album_service.dart';

class AlbumViewModel extends ChangeNotifier {
  final AlbumService _albumService = AlbumService();

  List<Album> _resultadosBusqueda = [];
  Set<String> _likedAlbumIds = {};
  bool _isLoading = false;
  String? _error;

  List<Album> get albums => _resultadosBusqueda;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isAlbumLiked(String albumId) => _likedAlbumIds.contains(albumId);

  Future<void> buscarAlbumes(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _resultadosBusqueda = await _albumService.buscarAlbumes(query);
      _error = null;
    } catch (e) {
      _resultadosBusqueda = [];
      _error = 'Error al buscar álbumes';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cargarAlbumsLikeados() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) return;

      final liked = await _albumService.obtenerLikedAlbums(token);
      _likedAlbumIds = liked.toSet();
      notifyListeners();
    } catch (e) {
      print('Error al cargar álbumes likeados: $e');
    }
  }

  Future<void> toggleLike(String albumId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      if (_likedAlbumIds.contains(albumId)) {
        await _albumService.quitarLike(token, albumId);
        _likedAlbumIds.remove(albumId);
      } else {
        await _albumService.darLike(token, albumId);
        _likedAlbumIds.add(albumId);
      }
      notifyListeners();
    } catch (e) {
      print('Error al cambiar estado del like: $e');
    }
  }
}
