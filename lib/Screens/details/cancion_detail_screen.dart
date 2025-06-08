import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../Model/Cancion.dart';
import '../../Model/Playlist.dart';
import '../../Viewmodels/cancion_viewmodel.dart';
import '../../Viewmodels/playlist_viewmodel.dart';

class CancionDetailScreen extends StatelessWidget {
  final Cancion cancion;

  const CancionDetailScreen({super.key, required this.cancion});

  String _formatDuration(int durationMs) {
    final minutes = (durationMs ~/ 60000);
    final seconds = ((durationMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _mostrarSelectorDePlaylists(BuildContext context, Cancion cancion) async {
    final playlistVM = context.read<PlaylistViewModel>();
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    final playlists = await playlistVM.obtenerPlaylistsDelUsuario(token);
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
                final p = playlists[index];
                return ListTile(
                  leading: p.imagenUrl.isNotEmpty
                      ? Image.network(p.imagenUrl, width: 40, height: 40, fit: BoxFit.cover)
                      : const Icon(Icons.music_note),
                  title: Text(p.nombre),
                  onTap: () async {
                    await playlistVM.agregarCancion(p.id!, cancion.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Canción agregada")),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cancionVM = context.watch<CancionViewModel>();
    final isLiked = cancionVM.isLiked(cancion.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(cancion.nombre, style: const TextStyle(color: Color(0xFFB1D1EC))),
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
                if (cancion.imagenUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      cancion.imagenUrl,
                      width: 320,
                      height: 320,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 25),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cancion.nombre,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB1D1EC)),
                            ),
                            const SizedBox(height: 4),
                            Text("Artista: ${cancion.artista}", style: const TextStyle(fontSize: 16, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                          color: Colors.red,
                          iconSize: 28,
                          onPressed: () => cancionVM.toggleLike(cancion.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          iconSize: 28,
                          onPressed: () => _mostrarSelectorDePlaylists(context, cancion),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 120),
                Text("Álbum: ${cancion.album}", style: const TextStyle(fontSize: 15, color: Colors.white70)),
                Text("Popularidad: ${cancion.popularidad}", style: const TextStyle(fontSize: 15, color: Colors.white70)),
                Text("Duración: ${_formatDuration(cancion.duracionMs)}", style: const TextStyle(fontSize: 15, color: Colors.white70)),
                const SizedBox(height: 40),
                cancion.audioUrl != null && cancion.audioUrl!.isNotEmpty
                    ? ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final player = AudioPlayer();
                            await player.setUrl(cancion.audioUrl!);
                            player.play();
                          } catch (_) {
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      )
                    : const Text("Sin audio disponible", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
