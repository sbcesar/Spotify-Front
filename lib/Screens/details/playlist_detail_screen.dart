import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Model/Playlist.dart';
import '../../Service/playlist_service.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final PlaylistService _playlistService = PlaylistService();
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://music-sound.onrender.com/usuario/perfil'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final biblioteca = data['biblioteca'];
        final likedIds = (biblioteca['likedPlaylists'] as List).cast<String>();
        setState(() {
          _isLiked = likedIds.contains(widget.playlist.id);
        });
      }
    } catch (e) {
      print("Error al verificar si la playlist ya tiene like: $e");
    }
  }

  Future<void> _toggleLike() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      if (_isLiked) {
        await _playlistService.quitarLike(token, widget.playlist.id!);
      } else {
        await _playlistService.darLike(token, widget.playlist.id!);
      }

      setState(() {
        _isLiked = !_isLiked;
      });
    } catch (e) {
      print("Error al cambiar estado del like de la playlist: $e");
    }
  }

  Future<void> _eliminarCancion(String cancionId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      final actualizada = await PlaylistService().eliminarCancionDePlaylist(token, widget.playlist.id!, cancionId);
      setState(() {
        widget.playlist.canciones.clear();
        widget.playlist.canciones.addAll(actualizada.canciones);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Canción eliminada")),
      );
    } catch (e) {
      print("Error al eliminar canción: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar canción")),
      );
    }
  }

  void _confirmarEliminacion(String cancionId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar canción?"),
        content: const Text("¿Seguro que deseas quitar esta canción de la playlist?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _eliminarCancion(cancionId);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;

    return Scaffold(
      appBar: AppBar(title: Text(playlist.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (playlist.imagenUrl.isNotEmpty)
                      ? Image.network(
                          playlist.imagenUrl,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/song_cover.png',
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 20),
                Text(playlist.nombre,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Creador: ${playlist.creadorNombre}"),
                IconButton(
                  icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border),
                  color: Colors.red,
                  onPressed: _toggleLike,
                ),
                const Divider(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Canciones:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                ...playlist.canciones.map((cancion) => ListTile(
                  leading: cancion.imagenUrl.isNotEmpty
                      ? Image.network(cancion.imagenUrl, width: 50, height: 50)
                      : const Icon(Icons.music_note),
                  title: Text(cancion.nombre),
                  subtitle: Text(cancion.artista),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _confirmarEliminacion(cancion.id),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}