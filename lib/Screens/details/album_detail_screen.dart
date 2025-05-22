import 'package:flutter/material.dart';

import '../../Model/Album.dart';

class AlbumDetailScreen extends StatelessWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
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
                if (album.imagenUrl?.isNotEmpty == true)
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
                Text(
                  album.nombre,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text("Tipo: ${album.tipo}", style: const TextStyle(fontSize: 16)),
                Text("Popularidad: ${album.popularidad}", style: const TextStyle(fontSize: 16)),
                Text("Lanzamiento: ${album.fechaLanzamiento}", style: const TextStyle(fontSize: 16)),
                Text("Total de canciones: ${album.totalCanciones}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                if (album.artistas.isNotEmpty)
                  Text("Artistas: ${album.artistas.join(', ')}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  iconSize: 30,
                  onPressed: () {
                    // Funcionalidad futura
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}