import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Model/Playlist.dart';
import '../Service/playlist_service.dart';

class PlaylistViewModel extends ChangeNotifier {
  final PlaylistService _playlistService = PlaylistService();

  List<Playlist> _playlists = [];
  Set<String> _playlistsLikeadas = {};
  List<Playlist> _resultadosBusqueda = [];
  Playlist? _playlistSeleccionada;

  bool _isLoading = false;
  String? _error;

  List<Playlist> get playlists => _playlists;
  List<Playlist> get resultadosBusqueda => _resultadosBusqueda;
  Playlist? get playlistSeleccionada => _playlistSeleccionada;

  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isLiked(String playlistId) => _playlistsLikeadas.contains(playlistId);

  Future<void> cargarPlaylists() async {
    _isLoading = true;
    notifyListeners();
    try {
      _playlists = await _playlistService.obtenerTodas();
      _error = null;
    } catch (e) {
      _error = "Error al cargar playlists";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> buscarPlaylists(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _resultadosBusqueda = await _playlistService.buscarPlaylists(query);
      _error = null;
    } catch (e) {
      _resultadosBusqueda = [];
      _error = "Error al buscar playlists";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> mezclarPlaylists(String id1, String id2) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return false;

    try {
      await _playlistService.mezclarPlaylists(token, id1, id2);
      await cargarPlaylists();
      return true;
    } catch (e) {
      print("Error al mezclar playlists: $e");
      return false;
    }
  }

  Future<void> seleccionarPlaylistPorId(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _playlistSeleccionada = await _playlistService.obtenerPlaylistPorId(id);
      _error = null;
    } catch (e) {
      _error = "No se pudo cargar la playlist";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Playlist>> obtenerPlaylistsDelUsuario(String token) async {
    try {
      return await _playlistService.obtenerPlaylistsDelUsuario(token);
    } catch (e) {
      print("Error al obtener playlists del usuario: $e");
      return [];
    }
  }

  Future<bool> editarPlaylist(String id, String nombre, String descripcion, String imagenUrl) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return false;

    try {
      await _playlistService.editarPlaylist(token, id, nombre, descripcion, imagenUrl);
      await cargarPlaylists();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> eliminarPlaylist(String playlistId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null) {
      await _playlistService.eliminarPlaylist(token, playlistId);
      await cargarPlaylists();
    }
  }

  Future<void> agregarCancion(String playlistId, String cancionId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null) {
      await _playlistService.agregarCancionAPlaylist(token, playlistId, cancionId);
      await seleccionarPlaylistPorId(playlistId);
    }
  }

  Future<void> quitarCancion(String playlistId, String cancionId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null) {
      _playlistSeleccionada = await _playlistService.eliminarCancionDePlaylist(token, playlistId, cancionId);
      notifyListeners();
    }
  }

  Future<void> toggleLike(String playlistId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      if (_playlistsLikeadas.contains(playlistId)) {
        await _playlistService.quitarLike(token, playlistId);
        _playlistsLikeadas.remove(playlistId);
      } else {
        await _playlistService.darLike(token, playlistId);
        _playlistsLikeadas.add(playlistId);
      }
      notifyListeners();
    } catch (e) {
      print("Error al cambiar like de la playlist: $e");
    }
  }

}
