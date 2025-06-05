import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../../Model/Cancion.dart';
import '../../Model/Playlist.dart';
import '../../Service/cancion_service.dart';
import '../../Service/playlist_service.dart';

class CancionDetailScreen extends StatefulWidget {
  final Cancion cancion;

  const CancionDetailScreen({super.key, required this.cancion});

  @override
  State<CancionDetailScreen> createState() => _CancionDetailScreenState();
}

class _CancionDetailScreenState extends State<CancionDetailScreen> {
  final CancionService _cancionService = CancionService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
        final likedIds = (biblioteca['likedCanciones'] as List).cast<String>();
        setState(() {
          _isLiked = likedIds.contains(widget.cancion.id);
        });
      }
    } catch (e) {
      print("Error al verificar si la canción ya tiene like: $e");
    }
  }

  Future<void> _toggleLike() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("Token no disponible");

    if (_isLiked) {
      await _cancionService.quitarLike(token, widget.cancion.id);
    } else {
      await _cancionService.darLike(token, widget.cancion.id);
    }

    setState(() {
      _isLiked = !_isLiked;
    });
  }

  Future<void> _mostrarSelectorDePlaylists() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.0.23:8081/usuario/biblioteca'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final playlists = (data['biblioteca']['playlists'] as List)
          .map((p) => Playlist.fromJson(p))
          .where((p) => p.creadorId == FirebaseAuth.instance.currentUser?.uid)
          .toList();

      if (playlists.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No tienes playlists creadas")),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Selecciona una playlist"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (_, index) {
                  final playlist = playlists[index];
                  return ListTile(
                    leading: playlist.imagenUrl.isNotEmpty
                        ? Image.network(playlist.imagenUrl, width: 40, height: 40, fit: BoxFit.cover)
                        : const Icon(Icons.music_note),
                    title: Text(playlist.nombre),
                    onTap: () async {
                      try {
                        await PlaylistService().agregarCancionAPlaylist(token, playlist.id!, widget.cancion.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Canción agregada")),
                        );
                      } catch (_) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error al agregar canción")),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    }
  }

  String _formatDuration(int durationMs) {
    final minutes = (durationMs ~/ 60000);
    final seconds = ((durationMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          c.nombre,
          style: const TextStyle(color: Color(0xFFB1D1EC)),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen destacada
                if (c.imagenUrl.isNotEmpty)
                const SizedBox(height: 25),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      c.imagenUrl,
                      width: 320,
                      height: 320,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 25),

                // Título y botones
                // Título, artista y botones
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y artista alineados a la izquierda
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.nombre,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB1D1EC),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Artista: ${c.artista}",
                              style: const TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botones alineados horizontalmente
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                          color: Colors.red,
                          iconSize: 28,
                          onPressed: _toggleLike,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          iconSize: 28,
                          onPressed: _mostrarSelectorDePlaylists,
                        ),
                      ],
                    ),
                  ],
                ),


                const SizedBox(height: 120),

                // Info adicional
                Text("Álbum: ${c.album}", style: const TextStyle(fontSize: 15, color: Colors.white70)),
                Text("Popularidad: ${c.popularidad}", style: const TextStyle(fontSize: 15, color: Colors.white70)),
                Text("Duración: ${_formatDuration(c.duracionMs)}", style: const TextStyle(fontSize: 15, color: Colors.white70)),

                const SizedBox(height: 40),

                // Audio o mensaje
                c.audioUrl != null && c.audioUrl!.isNotEmpty
                    ? ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await _audioPlayer.setUrl(c.audioUrl!);
                            _audioPlayer.play();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("No se pudo reproducir el audio")),
                            );
                          }
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Reproducir canción"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7495B4),
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      )
                    : const Text(
                        "Sin audio disponible",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
