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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Demo Songs",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          itemCount: canciones.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) {
                            final cancion = canciones[index];
                            final isPlaying = audioVM.currentPlayingId == cancion.id && audioVM.isPlaying;

                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: cancion.imagenUrl.isNotEmpty
                                          ? Image.network(
                                              cancion.imagenUrl,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/song_cover.png',
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover
                                            ),
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
