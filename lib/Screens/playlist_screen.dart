import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrearPlaylistScreen extends StatefulWidget {
  const CrearPlaylistScreen({super.key});

  @override
  State<CrearPlaylistScreen> createState() => _CrearPlaylistScreenState();
}

class _CrearPlaylistScreenState extends State<CrearPlaylistScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imagenController = TextEditingController();

  bool _isLoading = false;

  Future<void> _crearPlaylist() async {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final imagenUrl = _imagenController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre es obligatorio")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final url = Uri.parse('http://192.168.0.23:8081/playlists/crear');

      final body = {
        "nombre": nombre,
        "descripcion": descripcion,
        "imagenUrl": imagenUrl.isNotEmpty ? imagenUrl : null,
      };

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Regresa a biblioteca
      } else {
        print("❌ Error al crear la playlist: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al crear la playlist")),
        );
      }
    } catch (e) {
      print("❌ Excepción al crear playlist: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear nueva playlist")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre de la playlist"),
            ),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: _imagenController,
              decoration: const InputDecoration(labelText: "URL de imagen (opcional)"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _crearPlaylist,
                    icon: const Icon(Icons.check),
                    label: const Text("Crear"),
                  ),
          ],
        ),
      ),
    );
  }
}