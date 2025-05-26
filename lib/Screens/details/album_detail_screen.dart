import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Model/Album.dart';
import '../../Service/album_service.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  final AlbumService _albumService = AlbumService();
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
        final likedIds = (biblioteca['likedAlbums'] as List).cast<String>();
        setState(() {
          _isLiked = likedIds.contains(widget.album.id);
        });
      }
    } catch (e) {
      print("Error al verificar si el álbum ya tiene like: $e");
    }
  }

  Future<void> _toggleLike() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      if (_isLiked) {
        await _albumService.quitarLike(token, widget.album.id!);
      } else {
        await _albumService.darLike(token, widget.album.id!);
      }

      setState(() {
        _isLiked = !_isLiked;
      });
    } catch (e) {
      print("Error al cambiar estado del like del álbum: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final album = widget.album;

    return Scaffold(
      appBar: AppBar(title: Text(album.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (album.imagenUrl != null && album.imagenUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      album.imagenUrl!,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(album.nombre,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Fecha de lanzamiento: ${album.fechaLanzamiento}"),
                Text("Popularidad: ${album.popularidad}"),
                Text("Tipo: ${album.tipo}"),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border),
                  color: Colors.red,
                  onPressed: _toggleLike,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}