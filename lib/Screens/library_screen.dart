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
  final _baseUrl = 'https://music-sound.onrender.com/usuario';

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

      final todasLasPlaylists = await PlaylistService().obtenerTodas();

      if (response.statusCode == 200) {
        final usuario = UsuarioBibliotecaMostrableDTO.fromJson(jsonDecode(response.body));
        final biblioteca = usuario.biblioteca;

        final playlistIdsDelUsuario = biblioteca.playlists.map((p) => p.id).toSet();

        setState(() {
          likedSongs = biblioteca.canciones;
          likedArtists = biblioteca.artistas;
          likedAlbums = biblioteca.albumes;
          likedPlaylists = [
            ...biblioteca.playlists,
            ...todasLasPlaylists.where((p) => !playlistIdsDelUsuario.contains(p.id)),
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error al cargar biblioteca: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _mostrarDialogoMezcla() async {
    List<String> seleccionadas = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Selecciona 2 playlists para mezclar"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: likedPlaylists.length,
                  itemBuilder: (context, index) {
                    final playlist = likedPlaylists[index];
                    final selected = seleccionadas.contains(playlist.id);
                    return CheckboxListTile(
                      value: selected,
                      title: Text(playlist.nombre),
                      onChanged: (checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            if (seleccionadas.length < 2) {
                              seleccionadas.add(playlist.id!);
                            }
                          } else {
                            seleccionadas.remove(playlist.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: seleccionadas.length == 2
                      ? () async {
                          Navigator.pop(context);
                          await _mezclarPlaylists(seleccionadas[0], seleccionadas[1]);
                        }
                      : null,
                  child: const Text("Crear mezcla"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _mezclarPlaylists(String id1, String id2) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      print("❌ No hay token disponible.");
      return;
    }

    final body = {
      "playlistId1": id1,
      "playlistId2": id2,
    };

    print("➡️ Enviando mezcla con IDs:");
    print("   Playlist 1: $id1");
    print("   Playlist 2: $id2");

    final response = await http.post(
      Uri.parse("https://music-sound.onrender.com/playlists/mix"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(body),
    );

    print("📨 Código de respuesta: ${response.statusCode}");
    print("📨 Cuerpo de respuesta: ${response.body}");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Playlist mezclada creada exitosamente!")),
      );
      _cargarBiblioteca();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al crear la mezcla")),
      );
    }
  }

  Widget _buildFiltroButton(String label) {
    final isSelected = filtro == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF7495B4),
      backgroundColor: const Color(0xFF2C698D),
      onSelected: (_) => setState(() => filtro = label),
    );
  }

  Widget _buildContenido() {
    final List<Widget> items = [];

    if (filtro == 'All' || filtro == 'Canciones') {
      items.addAll(likedSongs.map((cancion) => Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(cancion.imagenUrl, width: 50, height: 50, fit: BoxFit.cover),
              ),
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
              },
            ),
          )));
    }

    if (filtro == 'All' || filtro == 'Artistas') {
      items.addAll(likedArtists.map((artista) => Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(artista.imagenUrl ?? '', width: 50, height: 50, fit: BoxFit.cover),
              ),
              title: Text(artista.nombre),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtistaDetailScreen(artista: artista),
                  ),
                );
                _cargarBiblioteca();
              },
            ),
          )));
    }

    if (filtro == 'All' || filtro == 'Álbumes') {
      items.addAll(likedAlbums.map((album) => Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(album.imagenUrl ?? '', width: 50, height: 50, fit: BoxFit.cover),
              ),
              title: Text(album.nombre),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlbumDetailScreen(album: album),
                  ),
                );
                _cargarBiblioteca();
              },
            ),
          )));
    }

    if (filtro == 'All' || filtro == 'Playlists') {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      items.addAll(likedPlaylists.map((playlist) => Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: GestureDetector(
              onLongPress: () {
                if (playlist.creadorId == currentUserId) {
                  Navigator.pushNamed(context, '/editarPlaylist', arguments: playlist)
                      .then((_) => _cargarBiblioteca());
                }
              },
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: playlist.imagenUrl.isNotEmpty
                      ? Image.network(playlist.imagenUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : Image.asset('assets/song_cover.png', width: 50, height: 50),
                ),
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
            ),
          )));
    }

    return Expanded(child: ListView(children: items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Biblioteca"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFiltroButton("All"),
                _buildFiltroButton("Canciones"),
                _buildFiltroButton("Artistas"),
                _buildFiltroButton("Álbumes"),
                _buildFiltroButton("Playlists"),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading ? const CircularProgressIndicator() : _buildContenido(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "mezclarBtn",
            onPressed: _mostrarDialogoMezcla,
            child: const Icon(Icons.shuffle),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "crearBtn",
            onPressed: () {
              Navigator.pushNamed(context, '/crearPlaylist').then((_) => _cargarBiblioteca());
            },
            child: const Icon(Icons.playlist_add),
          ),
        ],
      ),
    );
  }
}