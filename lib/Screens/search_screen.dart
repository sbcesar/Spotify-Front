import 'package:flutter/material.dart';

import '../Model/Album.dart';
import '../Model/Artista.dart';
import '../Model/Cancion.dart';
import '../Model/Playlist.dart';
import '../Service/spotify_service.dart';
import 'details/album_detail_screen.dart';
import 'details/artista_detail_screen.dart';
import 'details/playlist_detail_screen.dart';
import 'details/song_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final SpotifyService _spotifyService = SpotifyService();

  List<Cancion> _canciones = [];
  List<Artista> _artistas = [];
  List<Album> _albumes = [];
  List<Playlist> _playlists = [];

  bool _isLoading = false;

  void _buscar() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _canciones = [];
      _artistas = [];
      _albumes = [];
      _playlists = [];
    });

    try {
      final canciones = await _spotifyService.buscarCanciones(query);
      final artistas = await _spotifyService.buscarArtistas(query);
      final albumes = await _spotifyService.buscarAlbumes(query);
      final playlists = await _spotifyService.buscarPlaylists(query);

      setState(() {
        _canciones = canciones;
        _artistas = artistas;
        _albumes = albumes;
        _playlists = playlists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error: $e');
    }
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
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
      onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SongDetailScreen(cancion: cancion),
        ),
      );
    },
    );
  }

  Widget _buildArtista(Artista artista) {
    return ListTile(
      leading: artista.imagenUrl?.isNotEmpty == true
          ? Image.network(artista.imagenUrl!, width: 50, height: 50)
          : const Icon(Icons.person),
      title: Text(artista.nombre),
      trailing: _buildBadge('Artista', Colors.blue),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtistaDetailScreen(artista: artista),
          ),
        );
      },
    );
  }

  Widget _buildAlbum(Album album) {
    return ListTile(
      leading: album.imagenUrl?.isNotEmpty == true
          ? Image.network(album.imagenUrl!, width: 50, height: 50)
          : const Icon(Icons.album),
      title: Text(album.nombre),
      trailing: _buildBadge('Álbum', Colors.orange),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlbumDetailScreen(album: album),
          ),
        );
      },
    );
  }

  Widget _buildPlaylist(Playlist playlist) {
  return ListTile(
    leading: playlist.imagenUrl.isNotEmpty
        ? Image.network(playlist.imagenUrl, width: 50, height: 50)
        : const Icon(Icons.queue_music),
    title: Text(playlist.nombre),
    subtitle: Text("Por ${playlist.creadorNombre}"),
    trailing: _buildBadge('Playlist', Colors.deepPurple),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaylistDetailScreen(playlist: playlist),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buscar canciones")),
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
                  onPressed: _buscar,
                ),
              ),
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView(
                      children: [
                        const Text("Canciones",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ..._canciones.map(_buildCancion).toList(),
                        const SizedBox(height: 16),
                        const Text("Artistas",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ..._artistas.map(_buildArtista).toList(),
                        const SizedBox(height: 16),
                        const Text("Álbumes",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ..._albumes.map(_buildAlbum).toList(),
                        const SizedBox(height: 16),
                        const Text("Playlists", 
                          style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                        ..._playlists.map(_buildPlaylist).toList(),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}