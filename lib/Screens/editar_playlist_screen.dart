import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/Playlist.dart';
import '../../Viewmodels/playlist_viewmodel.dart';

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

    final success = await context.read<PlaylistViewModel>().editarPlaylist(
          widget.playlist.id!,
          _nombreController.text.trim(),
          _descripcionController.text.trim(),
          _imagenUrlController.text.trim(),
        );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Playlist actualizada")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar playlist")),
      );
    }
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
