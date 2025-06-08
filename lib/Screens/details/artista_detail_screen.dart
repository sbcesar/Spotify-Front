import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/Artista.dart';
import '../../Viewmodels/artista_viewmodel.dart';

class ArtistaDetailScreen extends StatefulWidget {
  final Artista artista;

  const ArtistaDetailScreen({super.key, required this.artista});

  @override
  State<ArtistaDetailScreen> createState() => _ArtistaDetailScreenState();
}

class _ArtistaDetailScreenState extends State<ArtistaDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      context.read<ArtistaViewModel>().cargarArtistasLikeados());
  }

  @override
  Widget build(BuildContext context) {
    final artista = widget.artista;

    return Scaffold(
      appBar: AppBar(title: Text(artista.nombre)),
      body: Consumer<ArtistaViewModel>(
        builder: (context, vm, child) {
          final isLiked = vm.isLiked(artista.id!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    Text(artista.nombre,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Popularidad: ${artista.popularidad}"),
                    Text("Seguidores: ${artista.seguidores}"),
                    Text("Géneros: ${artista.generos.join(', ')}"),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                      color: Colors.red,
                      onPressed: () =>
                          vm.toggleLike(artista.id!),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
