import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Model/Artista.dart';
import '../../Service/artista_service.dart';

class ArtistaDetailScreen extends StatefulWidget {
  final Artista artista;

  const ArtistaDetailScreen({super.key, required this.artista});

  @override
  State<ArtistaDetailScreen> createState() => _ArtistaDetailScreenState();
}

class _ArtistaDetailScreenState extends State<ArtistaDetailScreen> {
  final ArtistaService _artistaService = ArtistaService();
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
        final likedIds = (biblioteca['likedArtistas'] as List).cast<String>();
        setState(() {
          _isLiked = likedIds.contains(widget.artista.id);
        });
      }
    } catch (e) {
      print("Error al verificar si el artista ya tiene like: $e");
    }
  }

  Future<void> _toggleLike() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    try {
      if (_isLiked) {
        await _artistaService.quitarLike(token, widget.artista.id);
      } else {
        await _artistaService.darLike(token, widget.artista.id);
      }

      setState(() {
        _isLiked = !_isLiked;
      });
    } catch (e) {
      print("Error al cambiar estado del like del artista: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final artista = widget.artista;

    return Scaffold(
      appBar: AppBar(title: Text(artista.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (artista.imagenUrl != null && artista.imagenUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      artista.imagenUrl!,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(artista.nombre,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Popularidad: ${artista.popularidad}"),
                Text("Seguidores: ${artista.seguidores}"),
                Text("Géneros: ${artista.generos.join(', ')}"),
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