import 'dart:convert';

import '../Model/Cancion.dart';
import 'package:http/http.dart' as http;

class CancionService {
  // final String cancionUrl = 'http://192.168.0.23:8081/canciones';
  // final String spotifyUrl = 'http://192.168.0.23:8081/spotify';

  final String cancionUrl = 'https://music-sound.onrender.com/canciones';
  final String spotifyUrl = 'https://music-sound.onrender.com/spotify';

  Future<List<Cancion>> buscarCanciones(String query) async {
    final url = Uri.parse('$spotifyUrl/buscar/canciones?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Cancion.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar canciones');
    }
  }

  Future<Cancion> obtenerCancionPorId(String id) async {
    final url = Uri.parse('$cancionUrl/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Cancion.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener canción');
    }
  }

  Future<void> darLike(String idToken, String cancionId) async {
    final url = Uri.parse('$cancionUrl/like/$cancionId');
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
    final url = Uri.parse('$cancionUrl/like/$cancionId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode != 200) throw Exception('Error al quitar like');
  }
}