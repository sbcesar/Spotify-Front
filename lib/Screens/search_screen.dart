import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/Album.dart';
import '../Model/Artista.dart';
import '../Model/Cancion.dart';
import '../Model/Playlist.dart';
import '../Viewmodels/album_viewmodel.dart';
import '../Viewmodels/artista_viewmodel.dart';
import '../Viewmodels/cancion_viewmodel.dart';
import '../Viewmodels/playlist_viewmodel.dart';
import 'details/album_detail_screen.dart';
import 'details/artista_detail_screen.dart';
import 'details/playlist_detail_screen.dart';
import 'details/cancion_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;

  void _buscar(BuildContext context) async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        context.read<CancionViewModel>().buscarCanciones(query),
        context.read<ArtistaViewModel>().buscarArtistas(query),
        context.read<AlbumViewModel>().buscarAlbumes(query),
        context.read<PlaylistViewModel>().buscarPlaylists(query),
      ]);
    } catch (e) {
      print('Error en búsqueda: $e');
    }

    setState(() => _isLoading = false);
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildCancion(Cancion cancion) {
    return ListTile(
      leading: cancion.imagenUrl.isNotEmpty
          ? Image.network(cancion.imagenUrl, width: 50, height: 50)
          : const Icon(Icons.music_note),
      title: Text(cancion.nombre),
      subtitle: Text(cancion.artista),
      trailing: _buildBadge('Canción', Colors.green),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CancionDetailScreen(cancion: cancion)),
      ),
    );
  }

  Widget _buildArtista(Artista artista) {
    return ListTile(
      leading: artista.imagenUrl?.isNotEmpty == true
          ? Image.network(artista.imagenUrl!, width: 50, height: 50)
          : const Icon(Icons.person),
      title: Text(artista.nombre),
      trailing: _buildBadge('Artista', Colors.blue),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ArtistaDetailScreen(artista: artista)),
      ),
    );
  }

  Widget _buildAlbum(Album album) {
    return ListTile(
      leading: album.imagenUrl?.isNotEmpty == true
          ? Image.network(album.imagenUrl!, width: 50, height: 50)
          : const Icon(Icons.album),
      title: Text(album.nombre),
      trailing: _buildBadge('Álbum', Colors.orange),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
      ),
    );
  }

  Widget _buildPlaylist(Playlist playlist) {
    return ListTile(
      leading: playlist.imagenUrl.isNotEmpty
          ? Image.network(
              playlist.imagenUrl,
              width: 50,
              height: 50,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            )
          : const Icon(Icons.queue_music),
      title: Text(playlist.nombre),
      subtitle: Text("Por ${playlist.creadorNombre ?? 'Desconocido'}"),
      trailing: _buildBadge('Playlist', Colors.deepPurple),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlist: playlist)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canciones = context.watch<CancionViewModel>().canciones;
    final artistas = context.watch<ArtistaViewModel>().artistas;
    final albumes = context.watch<AlbumViewModel>().albums;
    final playlists = context.watch<PlaylistViewModel>().resultadosBusqueda;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Buscar...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _buscar(context),
                ),
              ),
              onSubmitted: (_) => _buscar(context),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView(
                      children: [
                        const Text("Canciones",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ...canciones.map(_buildCancion).toList(),
                        const SizedBox(height: 16),
                        const Text("Artistas",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ...artistas.map(_buildArtista).toList(),
                        const SizedBox(height: 16),
                        const Text("Álbumes",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ...albumes.map(_buildAlbum).toList(),
                        const SizedBox(height: 16),
                        const Text("Playlists",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ...playlists.map(_buildPlaylist).toList(),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
