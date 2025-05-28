import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_tfg_flutter/Screens/details/artista_detail_screen.dart';
import 'package:spotify_tfg_flutter/Screens/details/cancion_detail_screen.dart';

import '../DTO/UsuarioBibliotecaMostrableDTO.dart';
import '../Model/Album.dart';
import '../Model/Artista.dart';
import '../Model/Cancion.dart';
import '../Model/Playlist.dart';
import 'details/album_detail_screen.dart';
import 'details/playlist_detail_screen.dart';
import '../Service/playlist_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _baseUrl = 'http://192.168.0.23:8081/usuario';

  List<Cancion> likedSongs = [];
  List<Playlist> likedPlaylists = [];
  List<Artista> likedArtists = [];
  List<Album> likedAlbums = [];

  String filtro = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarBiblioteca();
  }

  Future<void> _cargarBiblioteca() async {
    setState(() => _isLoading = true);
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse("$_baseUrl/biblioteca"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final usuario =
            UsuarioBibliotecaMostrableDTO.fromJson(jsonDecode(response.body));
        final biblioteca = usuario.biblioteca;

        setState(() {
          likedSongs = biblioteca.canciones;
          likedPlaylists = biblioteca.playlists;
          likedArtists = biblioteca.artistas;
          likedAlbums = biblioteca.albumes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error al cargar biblioteca: $e");
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFiltroButton(String label) {
    final isSelected = filtro == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => filtro = label),
    );
  }

  Widget _buildPlaylistOptions(BuildContext context, Playlist playlist) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Editar Playlist'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/editarPlaylist', arguments: playlist)
                .then((_) => _cargarBiblioteca());
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text('Eliminar Playlist', style: TextStyle(color: Colors.red)),
          onTap: () async {
            Navigator.pop(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Confirmar eliminación"),
                content: const Text("¿Seguro que deseas eliminar esta playlist?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar")),
                ],
              ),
            );

            if (confirmed == true) {
              final token = await FirebaseAuth.instance.currentUser?.getIdToken();
              if (token != null) {
                await PlaylistService().eliminarPlaylist(token, playlist.id!);
                _cargarBiblioteca();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Playlist eliminada")),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildContenido() {
    final List<Widget> items = [];

    if (filtro == 'All' || filtro == 'Canciones') {
      items.addAll(likedSongs.map((cancion) => ListTile(
            leading: Image.network(cancion.imagenUrl, width: 50, height: 50),
            title: Text(cancion.nombre),
            subtitle: Text(cancion.artista),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CancionDetailScreen(cancion: cancion),
                ),
              );
              _cargarBiblioteca();
            })));
    }
    if (filtro == 'All' || filtro == 'Artistas') {
      items.addAll(likedArtists.map((artista) => ListTile(
          leading:
              Image.network(artista.imagenUrl ?? '', width: 50, height: 50),
          title: Text(artista.nombre),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ArtistaDetailScreen(artista: artista)),
            );
            _cargarBiblioteca();
          })));
    }
    if (filtro == 'All' || filtro == 'Álbumes') {
      items.addAll(likedAlbums.map((album) => ListTile(
            leading:
                Image.network(album.imagenUrl ?? '', width: 50, height: 50),
            title: Text(album.nombre),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AlbumDetailScreen(album: album)),
              );
              _cargarBiblioteca();
            })));
    }
    if (filtro == 'All' || filtro == 'Playlists') {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      items.addAll(likedPlaylists.map((playlist) => GestureDetector(
        onLongPress: () {
          if (playlist.creadorId == currentUserId) {
            Navigator.pushNamed(context, '/editarPlaylist', arguments: playlist)
                .then((_) => _cargarBiblioteca());
          }
        },
        child: ListTile(
          leading: playlist.imagenUrl.isNotEmpty
              ? Image.network(playlist.imagenUrl, width: 50, height: 50)
              : Image.asset('assets/song_cover.png', width: 50, height: 50),
          title: Text(playlist.nombre),
          trailing: playlist.creadorId == currentUserId
              ? IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Confirmar eliminación"),
                        content: const Text("¿Eliminar esta playlist?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar")),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
                      if (token != null) {
                        await PlaylistService().eliminarPlaylist(token, playlist.id!);
                        _cargarBiblioteca();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Playlist eliminada")),
                        );
                      }
                    }
                  },
                )
              : null,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlist: playlist)),
            );
            _cargarBiblioteca();
          },
        ),
      )));
    }

    return Expanded(child: ListView(children: items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Biblioteca")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                _buildFiltroButton("All"),
                _buildFiltroButton("Canciones"),
                _buildFiltroButton("Artistas"),
                _buildFiltroButton("Álbumes"),
                _buildFiltroButton("Playlists"),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading ? const CircularProgressIndicator() : _buildContenido()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/crearPlaylist').then((_) => _cargarBiblioteca());
        },
        child: const Icon(Icons.playlist_add),
      ),
    );
  }
}
