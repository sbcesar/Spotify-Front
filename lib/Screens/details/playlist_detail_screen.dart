import 'package:flutter/material.dart';

import '../../Model/Playlist.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(playlist.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            playlist.imagenUrl.isNotEmpty
                ? Image.network(playlist.imagenUrl, width: 200, height: 200)
                : const Icon(Icons.queue_music, size: 100),
            const SizedBox(height: 10),
            Text(
              playlist.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Por ${playlist.creadorNombre}',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 10),
            IconButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para seguir la playlist
              },
              icon: const Icon(Icons.favorite_border),
            ),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Canciones:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ...playlist.canciones.map((cancion) => ListTile(
                  leading: cancion.imagenUrl.isNotEmpty
                      ? Image.network(cancion.imagenUrl, width: 50, height: 50)
                      : const Icon(Icons.music_note),
                  title: Text(cancion.nombre),
                  subtitle: Text(cancion.artista),
                )),
          ],
        ),
      ),
    );
  }
}