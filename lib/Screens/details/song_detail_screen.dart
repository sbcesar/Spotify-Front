import 'package:flutter/material.dart';

import '../../Model/Cancion.dart';


class SongDetailScreen extends StatelessWidget {
  final Cancion cancion;

  const SongDetailScreen({super.key, required this.cancion});

  String _formatDuration(int durationMs) {
    final minutes = (durationMs ~/ 60000);
    final seconds = ((durationMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cancion.nombre)),
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
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),

                Text(
                  cancion.nombre,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),
                Text("Artista: ${cancion.artista}", style: const TextStyle(fontSize: 16)),
                Text("Álbum: ${cancion.album}", style: const TextStyle(fontSize: 16)),
                Text("Popularidad: ${cancion.popularidad}", style: const TextStyle(fontSize: 16)),
                Text("Duración: ${_formatDuration(cancion.duracionMs)}", style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 30),

                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  iconSize: 30,
                  onPressed: () {
                    // Like: funcionalidad futura
                  },
                ),

                const SizedBox(height: 10),

                if (cancion.previewUrl != null && cancion.previewUrl!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Preview futura
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Reproducir Preview"),
                  )
                else
                  const Text("Sin preview disponible", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
