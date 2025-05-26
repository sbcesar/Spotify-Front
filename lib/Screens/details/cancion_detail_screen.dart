import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../Model/Cancion.dart';
import '../../Service/cancion_service.dart';

class CancionDetailScreen extends StatefulWidget {
  final Cancion cancion;

  const CancionDetailScreen({super.key, required this.cancion});

  @override
  State<CancionDetailScreen> createState() => _CancionDetailScreenState();
}

class _CancionDetailScreenState extends State<CancionDetailScreen> {
  final CancionService _cancionService = CancionService();
  bool _isLiked = false;
  bool _isLoading = false;

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

    print("➡ Token: $token");
    print("➡ Canción ID: ${widget.cancion.id}");

    if (_isLiked) {
      await CancionService().quitarLike(token, widget.cancion.id);
    } else {
      await CancionService().darLike(token, widget.cancion.id);
    }

    setState(() {
      _isLiked = !_isLiked;
    });
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
      appBar: AppBar(title: Text(c.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (c.imagenUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      c.imagenUrl,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  c.nombre,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text("Artista: ${c.artista}", style: const TextStyle(fontSize: 16)),
                Text("Álbum: ${c.album}", style: const TextStyle(fontSize: 16)),
                Text("Popularidad: ${c.popularidad}", style: const TextStyle(fontSize: 16)),
                Text("Duración: ${_formatDuration(c.duracionMs)}", style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                        color: Colors.red,
                        iconSize: 30,
                        onPressed: _toggleLike,
                      ),
                const SizedBox(height: 10),

                if (c.previewUrl != null && c.previewUrl!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      // En el futuro: reproducir preview
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Reproducir Preview"),
                  )
                else
                  const Text("Sin preview disponible",
                      style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
