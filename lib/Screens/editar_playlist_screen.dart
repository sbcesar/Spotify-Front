import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Model/Playlist.dart';

class EditarPlaylistScreen extends StatefulWidget {
  final Playlist playlist;

  const EditarPlaylistScreen({super.key, required this.playlist});

  @override
  State<EditarPlaylistScreen> createState() => _EditarPlaylistScreenState();
}

class _EditarPlaylistScreenState extends State<EditarPlaylistScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imagenUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.playlist.nombre;
    _descripcionController.text = widget.playlist.descripcion ?? '';
    _imagenUrlController.text = widget.playlist.imagenUrl;
  }

  Future<void> _guardarCambios() async {
    setState(() => _isLoading = true);

    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    final body = {
      "nombre": _nombreController.text.trim(),
      "descripcion": _descripcionController.text.trim(),
      "imagenUrl": _imagenUrlController.text.trim(),
    };

    final response = await http.put(
      Uri.parse('https://music-sound.onrender.com/playlists/${widget.playlist.id}/editar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Playlist actualizada")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar playlist")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Playlist")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: _imagenUrlController,
              decoration: const InputDecoration(labelText: "Imagen URL"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _guardarCambios,
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar cambios"),
                  ),
          ],
        ),
      ),
    );
  }
}