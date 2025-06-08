import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/Cancion.dart';
import '../Viewmodels/cancion_viewmodel.dart';
import '../Viewmodels/audio_player_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CancionViewModel>(context, listen: false).cargarCancionesDemo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CancionViewModel, AudioPlayerViewModel>(
      builder: (context, cancionVM, audioVM, _) {
        final canciones = cancionVM.demoCanciones;
        final isLoading = cancionVM.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            automaticallyImplyLeading: false,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Demo Songs",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: canciones.length,
                          itemBuilder: (context, index) {
                            final cancion = canciones[index];
                            final isPlaying = audioVM.currentPlayingId == cancion.id && audioVM.isPlaying;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  width: 160,
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: cancion.imagenUrl.isNotEmpty
                                            ? Image.network(
                                                cancion.imagenUrl,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              )
                                            : const Icon(Icons.music_note, size: 80),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cancion.nombre,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      IconButton(
                                        icon: Icon(
                                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                                        ),
                                        iconSize: 28,
                                        onPressed: () => audioVM.togglePlay(cancion),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
