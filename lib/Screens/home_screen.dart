import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Model/Cancion.dart';
import '../Service/audio_player_service.dart'; // Asegúrate de tener este archivo implementado

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiUrl = 'http://192.168.0.23:8081/canciones/all';

  List<Cancion> cancionesLocales = [];
  String? _currentPlayingId;

  @override
  void initState() {
    super.initState();
    _cargarCancionesLocales();
  }

  Future<void> _cargarCancionesLocales() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final canciones = data
            .map((e) => Cancion.fromJson(e))
            .where((c) => c.audioUrl != null && c.audioUrl!.isNotEmpty)
            .toList();
        setState(() {
          cancionesLocales = canciones;
        });
      }
    } catch (e) {
      print("❌ Error al cargar canciones locales: $e");
    }
  }

  void _reproducirCancion(Cancion cancion) async {
    if (_currentPlayingId == cancion.id) {
      AudioPlayerService.stop();
      setState(() => _currentPlayingId = null);
    } else {
      await AudioPlayerService.play(cancion.audioUrl!);
      setState(() => _currentPlayingId = cancion.id);
    }
  }

  @override
  void dispose() {
    AudioPlayerService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: cancionesLocales.isEmpty
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
                      itemCount: cancionesLocales.length,
                      itemBuilder: (context, index) {
                        final cancion = cancionesLocales[index];
                        final isPlaying = _currentPlayingId == cancion.id;

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
                                    onPressed: () => _reproducirCancion(cancion),
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
  }
}
