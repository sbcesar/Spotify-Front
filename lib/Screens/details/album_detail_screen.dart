import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/Album.dart';
import '../../Viewmodels/album_viewmodel.dart';

class AlbumDetailScreen extends StatelessWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final albumVM = context.watch<AlbumViewModel>();
    final isLiked = albumVM.isAlbumLiked(album.id);

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
                if (album.imagenUrl != null && album.imagenUrl!.isNotEmpty)
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
                Text(album.nombre,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Fecha de lanzamiento: ${album.fechaLanzamiento}"),
                Text("Popularidad: ${album.popularidad}"),
                Text("Tipo: ${album.tipo}"),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                  color: Colors.red,
                  onPressed: () {
                    albumVM.toggleLike(album.id!);
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
