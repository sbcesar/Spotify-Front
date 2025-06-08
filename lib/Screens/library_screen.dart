import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_tfg_flutter/Viewmodels/playlist_viewmodel.dart';
import 'package:spotify_tfg_flutter/Viewmodels/usuario_viewmodel.dart';
import '../Screens/details/album_detail_screen.dart';
import '../Screens/details/artista_detail_screen.dart';
import '../Screens/details/cancion_detail_screen.dart';
import '../Screens/details/playlist_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String filtro = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuarioVM = context.read<UsuarioViewModel>();
      final playlistVM = context.read<PlaylistViewModel>();
      usuarioVM.cargarBiblioteca();
      playlistVM.cargarPlaylists();
    });
  }

  Future<void> _mostrarDialogoMezcla(
    UsuarioViewModel usuarioVM, PlaylistViewModel playlistVM) async {
    List<String> seleccionadas = [];

    final todas = playlistVM.playlists;
    final propias = usuarioVM.usuarioBiblioteca?.biblioteca.playlists ?? [];
    final likedPlaylists = [
      ...propias,
      ...todas.where((p) => !propias.map((e) => e.id).contains(p.id)),
    ];

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
                          final success = await playlistVM
                              .mezclarPlaylists(seleccionadas[0], seleccionadas[1]);
                          if (success) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("¡Playlist mezclada creada!")),
                              );
                              await usuarioVM.cargarBiblioteca();
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Error al crear la mezcla")),
                              );
                            }
                          }
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<UsuarioViewModel, PlaylistViewModel>(
      builder: (context, usuarioVM, playlistVM, child) {
        final biblioteca = usuarioVM.usuarioBiblioteca?.biblioteca;

        if (usuarioVM.isLoading || biblioteca == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUserId = usuarioVM.usuarioBiblioteca?.id;
        final todas = playlistVM.playlists;
        final propias = biblioteca.playlists;
        final likedPlaylists = [
          ...propias,
          ...todas.where((p) => !propias.map((e) => e.id).contains(p.id)),
        ];

        List<Widget> items = [];

        if (filtro == 'All' || filtro == 'Canciones') {
          items.addAll(biblioteca.canciones.map((c) => ListTile(
                leading: Image.network(c.imagenUrl, width: 50, height: 50),
                title: Text(c.nombre),
                subtitle: Text(c.artista),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CancionDetailScreen(cancion: c))),
              )));
        }

        if (filtro == 'All' || filtro == 'Artistas') {
          items.addAll(biblioteca.artistas.map((a) => ListTile(
                leading: a.imagenUrl != null
                    ? Image.network(a.imagenUrl!, width: 50, height: 50)
                    : const Icon(Icons.person),
                title: Text(a.nombre),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ArtistaDetailScreen(artista: a))),
              )));
        }

        if (filtro == 'All' || filtro == 'Álbumes') {
          items.addAll(biblioteca.albumes.map((a) => ListTile(
                leading: a.imagenUrl != null
                    ? Image.network(a.imagenUrl!, width: 50, height: 50)
                    : const Icon(Icons.album),
                title: Text(a.nombre),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AlbumDetailScreen(album: a))),
              )));
        }

        if (filtro == 'All' || filtro == 'Playlists') {
          items.addAll(likedPlaylists.map((p) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: p.imagenUrl.isNotEmpty
                    ? Image.network(p.imagenUrl, width: 50, height: 50, fit: BoxFit.cover)
                    : Image.asset('assets/song_cover.png', width: 50, height: 50, fit: BoxFit.cover),
                ),
                title: Text(p.nombre),
                trailing: p.creadorId == currentUserId
                  ? IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Eliminar playlist"),
                            content: const Text("¿Estás seguro de eliminar esta playlist?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar")),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await playlistVM.eliminarPlaylist(p.id!);
                          await usuarioVM.cargarBiblioteca();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Playlist eliminada")));
                        }
                      },
                    )
                  : null,
                onLongPress: () {
                  if (p.creadorId == currentUserId) {
                    Navigator.pushNamed(context, '/editarPlaylist', arguments: p)
                        .then((_) => usuarioVM.cargarBiblioteca());
                  }
                },
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PlaylistDetailScreen(playlist: p))),
              )));
        }

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
                Expanded(
                  child: ListView(children: items),
                ),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "mezclarBtn",
                onPressed: () =>
                    _mostrarDialogoMezcla(usuarioVM, playlistVM),
                child: const Icon(Icons.shuffle),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "crearBtn",
                onPressed: () {
                  Navigator.pushNamed(context, '/crearPlaylist')
                      .then((_) => usuarioVM.cargarBiblioteca());
                },
                child: const Icon(Icons.playlist_add),
              ),
            ],
          ),
        );
      },
    );
  }
}
