import 'dart:convert';

import '../Model/Cancion.dart';
import 'package:http/http.dart' as http;

class CancionService {
  final String baseUrl = 'https://music-sound.onrender.com';

  Future<List<Cancion>> buscarCanciones(String query) async {
    final url = Uri.parse('$baseUrl/spotify/buscar/canciones?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Cancion.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar canciones');
    }
  }

  Future<Cancion> obtenerCancionPorId(String id) async {
    final url = Uri.parse('$baseUrl/canciones/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Cancion.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener canción');
    }
  }

  Future<List<String>> obtenerLikedSongs(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/perfil'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final biblioteca = data['biblioteca'];
      return List<String>.from(biblioteca['likedCanciones'] ?? []);
    } else {
      throw Exception('Error al obtener canciones con like');
    }
  }

  Future<void> darLike(String idToken, String cancionId) async {
    final url = Uri.parse('$baseUrl/canciones/like/$cancionId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode != 200) throw Exception('Error al dar like');
  }

  Future<void> quitarLike(String idToken, String cancionId) async {
    final url = Uri.parse('$baseUrl/canciones/like/$cancionId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode != 200) throw Exception('Error al quitar like');
  }

  Future<List<Cancion>> cargarCancionesDemo() async {
    final response = await http.get(Uri.parse('$baseUrl/canciones/all'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Cancion.fromJson(e))
          .where((c) => c.audioUrl != null && c.audioUrl!.isNotEmpty)
          .toList();
    } else {
      throw Exception("Error al cargar canciones demo");
    }
  }
}