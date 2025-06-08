import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/Playlist.dart';
import '../../Viewmodels/playlist_viewmodel.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late Playlist _playlist;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _playlist = widget.playlist;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playlistVM = context.read<PlaylistViewModel>();
      setState(() {
        _isLiked = playlistVM.isLiked(_playlist.id!);
      });
    });
  }

  Future<void> _toggleLike(PlaylistViewModel playlistVM) async {
    await playlistVM.toggleLike(_playlist.id!);
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  Future<void> _eliminarCancion(BuildContext context, String cancionId, PlaylistViewModel playlistVM) async {
    await playlistVM.quitarCancion(_playlist.id!, cancionId);
    final actualizada = playlistVM.playlistSeleccionada;
    if (actualizada != null) {
      setState(() {
        _playlist = actualizada;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Canción eliminada")),
    );
  }

  void _confirmarEliminacion(BuildContext context, String cancionId, PlaylistViewModel playlistVM) {
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
              await _eliminarCancion(context, cancionId, playlistVM);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistViewModel>(
      builder: (_, playlistVM, __) {
        return Scaffold(
          appBar: AppBar(title: Text(_playlist.nombre)),
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
                      child: _playlist.imagenUrl.isNotEmpty
                          ? Image.network(_playlist.imagenUrl, width: 250, height: 250, fit: BoxFit.cover)
                          : Image.asset('assets/song_cover.png', width: 250, height: 250, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 20),
                    Text(_playlist.nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Creador: ${_playlist.creadorNombre}"),
                    IconButton(
                      icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                      color: Colors.red,
                      onPressed: () => _toggleLike(playlistVM),
                    ),
                    const Divider(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Canciones:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    ..._playlist.canciones.map((c) => ListTile(
                          leading: c.imagenUrl.isNotEmpty
                              ? Image.network(c.imagenUrl, width: 50, height: 50)
                              : const Icon(Icons.music_note),
                          title: Text(c.nombre),
                          subtitle: Text(c.artista),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _confirmarEliminacion(context, c.id, playlistVM),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
