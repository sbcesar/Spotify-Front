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
        Uri.parse('http://192.168.0.23:8081/usuario/perfil'),
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

  @override
  Widget build(BuildContext context) {
    final p = widget.playlist;

    return Scaffold(
      appBar: AppBar(title: Text(p.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (p.imagenUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      p.imagenUrl,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(p.nombre,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Creador: ${p.creadorNombre}"),
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
                ...p.canciones.map((cancion) => ListTile(
                      leading: cancion.imagenUrl.isNotEmpty
                          ? Image.network(cancion.imagenUrl, width: 50, height: 50)
                          : const Icon(Icons.music_note),
                      title: Text(cancion.nombre),
                      subtitle: Text(cancion.artista),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}