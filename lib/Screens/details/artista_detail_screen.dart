import 'package:flutter/material.dart';

import '../../Model/Artista.dart';

class ArtistaDetailScreen extends StatelessWidget {
  final Artista artista;

  const ArtistaDetailScreen({super.key, required this.artista});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(artista.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                if (artista.imagenUrl?.isNotEmpty == true)
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
                Text(
                  artista.nombre,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text("Popularidad: ${artista.popularidad}", style: const TextStyle(fontSize: 16)),
                Text("Seguidores: ${artista.seguidores}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                if (artista.generos.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: artista.generos.map((g) => Chip(label: Text(g))).toList(),
                  ),
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